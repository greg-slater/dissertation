
library(tidyverse)


# script to consolidate all processed data so far, and produce summary 
# stats for all

# DATA IN  -------------------------------------------------------------------->

# all indicator data
health     <- read_csv('../initial/data_health/lon_lsoa_ind_prevalence_percentage_of_pop2_wOB.csv') %>% rename(LSOA11CD = LSOA_CODE)
pollution  <- read_csv('../initial/data_pollution/lon_lsoa_pollution_all.csv') %>% select(LSOA11CD = lsoa11cd, no2 = no2_mean, nox = nox_mean, pm10 = pm10_mean, pm25 = pm25_mean)
temp       <- read_csv('../initial/data_temperature/lon_lsoa_tempmin.csv') %>% select(LSOA11CD, temp)
noise_road <- read_csv('../initial/data_noise/lon_lsoa_Road_Lnight_area_covered_perc.csv') %>% select(LSOA11CD, noise_road = noise_perc)
noise_rail <- read_csv('../initial/data_noise/lon_lsoa_Rail_Lnight_area_covered_perc.csv') %>% select(LSOA11CD, noise_rail = noise_perc)
flood      <- read_csv('../initial/data_flood/lon_lsoa_flood_area_percentage.csv') %>% select(LSOA11CD, flood = flood_percent)

ind_lookup <- read_csv('dataset_ind_cat_lookup.csv')

# London LSOA data - 4,835 rows
lsoa_lon <- read_csv('../initial/data_georef/Output_Area_to_Lower_Layer_Super_Output_Area_to_Middle_Layer_Super_Output_Area_to_Local_Authority_District_December_2017_Lookup_in_Great_Britain__Classification_Version_2.csv') %>% 
  filter(RGN11NM == 'London') %>% 
  select(LSOA11CD, LAD17CD, LAD17NM) %>% 
  distinct()

lon_all <- lsoa_lon %>% left_join(health, by = 'LSOA11CD') %>%
  left_join(pollution, by = 'LSOA11CD') %>%
  left_join(temp, by = 'LSOA11CD') %>%
  left_join(noise_road, by = 'LSOA11CD') %>%
  left_join(noise_rail, by = 'LSOA11CD') %>%
  left_join(flood, by = 'LSOA11CD') 

nrow(lon_all)
nrow(distinct(lon_all))

head(lon_all, 10)
head(ind_lookup)
# write_csv(lon_all, 'lon_all_data.csv')
# lon_all <- read_csv('lon_all_data.csv')

# SUMMARY TABLE  -------------------------------------------------------------------->

tibble(names(lon_all))

lon_all_nar <- lon_all %>% gather('CVDPP':'flood', key = 'data', value = 'value') %>%
  inner_join(ind_lookup, by = 'data')


# summary_stats <- 
summary <- lon_all_nar %>% group_by(category, cat_order, indicator, ind_order, data_name) %>%
  summarise(count = n(), min = min(value), max = max(value), mean = mean(value), std = sd(value))

write_csv(summary, 'summary_stats.csv')

