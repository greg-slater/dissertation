
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(gtools)
library(tmap)
library(tmaptools)
library(sf)

# processing for uncertainty analysis - essentially puts the index 
# aggregation script in a really big nested loop (...) to test all 
# combinations of input factors. Stores final CI score for every LSOA
# in one big table, as well as summary stats for each test variation

# DATA IN  -------------------------------------------------------------------->

# read in London LSOA sf
lsoa_lon_sf <- st_read('../initial/data_georef/london/london.shp')
# indicator data
lon_all <- read_csv('../descriptive_stats/lon_all_data.csv')
# health data after shrinkage
health_shrunk <- read_csv('../shrinkage/lsoa_health_shrunk_scores_all_final.csv')
# all air pollution indicator data
air <- read_csv('../initial/data_pollution/lon_lsoa_pollution_all.csv')
# factorised air pollution data
air_factor <- read_csv('../pca/lon_lsoa_pollution_factors.csv')


# FUNCTIONS  -------------------------------------------------------------------->

# read in functions
source('functions.r')

# define lists to use in looping
shrinkage_tests <- c('BASIC', 'QUEENS', 'KN-10', 'LAD')
noise_tests <- c('basic')
air_tests <- c('no2_only', 'all_equal', 'factor')

regulating_weights <- list('1' = c(0.25, 0.25, 0.25, 0.25),
                           '2' = c( 0, 0.25, 0.25, 0.25),
                           '3' = c(0.25, 0, 0.25, 0.25),
                           '4' = c(0.25, 0.25, 0, 0.25),
                           '5' = c(0.25, 0.25, 0.25, 0))

cultural_weights <- list('1' = c(1/3, 1/3, 1/3), 
                         '2' = c(0, 0.5, 0.5),
                         '3' = c(0.5, 0, 0.5),
                         '4' = c(0.5, 0.5, 0))

# PROCESSING  -------------------------------------------------------------------->

ua_output <- tibble()

# run loop - will create 240 versions of index and store results for each
for (air_t in seq(1, length(air_tests))){
  
  for (reg_w in seq(1, length(regulating_weights))){

    # NOISE
    noise_w1 <- select(lon_all, LSOA11CD, noise_road) 
    noise_w1[, 'noise_exp'] <- rank_exp(noise_w1, noise_road)
    noise_fin <- select(noise_w1, LSOA11CD, noise_exp)
    
    # AIR POLLUTION
    # no2 only
    air_temp <- select(lon_all, LSOA11CD, no2)
    air_no2 <- air_temp
    air_no2['air_exp'] <- rank_exp(air_no2, no2)
    # all equal
    air_all <- select(air, LSOA11CD = lsoa11cd, no2_mean, nox_mean, pm10_mean, pm25_mean) %>%
      mutate(all = (no2_mean / 4) + (nox_mean / 4) + (pm10_mean / 4) + (pm25_mean / 4))
    
    air_all['air_exp'] <- rank_exp(air_all, all)

    # factor
    air_f <- select(air_factor, LSOA11CD = lsoa11cd, factor_1)
    air_f['air_exp'] <- rank_exp(air_f, factor_1)
    
    # select final based on air test var
    if (air_t == 1){
      air_fin <- select(air_no2, LSOA11CD, air_exp)
    }
    if (air_t == 2){
      air_fin <- select(air_all, LSOA11CD, air_exp)
    }
    if (air_t == 3){
      air_fin <- select(air_f, LSOA11CD, air_exp)
    }

    # REMAINING REG INDICATORS
    reg_all <- select(lon_all, LSOA11CD)
    # exponential transform for remaining two indicators
    reg_all['flood_exp'] <- rank_exp(lon_all, flood)
    reg_all['temp_exp'] <- rank_exp(lon_all, temp)
    # join to final noise and air tables
    reg_all <- reg_all %>% left_join(noise_fin, by = 'LSOA11CD') %>%
      left_join(air_fin, by = 'LSOA11CD')

    # REGULATING DOMAIN - final weighting
    reg_weight <- reg_all %>%
      mutate(reg_score = (flood_exp * regulating_weights[[reg_w]][1]) + (temp_exp * regulating_weights[[reg_w]][2]) + 
               (noise_exp * regulating_weights[[reg_w]][3]) + (air_exp * regulating_weights[[reg_w]][4]))
    
    reg_weight['reg_exp'] <- rank_exp(reg_weight, reg_score)
    reg_fin <- select(reg_weight, LSOA11CD, reg_exp)
    
  
    for (shr_t in seq(1, length(shrinkage_tests))){

      # HEALTH
      # select health data for appropriate shrinkage method and spread to wide table
      health_cur <- filter(health_shrunk, METHOD == shrinkage_tests[shr_t]) %>%
        select(-c('METHOD', 'METHOD_F')) %>%
        spread(key = INDICATOR_GROUP_CODE, value = rate)
      
      # standardise the indicator fields
      std <- health_cur %>% select(-(LSOA11CD)) %>% mutate_all(list(~scale(.) %>% as.vector))
      std['LSOA11CD'] <- health_cur['LSOA11CD']
      
      for (cul_w in seq(1, length(cultural_weights))){
        
        # DOMAIN WEIGHTING
        # combine obesity and cvd into physical indicator
        health_w1 <- std %>% mutate(PHYS = (CVDPP * 0.5) + (OB * 0.5))
        health_w1['phys_exp'] <- rank_exp(health_w1, PHYS)
        health_w1['dem_exp'] <- rank_exp(health_w1, DEM)
        health_w1['dep_exp'] <- rank_exp(health_w1, DEP)
        
        # use weights from list to calculate score
        health_w1 <- health_w1 %>% 
          mutate(health_score = (phys_exp * cultural_weights[[cul_w]][1]) + (dem_exp * cultural_weights[[cul_w]][2]) + 
                   (dep_exp * cultural_weights[[cul_w]][3]))
        
        # transform to exponential and create final table
        health_w1['health_exp'] <- rank_exp(health_w1, health_score)
        health_fin <- select(health_w1, LSOA11CD, health_exp)

        # FINAL INDEX 
        gi_temp <- reg_fin %>%
          left_join(health_fin, by = 'LSOA11CD')
        
        gi_w1 <- gi_temp %>%
          mutate(gi_score = (reg_exp / 2) + (health_exp / 2))
        
        gi_w1['gi_exp'] <- rank_exp(gi_w1, gi_score)
        
        gi_w1 <- gi_w1 %>% mutate(gi_rank = min_rank(gi_score), 
                                  gi_decile = ntile(gi_score, 10))
        
        # print current iteration
        print(paste('shr: ', shrinkage_tests[shr_t], '   cul_w: ', cul_w, '   air_t: ', air_tests[air_t], '   reg_w: ', reg_w))
        
        # create final output table
        gi_fin <- select(gi_w1, LSOA11CD, gi_score, gi_exp, gi_rank, gi_decile)
        
        # add variable fields
        gi_fin$shrinkage_test <- shrinkage_tests[shr_t]
        gi_fin$cultural_weight <- cul_w
        gi_fin$air_test <- air_tests[air_t]
        gi_fin$noise_test <- 'basic'
        gi_fin$regulating_weight <- reg_w
        gi_fin$gi_weight <- 'basic'
        
        ua_output <- rbind(ua_output, gi_fin)
      }
    }
  }
}

write_csv(ua_output, 'uncertainty_analysis_raw_output.csv')

# filter to just the test we're calling the baseline
baseline <- filter(ua_output, shrinkage_test == 'KN-10', cultural_weight == 1, air_test == 'factor', regulating_weight == 1) %>%
  select(LSOA11CD, gi_rank_b = gi_rank)

# save baseine to csv for use in sensitivity analysis
write_csv(baseline, 'outputs/gi_baseline_scores.csv')

# left join baseline to full table, so we can work out each iterations score compared to the baseline
ua_final <- ua_output %>% left_join(baseline, by = 'LSOA11CD') %>%
  mutate(gi_rank_change = abs(gi_rank - gi_rank_b), rank_change_perc = gi_rank_change / 4835)

# write / read as necessary 
# write_csv(sens_final, 'outputs/UA_all_tests_rank_change.csv')
# ua_final <- read_csv('outputs/UA_all_tests_rank_change.csv')

# summary stats for each variation of the model run
ua_vars <- ua_final %>% group_by(shrinkage_test, cultural_weight, air_test, noise_test, regulating_weight, gi_weight) %>%
  summarise(mean_rank_change = mean(rank_change_perc), min_rank_change = min(rank_change_perc), 
            max_rank_change = max(rank_change_perc),sd_rank_change = sd(rank_change_perc), count = n())


# check we're grouping all used indicators, result below should be 0
filter(ua_vars, count != 4835)

write_csv(ua_vars, 'sensitivity_analysis_variants.csv')


# LSOA RANK VARIANCE PER TEST  -------------------------------------------------------------------->

lsoa_lon <- lsoa_lon_sf %>% st_set_geometry(NULL)

# join to get LAD field and create unique test identifier to group by
results <- ua_final %>% left_join(lsoa_lon, by = 'LSOA11CD') %>%
  unite(test, c('shrinkage_test', 'air_test', 'cultural_weight', 'regulating_weight'), remove = FALSE)

nrow(distinct(results, test))

# for each test factor calculate mean rank for each LSOA then deviation in mean rank across each test
dev_shrinkage <- results %>% group_by(LSOA11CD, shrinkage_test) %>% 
  summarise(mean_rank = mean(gi_rank)) %>%
  group_by(LSOA11CD) %>%
  summarise(rank_dev = sd(mean_rank) / 4835, test = 'shrinkage') 

dev_air <- results %>% group_by(LSOA11CD, air_test) %>% 
  summarise(mean_rank = mean(gi_rank)) %>%
  group_by(LSOA11CD) %>%
  summarise(rank_dev = sd(mean_rank) / 4835, test = 'air') 

dev_cultural <- results %>% group_by(LSOA11CD, cultural_weight) %>% 
  summarise(mean_rank = mean(gi_rank)) %>%
  group_by(LSOA11CD) %>%
  summarise(rank_dev = sd(mean_rank) / 4835, test = 'cultural_weights')

dev_regulating <- results %>% group_by(LSOA11CD, regulating_weight) %>% 
  summarise(mean_rank = mean(gi_rank)) %>%
  group_by(LSOA11CD) %>%
  summarise(rank_dev = sd(mean_rank) / 4835, test = 'regulating_weights')

# bind all tables together
dev_all <- plyr::rbind.fill(dev_shrinkage, dev_air, dev_cultural, dev_regulating)
head(dev_all)
# check we have 4835 records for each test
dev_all %>% group_by(test) %>% summarise(count = n())
