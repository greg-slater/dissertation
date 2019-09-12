
library(tidyverse)

# script to aggregate all final CI data using equal weights in
# all aggregations

# DATA IN  -------------------------------------------------------------------->

lon_all <- read_csv('../descriptive_stats/lon_all_data.csv')
health_shrunk <- read_csv('../shrinkage/lsoa_health_shrunk_scores_all_final.csv')
air <- read_csv('../pca/lon_lsoa_pollution_factors.csv')

# VARIABLES & FUNCTIONS  -------------------------------------------------------------------->

# define shrinkage method to use for health data
shrinkage_method <- 'KN-10'

# read in functions
source('functions.r')

# PROCESSING  -------------------------------------------------------------------->

# HEALTH
# select health data for appropriate shrinkage method and spread to wide table
health_cur <- filter(health_shrunk, METHOD == shrinkage_method) %>%
  select(-c('METHOD', 'METHOD_F')) %>%
  spread(key = INDICATOR_GROUP_CODE, value = rate)

head(health_cur)
nrow(health_cur)

# standardise the indicator fields
std <- health_cur %>% select(-(LSOA11CD)) %>% mutate_all(list(~scale(.) %>% as.vector))
std['LSOA11CD'] <- health_cur['LSOA11CD']


# domain weighting
health_w1 <- std %>% mutate(PHYS = (CVDPP * 0.5) + (OB * 0.5))
health_w1[, 'phys_exp'] <- rank_exp(health_w1, PHYS)
health_w1[, 'dem_exp'] <- rank_exp(health_w1, DEM)
health_w1[, 'dep_exp'] <- rank_exp(health_w1, DEP)

health_w1 <- health_w1 %>% 
  mutate(health_score = (phys_exp / 3) + (dem_exp / 3) + (dep_exp) /3) 

health_w1[, 'health_exp'] <- rank_exp(health_w1, health_score)
health_fin <- select(health_w1, LSOA11CD, phys_exp, dem_exp, dep_exp, health_score, health_exp)

# NOISE
noise_w1 <- select(lon_all, LSOA11CD, noise_road) 
noise_w1[, 'noise_exp'] <- rank_exp(noise_w1, noise_road)
noise_fin <- select(noise_w1, LSOA11CD, noise_exp)


# AIR POLLUTION
air_temp <- select(air, LSOA11CD = lsoa11cd, value = factor_1)

air_w1 <- air_temp
air_w1['air_exp'] <- rank_exp(air_w1, value)
air_fin <- select(air_w1, LSOA11CD, air_exp)

# REMAINING REG INDICATORS
reg_all <- select(lon_all, LSOA11CD)
reg_all['flood_exp'] <- rank_exp(lon_all, flood)
reg_all['temp_exp'] <- rank_exp(lon_all, temp)

reg_all <- reg_all %>% left_join(noise_fin, by = 'LSOA11CD') %>%
  left_join(air_fin, by = 'LSOA11CD')

# REGULATING DOMAIN
reg_w1 <- reg_all %>%
  mutate(reg_score = (flood_exp / 4) + (temp_exp / 4) + (noise_exp / 4) + (air_exp/ 4))

reg_w1['reg_exp'] <- rank_exp(reg_w1, reg_score)
reg_fin <- select(reg_w1, LSOA11CD, flood_exp, temp_exp, noise_exp, air_exp, reg_score, reg_exp)


# FINAL INDEX 
gi_temp <- reg_fin %>%
  left_join(health_fin, by = 'LSOA11CD')

gi_w1 <- gi_temp %>%
  mutate(gi_score = (reg_exp / 2) + (health_exp / 2))

gi_w1['gi_exp'] <- rank_exp(gi_w1, gi_score)

gi_w1 <- gi_w1 %>% mutate(gi_rank = min_rank(gi_score), 
                          gi_decile = ntile(gi_score, 10))


write_csv(gi_w1, 'outputs/gi_basic_scores.csv')

