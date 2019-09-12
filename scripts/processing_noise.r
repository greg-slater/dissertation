
library(sf)
library(tidyverse)
library(tmap)

# DATA IN ------------------------------------------------------------>
# read in London LSOA sf
lsoa_lon_sf <- st_read('../initial/data_georef/london/london.shp')
lsoa_lon <- lsoa_lon_sf %>% st_set_geometry(NULL)

# NOISE DATA
road_lon <- st_read('data_noise/Road_Lnight_London/Road_Lnight_London.shp') %>%
  st_transform(27700)

rail_lon <- st_read('data_noise/Rail_Lnight_London/Rail_Lnight_London.shp') %>%
  st_transform(27700)


# take random sample to check category counts
road_lon_samp <- road_lon[sample(1:nrow(road_lon), 1000), ]
# check classes
road_lon_samp %>% st_set_geometry(NULL) %>%
  count(NoiseClass)

rail_lon_samp <- rail_lon[sample(1:nrow(rail_lon), 1000), ]
# check classes
rail_lon_samp %>% st_set_geometry(NULL) %>%
  count(NoiseClass)

# LSOA LEVELS  ------------------------------------------------------------>

# list of boroughs
boroughs <- lsoa_lon_sf %>% st_set_geometry(NULL) %>% distinct(LAD17NM)
# output table
final_output <- tibble()
# log for error LSOAs
errors <- NULL

for (b in seq(1, nrow(boroughs))){
  
  lsoas <- filter(lsoa, LAD17NM %in% boroughs[b, ])
  b_boundary <- st_union(lsoas)
  
  print(paste('calculating noise overlap with', boroughs[b, ]))
  
  borough_noise <- st_intersection(b_boundary, rail_lon) %>%
    st_union() %>%
    st_buffer(0)
  
  # empty lists to store results from below
  lsoa_area <- NULL
  noise_area <- NULL
  
  print(paste('running through', nrow(lsoas), 'LSOAs in', boroughs[b, ]))
  
  for (l in seq(1, nrow(lsoas))){
    
    print(l)
    lsoa_overlap <- try(st_intersection(lsoas[l, ], borough_noise))
    
    if(class(lsoa_overlap) == 'try-error'){
      
      err <- lsoas[l, ] %>% st_set_geometry(NULL) %>% select(LSOA11CD)
      errors <- append(errors, err[1,])
      
      lsoa_area <- append(lsoa_area, units::set_units(0, m^2))
      noise_area <- append(noise_area, units::set_units(0, m^2))
      
    } else {
      print('success')
      
      # work out areas for LSOA and noise intersection
      l_area <- st_area(lsoas[l, ])
      n_area <- st_area(lsoa_overlap)
      # append l_area to list
      lsoa_area <- append(lsoa_area, l_area)
      # only append n_area if it has a value, else append 0
      noise_area <- append(noise_area, ifelse(length(n_area) > 0, n_area, units::set_units(0, m^2)))
    }
  }
  
  lsoa_vals <- lsoas %>% st_set_geometry(NULL)
  borough_output <- tibble(lsoa_vals$LSOA11CD, lsoa_area, noise_area)
  final_output <- rbind(final_output, borough_output)
  write_csv(final_output, 'noise/Rail_Lnight_LSOA_area_covered.csv')
}

nrow(final_output)

# lsoa_errors <- tibble(errors = errors)
# write_csv(lsoa_errors, 'noise/Road_Lnight_LSOA_area_errors.csv')

