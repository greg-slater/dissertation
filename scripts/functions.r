
# EXPONENTIAL TRANSFORMATION AND RANKING

# exponential transformation function
exp_trans <- function(var){
  -23 * log(1 - (var * (1 - (exp(-100/23)))))
}

# function to rank and exponentially transform a variable in a given table
rank_exp <- function(df, var){
  
  var <- enquo(var)
  # select relevant data from df
  data <- select(df, LSOA11CD, !! var)
  # create a ranking, rescale to 0-1, then apply exponential transformation
  data %>%
    mutate(rank = min_rank(!! var),
           rank_s = scales::rescale(rank, to = c(0, 1)),
           exp = exp_trans(rank_s)) %>%
    select(exp)
}


# DIRICHLET WEIGHT SAMPLES

# move last item from a list back n positions
lCycle <- function(x, n = 1) {
  if (n == 0) x else c(tail(x, -n), head(x, n))
}

# this function creates a table of nsamples from the dirichlet distribution for nweights (no. of indicators)
# each of the nweights will be treated with the alpha values in turn, while the others remain at 1
dirSampleSpread <- function(alpha_vals, nsamples, nweights){
  
  out <- data.frame()
  # loop through alpha values
  for (a in seq(1, length(alpha_vals))){
    # create a list of 1 for each weight, with the current alpha value at the end
    weights <- c(rep(1, (nweights - 1)), alpha_vals[a])

    for (w in seq(0, nweights - 1)){
      
      # cycle the weight list so that each weight gets sampled with the current alpha treatment
      w_list <- lCycle(weights, w)
      # create dirichlet samples and turn to data frame
      weight_samples_m <- rdirichlet(nsamples, w_list)
      weight_samples <- as.data.frame(weight_samples_m)
      # rename weight variables and then store alpha value
      names(weight_samples) <- paste('w', seq(1, nweights), sep = '')
      # weight_samples$alpha <- paste('alpha = ', alpha_vals[a])
      weight_samples$alpha <-alpha_vals[a]
      weight_samples$w_focus <- nweights - w
      
      # # bind to output table
      out <- rbind(out, weight_samples)
    }
  }
  out
}