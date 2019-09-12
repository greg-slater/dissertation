
library(tidyverse)
library(ggplot2)
library(sf)
library(sp)
library(spdep)
library(tmap)
library(gridExtra)

# script to carry out shrinkage estimation using local empirical bayes
# with three differentneighbourhood definitions for each lsoa. All
# results stored, which can then be used in uncertainty and sensitivity tests

# DATA IN  -------------------------------------------------------------------->

# London LSOA data - 4,835 rows
lsoa_lon_sf <- st_read('../initial/data_georef/london/london.shp')
lsoa_lon <- lsoa_lon_sf %>% st_set_geometry(NULL)


lad_sf <- st_read('../london_boundaries/London_Borough_Excluding_MHW.shp') %>%
  st_transform(27700)

prev_all <- read_csv('../initial/data_health/lon_lsoa_prev_and_pop_narrow2_wOB.csv') 

# join all prev data to london sf, this new sf will contain 4 records per LSOA
lon_all_sf <- lsoa_lon_sf %>% left_join(prev_all, by = c('LSOA11CD' = 'LSOA_CODE'))



# SPATIAL WEIGHTS -------------------------------------------------------------------->

lsoa_lon_sp <- as(lsoa_lon_sf, 'Spatial')

# Create QUEENS weights matrix
nb_queens <- poly2nb(lsoa_lon_sp, queen=TRUE)

# plot distribution of number of neighbours for each LSOA
nb_queen_tally <- tibble(n_neighbours = card(nb_queens))

# Create K-N weights matrix
# input fields
coords <- coordinates(lsoa_lon_sp)
ids <- row.names(as(lsoa_lon_sp, 'data.frame'))

# calculate k nearest neighbours
nb_kn10 <- knn2nb(knearneigh(coords, k = 10), row.names = ids)


# tally and plot for k10
nb_kn10_tally <- tibble(n_neighbours = card(nb_kn10)) %>% group_by(n_neighbours) %>% summarise(count = n())


# calculate BLOCK weight matrix based on LAD membership
nb_lad <- read.gal('lon_lad_blocks.gal', override.id = TRUE) 
nb_lad_tally <- tibble(n_neighbours = card(nb_lad))


# EMPIRICAL BAYES -------------------------------------------------------------------->

# list of indicators for loop
indicators <- c('CVDPP', 'DEM', 'DEP', 'OB')
# empty table to load results into
eb_results <- tibble()

for (i in seq(1, 4)){
  
  print(paste('Running Empirical Bayes Smoothing for indicator', indicators[i]))
  
  # filter sf to just current indicator
  lon_sf <- filter(lon_all_sf, INDICATOR_GROUP_CODE == indicators[i])
  # create sp from the london sf
  lon_sp <- as(lon_sf, 'Spatial')
  # run local empirical bayes for each weight matrix
  eb_queens <- EBlocal(lon_sp$INDICATOR_COUNT, lon_sp$LSOA_POP, nb_queens)
  eb_kn10 <- EBlocal(lon_sp$INDICATOR_COUNT, lon_sp$LSOA_POP, nb_kn10)
  eb_lad <- EBlocal(lon_sp$INDICATOR_COUNT, lon_sp$LSOA_POP, nb_lad)
  # load outputs from each to table, also just calculating basic rate 
  q <- tibble(LSOA11CD = lon_sf$LSOA11CD, INDICATOR_GROUP_CODE = indicators[i], METHOD = 'QUEENS', rate = eb_queens$est)
  k <- tibble(LSOA11CD = lon_sf$LSOA11CD, INDICATOR_GROUP_CODE = indicators[i], METHOD = 'KN-10', rate = eb_kn10$est)
  l <- tibble(LSOA11CD = lon_sf$LSOA11CD, INDICATOR_GROUP_CODE = indicators[i], METHOD = 'LAD', rate = eb_lad$est)
  # bind all into one table
  out <- plyr::rbind.fill(q, k, l)
  # bind to final results table
  eb_results <- rbind(eb_results, out)
}

# check all results loaded, and distinct
count(eb_results, INDICATOR_GROUP_CODE, METHOD)
nrow(eb_results)
nrow(distinct(eb_results))
head(eb_results)

# calculate basic rate from prev table and load into results too
basic_rate <- tibble(LSOA11CD = prev_all$LSOA_CODE, INDICATOR_GROUP_CODE = prev_all$INDICATOR_GROUP_CODE,
                     METHOD = 'BASIC', rate = prev_all$INDICATOR_COUNT / prev_all$LSOA_POP)

eb_results <- rbind(eb_results, basic_rate)

# check distribution of results across ind and method
results_check <- eb_results %>% group_by(INDICATOR_GROUP_CODE, METHOD_F) %>%
  summarise(count = n(), min = min(rate), max = max(rate), mean = mean(rate), sd = sd(rate))

results_check

write_csv(eb_results, 'lsoa_health_shrunk_scores_all_final.csv')
