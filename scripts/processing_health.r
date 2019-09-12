
library(sf)
library(tidyverse)
library(tmap)
library(ggplot2)

# DATA IN  -------------------------------------------------------------------->

# all prevelance data - 149,100 rows
prev_all <- read_csv('data_health/qof-1718-csv/PREVALENCE.csv')
# all GP surgery data - 806,289 rows
surg_all <- read_csv('data_health/gp_LSOA/2018/gp-reg-pat-prac-lsoa-all.csv')
# organisation reference lookup, filter to just practices in London, check distinct
org_ref_lon <- read_csv('data_health/qof-1718-csv/ORGANISATION_REFERENCE.csv') %>%
  filter(REGION_NAME == 'LONDON') %>%
  select(PRACTICE_CODE, REGION_NAME)

# London LSOA sf
lsoa_lon_sf <- st_read('../initial/data_georef/london/london.shp')
lsoa_lon <- lsoa_lon_sf %>% st_set_geometry(NULL)

# read in population data
pop <- read_csv('data_health/population_age_lsoa/population_age_lsoa.csv')


# FILTER   -------------------------------------------------------------------->

# filter prevelance data to depression and dementia - 14,200 rows
prev <- prev_all %>% filter(INDICATOR_GROUP_CODE %in% c('DEP', 'DEM', 'CVDPP', 'OB'))
nrow(prev)

# join prevelance to org lookup to restrict to just London practices - 1,286 unique GP surgeries
# some surgeries have NA in register count, so replace with 0
prev_lon <- inner_join(prev, org_ref_lon, by = "PRACTICE_CODE") %>%
  mutate(REGISTER = replace_na(REGISTER, 0))

head(prev_lon, 10)
distinct(prev_lon, INDICATOR_GROUP_CODE, PATIENT_LIST_TYPE)
nrow(prev_lon)
nrow(distinct(prev_lon, PRACTICE_CODE))

# Create table of total patient list size per London GP surgery - 1,286 surgeries in London
lon_tot_gp_pat_count <- prev_lon %>% filter(PATIENT_LIST_TYPE == 'TOTAL') %>%
  select(PRACTICE_CODE, PATIENT_LIST_SIZE) %>%
  filter()

nrow(lon_tot_gp_pat_count)


# restrict surgery > LSOA lookup to just London GP surgeries by inner joining to my London surgeries, 
# then create field proportion of patients in each LSOA
surg_lon <- inner_join(surg_all, lon_tot_gp_pat_count, by = 'PRACTICE_CODE') %>%
  select(-c(PUBLICATION, EXTRACT_DATE, PRACTICE_NAME, SEX), LSOA_PATIENT_COUNT = 'Number of Patients') %>%
  mutate(LSOA_PATIENT_PROP = LSOA_PATIENT_COUNT / PATIENT_LIST_SIZE)

head(surg_lon, 10)
nrow(surg_lon)

# check that the number of patients across LSOA from the distribution table adds up to the patient size list from QOF data
count_comparison <- surg_lon %>% 
  group_by(PRACTICE_CODE) %>%
  summarise(lsoa_pat = sum(LSOA_PATIENT_COUNT), qof_pat = max(PATIENT_LIST_SIZE), prop_sum = sum(LSOA_PATIENT_PROP)) %>%
  mutate(dif = lsoa_pat - qof_pat)

head(count_comparison, 10)

# correct 4,835 LSOAs present, with 1,281 surgeries in total (we seem to have lost 5 from the pure prevelance data)
print(paste('number of LSOAs in London surgery data:', nrow(distinct(surg_lon, LSOA_CODE))))
print(paste('number of GP surgerys in London:', nrow(distinct(surg_lon, PRACTICE_CODE))))

# still too many LSOAs in the data, so need to join to just London LSOAs
surg_lon_fin <- surg_lon %>% inner_join(lsoa_lon, by = c('LSOA_CODE' = 'LSOA11CD'))

# check counts again:
print(paste('number of LSOAs in London surgery data:', nrow(distinct(surg_lon_fin, LSOA_CODE))))
print(paste('number of GP surgerys in London:', nrow(distinct(surg_lon_fin, PRACTICE_CODE))))

# check how many LSOAs there are for each GP surgery, and the max no. of patients in any LSOA for each surgery
surg_lsoa_count <- surg_lon_fin %>% group_by(PRACTICE_CODE) %>% 
  summarise(n_lsoa = n(), max_pat = max(LSOA_PATIENT_COUNT))

head(surg_lsoa_count, 10)

# check how many surgeries and patients per LSOA
lsoa_surg_count <- surg_lon_fin %>% group_by(LSOA_CODE) %>% 
  summarise(practices = n(), patients = sum(LSOA_PATIENT_COUNT))


# Joining all info together, and create field for proportion of each practice's prevalence counts represented in each LSOA
prev_lon_lsoa <- inner_join(prev_lon, surg_lon_fin, by = 'PRACTICE_CODE') %>%
  mutate(INDICATOR_LSOA_COUNT = REGISTER * LSOA_PATIENT_PROP)

# check counts again:
print(paste('number of LSOAs in London surgery data:', nrow(distinct(prev_lon_lsoa, LSOA_CODE))))
print(paste('number of GP surgerys in London:', nrow(distinct(prev_lon, PRACTICE_CODE))))

head(prev_lon_lsoa, 10)


# FINAL COUNTS PER LSOA, group by LSOA and indicator and sum the count for each LSOA
lsoa_prev <- prev_lon_lsoa %>% group_by(LSOA_CODE, INDICATOR_GROUP_CODE) %>%
  summarise(INDICATOR_COUNT = sum(INDICATOR_LSOA_COUNT)) 

head(lsoa_prev, 10)
print(paste('number of LSOAs in final prev counts:', nrow(distinct(lsoa_prev, LSOA_CODE))))
print(paste('number of NAs in final prev indicator count:', nrow(filter(lsoa_prev, is.na(INDICATOR_COUNT)))))


# POPULATION COUNTS  -------------------------------------------------------------------->

# In order to standardise the number of patients in each LSOA, we need to know the population of the age band they were meaured from
# DEM - TOTAL
# DEP - 18OV
# CVDPP - 30_74
# OB - 18OV

# population for London LSOAS
pop_lon <- pop %>% rename(LSOA11CD = 'Area Codes', LSOA_POP = 'All Ages') %>%
  inner_join(lsoa_lon, by = 'LSOA11CD')

nrow(pop_lon)

ggplot(data = pop_lon, aes(LSOA_POP)) + geom_histogram()

# total pop
pop_lon_dem <- pop_lon %>% select(LSOA11CD, LSOA_POP) %>%
  mutate(INDICATOR_GROUP_CODE = 'DEM', AGE_BAND = 'TOTAL') %>%
  select(LSOA11CD, INDICATOR_GROUP_CODE, AGE_BAND, LSOA_POP)

head(pop_lon_dem, 10)

# age pops for dep ages
pop_lon_dep <- pop_lon %>% select(LSOA11CD, '18':'90+') %>%
  mutate(INDICATOR_GROUP_CODE = 'DEP', AGE_BAND = '18OV') %>%
  gather('18':'90+', key = 'AGE', value = 'POP') %>%
  group_by(LSOA11CD, INDICATOR_GROUP_CODE, AGE_BAND) %>%
  summarise(LSOA_POP = sum(POP))

head(pop_lon_dep, 10)

# age pops for cvt ages
pop_lon_cvt <- pop_lon %>% select(LSOA11CD, '30':'74') %>%
  mutate(INDICATOR_GROUP_CODE = 'CVDPP', AGE_BAND = '30_74') %>%
  gather('30':'74', key = 'AGE', value = 'POP') %>%
  group_by(LSOA11CD, INDICATOR_GROUP_CODE, AGE_BAND) %>%
  summarise(LSOA_POP = sum(POP))

head(pop_lon_cvt, 10)

# age pops for OB ages
pop_lon_ob <- pop_lon %>% select(LSOA11CD, '18':'90+') %>%
  mutate(INDICATOR_GROUP_CODE = 'OB', AGE_BAND = '18OV') %>%
  gather('18':'90+', key = 'AGE', value = 'POP') %>%
  group_by(LSOA11CD, INDICATOR_GROUP_CODE, AGE_BAND) %>%
  summarise(LSOA_POP = sum(POP))

head(pop_lon_ob, 10)

# combine into one narrow table of pop counts per indicator list per LSOA 
pop_lon_inds <- plyr::rbind.fill(pop_lon_dep, pop_lon_dem, pop_lon_cvt, pop_lon_ob)

head(pop_lon_inds, 10)
nrow(pop_lon_inds)
nrow(distinct(pop_lon_inds, LSOA11CD))

# check table looks correct for each indicator
pop_lon_inds %>% group_by(INDICATOR_GROUP_CODE, AGE_BAND) %>%
  summarise(count_lsoa = n(), mean_pop = mean(LSOA_POP), max_pop = max(LSOA_POP), min_pop = min(LSOA_POP))


# % POPULATION CALCS  -------------------------------------------------------------------->

# Now we have lsoa pop for each list type age band we can turn our prevalence counts per lsoa to % of pop per LSOA

# left join prevelance data to population by LSOA and the indicator
lsoa_prev_pop <- lsoa_prev %>% left_join(pop_lon_inds, by = c('LSOA_CODE' = 'LSOA11CD', 'INDICATOR_GROUP_CODE' = 'INDICATOR_GROUP_CODE'))

head(lsoa_prev_pop, 10)
sum(is.na(lsoa_prev_pop))

lsoa_prev_pop$INDICATOR_PERC <- lsoa_prev_pop$INDICATOR_COUNT / lsoa_prev_pop$LSOA_POP

# write_csv(lsoa_prev_pop, 'data_health/lon_lsoa_prev_and_pop_narrow2_wOB.csv')
lsoa_prev_pop <- read_csv('data_health/lon_lsoa_prev_and_pop_narrow2_wOB.csv')

# create wide version using spread
lsoa_prev_wide <- lsoa_prev_pop %>% 
  select(LSOA_CODE, INDICATOR_GROUP_CODE, INDICATOR_PERC) %>%
  spread(key = INDICATOR_GROUP_CODE, value = INDICATOR_PERC)

head(lsoa_prev_wide, 10)
sum(is.na(lsoa_prev_wide))
nrow(lsoa_prev_wide)
nrow(distinct(lsoa_prev_wide))

write_csv(lsoa_prev_wide, 'data_health/lon_lsoa_ind_prevalence_percentage_of_pop2_wOB.csv')
