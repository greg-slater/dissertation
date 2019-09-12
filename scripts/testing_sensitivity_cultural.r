
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(gtools)

# processing for sensitivity analysis - similar set up to the UA processing, 
# but here the loop is focussed just on one aggregation step and runs through 
# a big table of different weight samples created using the dirichlet 
# function at the beginning. Here only Rs for each test is recorded.

# DATA IN  -------------------------------------------------------------------->

lon_all <- read_csv('../descriptive_stats/lon_all_data.csv')
health_shrunk <- read_csv('../shrinkage/lsoa_health_shrunk_scores_all_final.csv')
air <- read_csv('../pca/lon_lsoa_pollution_factors.csv')

baseline <- read_csv('../sensitivity/outputs/gi_baseline_scores.csv') %>%
  select(LSOA11CD, gi_rank_b = gi_rank)

# FUNCTIONS AND VARIABLES -------------------------------------------------------------------->

# read in functions
source('functions.r')

# create table of sample weights - 3 variables, 250 samples for each iteration, alpha ranging from 1-10
weights <- dirSampleSpread(alpha_vals = seq(1, 10, 1), nsamples = 250, nweights = 3)

# sense check output
weights <- arrange(weights, w_focus, alpha)
nrow(weights)
head(weights)
head(filter(weights, w_focus == 1))
head(filter(weights, w_focus == 2))
head(filter(weights, w_focus == 3))
weights %>% group_by(w_focus, alpha) %>% summarise(n = n())


# PROCESSING  -------------------------------------------------------------------->

# below runs through standard index aggregation stages, but looping a particular stage using sample weights from above

# NOISE
noise_w1 <- select(lon_all, LSOA11CD, noise_road) 
noise_w1[, 'noise_exp'] <- rank_exp(noise_w1, noise_road)
noise_fin <- select(noise_w1, LSOA11CD, noise_exp)

# AIR POLLUTION
# factor
air_f <- select(air, LSOA11CD = lsoa11cd, factor_1)
air_f['air_exp'] <- rank_exp(air_f, factor_1)
air_fin <- select(air_f, LSOA11CD, air_exp)

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
  mutate(reg_score = (flood_exp / 4) + (temp_exp / 4) +
           (noise_exp / 4) + (air_exp / 4))

reg_weight['reg_exp'] <- rank_exp(reg_weight, reg_score)
reg_fin <- select(reg_weight, LSOA11CD, reg_exp)


# CULTURAL
# select health data for appropriate shrinkage method and spread to wide table
health_cur <- filter(health_shrunk, METHOD == 'KN-10') %>%
  select(-c('METHOD', 'METHOD_F')) %>%
  spread(key = INDICATOR_GROUP_CODE, value = rate)

# standardise the indicator fields
std <- health_cur %>% select(-(LSOA11CD)) %>% mutate_all(list(~scale(.) %>% as.vector))
std['LSOA11CD'] <- health_cur['LSOA11CD']


# DOMAIN WEIGHTING
# combine obesity and cvd into physical indicator
health_w1 <- std %>% mutate(PHYS = (CVDPP * 0.5) + (OB * 0.5))
health_w1['phys_exp'] <- rank_exp(health_w1, PHYS)
health_w1['dem_exp'] <- rank_exp(health_w1, DEM)
health_w1['dep_exp'] <- rank_exp(health_w1, DEP)


# LOOP FOR SENSITIVITY
score_list <- NULL

for (w in seq(1, nrow(weights))){

  # use weights from list to calculate score
  health_w1 <- health_w1 %>% 
    mutate(health_score = (phys_exp * weights[w, 'w1']) + (dem_exp * weights[w, 'w2']) + 
             (dep_exp * weights[w, 'w3']))
  
  # transform to exponential and create final table
  health_w1['health_exp'] <- rank_exp(health_w1, health_score)
  health_fin <- select(health_w1, LSOA11CD, health_exp)
  
  # FINAL INDEX 
  gi_temp <- reg_fin %>%
    left_join(health_fin, by = 'LSOA11CD')
  
  gi_w1 <- gi_temp %>%
    mutate(gi_score = (reg_exp / 2) + (health_exp / 2))
  
  gi_w1 <- gi_w1 %>% mutate(gi_rank = min_rank(gi_score))
  
  # create final output table - joining to baseline to calculate rank change per LSOA
  gi_fin <- select(gi_w1, LSOA11CD, gi_rank) %>% 
    left_join(baseline, by = 'LSOA11CD') %>%
    mutate(rank_change = abs(gi_rank - gi_rank_b))
  
  mean_r_change <- mean(gi_fin$rank_change)
  score_list <- append(score_list, mean_r_change)
}  

# append score list (of mean rank change per test) back to weights table
weights$rank_change <- score_list
weights$rank_change_percent <- score_list / 4835

write_csv(weights, 'outputs/sensitivity_dirichlet_cultural_results.csv')
