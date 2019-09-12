
library(sf)
library(tidyverse)
library(tmap)
library(ggplot2)
library(RColorBrewer)

# DATA IN  -------------------------------------------------------------------->

# read in London LSOA sf
lsoa_lon_sf <- st_read('../initial/data_georef/london/london.shp')
lsoa_lon <- lsoa_lon_sf %>% st_set_geometry(NULL)

# flood data
flood <- st_read('flood/RoFSW_london_LSOA/RoFSW_london_LSOA.shp') %>%
  st_transform(27700) %>%
  select(hazard, shape_area, tile_id, LSOA11CD, LAD11NM)


# PROCESSING  -------------------------------------------------------------------->

# empty lists to store results
lsoa_areas <- NULL
lsoa_flood_areas <- NULL
errors <- NULL

# loop through all London LSOAS
for (row in 1:nrow(lsoa_lon)){
  
  # string of current LSOA
  lsoa_name <- (paste(lsoa_lon[row, "LSOA11CD"]))
  # print progress every 50 recs
  if (row %% 50 == 0){
    print(paste('working on record', row, '--', lsoa_name))
  }
  
  # filter flood and LSOA main files down to LSOA in question
  flood_polys <- filter(flood, LSOA11CD == lsoa_name)
  lsoa_poly <- filter(lsoa_lon_sf, LSOA11CD == lsoa_name)
  
  # ERROR HANDLING
  # create polys of only overlapping areas
  flood_overlaps <- try(st_intersection(flood_polys, lsoa_poly))
  # if intersection errors log lsoa to errors list and append 0s to others
  if(class(flood_overlaps) == 'try-error'){
    
    print(paste('ERROR at record', row, '--', lsoa_name))
    errors <- append(errors, lsoa_name)
    lsoa_areas <- append(lsoa_areas, 0)
    lsoa_flood_areas <- append(lsoa_flood_areas, 0)
    
  } else {
  # calculate areas
  lsoa_area <- units::drop_units(st_area(lsoa_poly))
  lsoa_flood_area <- units::drop_units(sum(st_area(flood_overlaps)))
  
  # append areas to list
  lsoa_areas <- append(lsoa_areas, lsoa_area)
  lsoa_flood_areas <- append(lsoa_flood_areas, lsoa_flood_area)
  }
}

# load results to lon_lsoa table
lsoa_lon$lsoa_area <- lsoa_areas
lsoa_lon$lsoa_flood_area <- lsoa_flood_areas
lsoa_lon$flood_percent <- lsoa_lon$lsoa_flood_area / lsoa_lon$lsoa_area 

# check distinct
nrow(lsoa_lon)
nrow(distinct(lsoa_lon))

write_csv(lsoa_lon, 'flood/lon_lsoa_flood_area_percentage.csv')
