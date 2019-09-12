
library(sf)
library(tmap)
library(rgdal)
library(tidyverse)

# DATA IN  -------------------------------------------------------------------->

PM10d <- read_csv('inputs/PostLAEI2013_2020_PM10d.csv')
PM10d_sf <- st_as_sf(PM10d, coords=c('x', 'y'), crs=st_crs(27700)$proj4string) 

oa_ref <- read_csv('inputs/Output_Area_to_Lower_Layer_Super_Output_Area_to_Middle_Layer_Super_Output_Area_to_Local_Authority_District_December_2017_Lookup_in_Great_Britain__Classification_Version_2.csv')
lsoa_lon <- filter(oa_ref, RGN11NM == 'London') %>% select(LSOA11CD, LAD17CD, LAD17NM) %>% distinct()

lsoa <- st_read('inputs/LSOA/Lower_Layer_Super_Output_Areas_December_2011_Generalised_Clipped__Boundaries_in_England_and_Wales.shp')
lsoa <- inner_join(lsoa, lsoa_lon, by=c('lsoa11cd'='LSOA11CD'))
lsoa <- st_transform(lsoa, 27700)


# PROCESSING  -------------------------------------------------------------------->

# LOOP INPUTS
LADs <- distinct(filter(oa_ref, RGN11NM == 'London'), LAD17NM) # distinct list of all LADs in London, to loop through
final_output_df <- data.frame() # empty frame to load data into

# loop through LADs
for (lad in seq(1, nrow(LADs))) {

  print(paste('PROCESSING DATA FOR: ', LADs$LAD17NM[lad]))
  
  # filter LSOA sf to just current LAD
  working_lsoa_sf <- (filter(lsoa, LAD17NM == LADs$LAD17NM[lad]))
  
  print('- creating subset of air data')
  # create temporary sf of just NO2 points in current LAD, for faster processing
  working_NO2_index <- st_contains(st_union(working_lsoa_sf), PM10d_sf, sparse = T)
  working_NO2_sf <-  PM10d_sf[working_NO2_index[[1]],]
  
  # create matrix to store output for each LAD
  out_matrix <- matrix(ncol=6, nrow=nrow(working_lsoa_sf))
  LAD17NM <- working_lsoa_sf$LAD17NM[[1]]
  
  # loop through lsoas in the current LAD and work out NO2 scores
  for (i in seq(1, nrow(working_lsoa_sf))){  #nrow(working_lsoa_sf)
    
    index <- st_contains(working_lsoa_sf[i,1], working_NO2_sf, sparse=T)
    points <- working_NO2_sf[index[[1]],] %>% st_set_geometry(NULL)
    
    lsoa11cd <- working_lsoa_sf$lsoa11cd[[i]]
    count <- nrow(points)
    mean <- mean(points[['conct']])
    max  <- max(points[['conct']])
    min  <- min(points[['conct']])
    
    try(
      out_matrix[i,] <- c(LAD17NM, lsoa11cd, count, mean, max, min)
    )
    if (i %% 50 == 0 ){
    print(paste('-- loaded result no.', i, 'out of', nrow(working_lsoa_sf), ' - ', round(i/nrow(working_lsoa_sf)*100), '% complete'))
    }
  }
  
  print(paste('- calculations complete for: ', LADs$LAD17NM[lad]))
  # load LAD output into a dataframe and name columns
  output_df <- data.frame(out_matrix)
  names(output_df) <- c('LAD17NM', 'lsoa11cd', 'count', 'mean', 'max', 'min')
  
  # if it's the first LAD turn into to final_output, else join to existing final_output
  if (lad == 1){
    final_output_df <- output_df
  } else {
    final_output_df <- rbind(final_output_df, output_df)
  }
  # write final_output table to csv
  write_csv(final_output_df, 'outputs/LAD_all_output_PM10d.csv')
  print('- all data loaded to output table')
}


# read all pollution data and join to one table

no2 <- read_csv('outputs/LAD_all_output_NO2.csv') %>% select(lsoa11cd, no2_mean = NO2_mean)
nox <- read_csv('outputs/LAD_all_output_NOx.csv') %>% select(lsoa11cd, nox_mean = mean) 
pm10 <- read_csv('outputs/LAD_all_output_PM10.csv') %>% select(lsoa11cd, pm10_mean = mean)
pm25 <- read_csv('outputs/LAD_all_output_PM25.csv') %>% select(lsoa11cd, pm25_mean = mean)
  
all_air <-  no2 %>% left_join(nox, by = 'lsoa11cd') %>%
  left_join(pm10, by = 'lsoa11cd') %>%
  left_join(pm25, by = 'lsoa11cd')

write_csv(all_air, 'lon_lsoa_pollution_all.csv')
