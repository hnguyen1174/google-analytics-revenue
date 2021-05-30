#' Get Time Log
#'
#' @param df dataframe for processing
#' @param k the kth window
#' @param type log type (start of end)
#'
#' @return time bound for logging
get_time_log <- function(df, k, type = 'start') {
  
  min_date <- min(df$date)
  num_days_partition <- 168
  min_bound <- min_date + num_days_partition * (k - 1)
  max_bound <- min_date + num_days_partition * k
  
  if (type == 'start') {
    min_bound
  } else if (type == 'end') {
    max_bound
  }
}