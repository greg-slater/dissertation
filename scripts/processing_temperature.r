
library(raster)
library(sf)
library(tidyverse)
library(tmap)

# DATA IN ------------------------------------------------------------>

# LONDON SHAPEFILE >> SF @ 27700CRF
lon <- st_read('london_boundaries/LSOA_2011_London_gen_MHW.shp') %>%
  st_transform(27700) %>%
  select(LSOA11CD, LAD11NM)

# LONDON TEMPERATURE DATA
temp <- raster('temperature/London_Tmin_midnight_2011.tif')

# TEMP DATA >> SF @ 27700CRF
temp_point <- rasterToPoints(temp, spatial = TRUE) %>%
  st_as_sf() %>%
  rename(temp = London_Tmin_midnight_2011) %>%
  st_transform(27700)


# TRANSFORM POINTS TO POLY ------------------------------------------->
# join points to the london LSOA polys, group and summarise
lon_temp <- st_join(lon, temp_point, join = st_contains) %>%
  group_by(LSOA11CD) %>%
  summarise(count = sum(!is.na(temp)), mean = mean(temp))


# DEAL WITH MISSING VALUES ------------------------------------------->
lon_temp_missings <- filter(lon_temp, count == 0)
print(paste("missing values n =", nrow(lon_temp_missings)))

# empty lists
LSOA11CD <- NULL
temp <- NULL

for (m in seq(1, nrow(lon_temp_missings))) {
# for (m in seq(1, 3)) {
  
  # LSOA we're missing data for
  missing <- lon_temp_missings[m,]
  # all surrounding LSOAs, making sure no NAs included 
  # (there are 11 of the 84 LSOAs which have NAs in surrounding LSOAs)
  touching <- lon_temp[missing, op = st_overlaps] %>%
    filter(!is.na(mean))
  # remove geometry and take just character value of LSOA11CD
  st_geometry(missing) <- NULL
  missing <- as.character(droplevels(missing$LSOA11CD))
  # caluclate mean of all touching LSOAs
  missing_temp <- mean(touching$mean)
  # append values to list
  LSOA11CD <- append(LSOA11CD, missing)
  temp <- append(temp, missing_temp)
}

# load into table
temp_missings <- tibble(LSOA11CD, temp)
# check for NAs
filter(temp_missings, is.na(temp))
# append inferred values to missing temps SF
lon_temp_missings <- left_join(lon_temp_missings, temp_missings, by = 'LSOA11CD')


# JOIN BACK WITH VALID DATA  ------------------------------------------->

# filter all temps SF to no missing values, and create temp column
lon_temp_valid <- filter(lon_temp, count > 0)
lon_temp_valid$temp <- lon_temp_valid$mean
# double check missing + valid is same length as starting table
print(paste("all LSOAs =", nrow(lon_temp)))
print(paste("missing + valid LSOAs =", nrow(lon_temp_missings) + nrow(lon_temp_valid)))
# table of just london boroughs
lon_regs <- lon %>% st_set_geometry(NULL)

# bind valid and missings, select fields, and add back on boroughs
lon_temp_fin <- rbind(lon_temp_valid, lon_temp_missings) %>% 
  select(LSOA11CD, count, temp) %>%
  left_join(lon_regs, by = 'LSOA11CD')

# check final table is distinct 
print(paste("rows n =", nrow(lon_temp_fin)))
print(paste("distinct rows n =", nrow(distinct(lon_temp_fin))))


# SAVE ------------------------------------------------------------------->

st_write(lon_temp_fin, 'data_temperature/lon_tmin_LSOA_final/lon_lsoa_tempmin.shp')
lon_temp_fin %>% st_set_geometry(NULL) %>% write_csv('temperature/lon_lsoa_tempmin.csv')
