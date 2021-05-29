#' Flatten JSON
#' 
#' This function flattens a json like objects
#' into named vectors
#'
#' @param x a json-like object
#'
#' @return a named vector
flatten_json <- function(x) {
  
  str_c(x, collapse = ',') %>% 
    str_c('[', ., ']') %>% 
    fromJSON(flatten = T)
} 

#' Prepare columns for data
#'
#' @param package name of package
#'
#' @return column names to choose
prep_cols <- function(package = 'GglAnalyticsRev') {
  file <- system.file('cols_to_choose.rds', package = package)
  readRDS(file)
}

#' Process Google Analytics Data
#'
#' @param raw_data raw Google Analytics data
#' @param cols_to_choose columns to choose
#'
#' @return processed Google Analytics data
#' @export
prc_ggl_data <- function(raw_data, cols_to_choose = prep_cols()) {
  
  processed_data <- raw_data %>% 
    
    # Remove faulty line
    head(-1) %>% 
    rowid_to_column() %>% 
    dplyr::rename(index = rowid) %>% 
    as_tibble() %>% 
    
    # Flatten json-like columns
    mutate(device_prc = map(device, flatten_json)) %>% 
    unnest(device_prc) %>% 
    mutate(geoNetwork_prc = map(geoNetwork, flatten_json)) %>% 
    unnest(geoNetwork_prc) %>% 
    mutate(trafficSource_prc = map(trafficSource, flatten_json)) %>% 
    unnest(trafficSource_prc) %>% 
    mutate(totals_prc = map(totals, flatten_json)) %>% 
    unnest(totals_prc) %>% 
    
    # Remove origin json-like columns
    select(-device, -trafficSource, -totals) %>% 
    select(all_of(cols_to_choose)) %>% 
    mutate(date = ymd(date)) %>% 
    mutate_at(vars(18:26, 31), as.integer) %>% 
    mutate(transactionRevenue = ifelse(is.na(transactionRevenue), 0, transactionRevenue))
  
  processed_data
}