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

#' Prepare Partitioned Train Sets
#'
#' @param df data for partitioning
#' @param k the kth partition
#'
#' @return the kth processed training partition
#' @export
prep_partition_train <- function(df, k) {
  
  min_date <- min(df$date)
  num_days_partition <- 168
  min_bound <- min_date + num_days_partition * (k - 1)
  max_bound <- min_date + num_days_partition * k
  
  # Partition dataframe
  patition_df <- df %>% 
    filter(date >= min_bound, date < max_bound)
  
  return_visitor_id <- df %>% 
    filter(date >= max_bound + 46, date < max_bound + 46 + 62) %>% 
    pull(fullVisitorId) %>% 
    unique()
  
  return_visitor_paritioned_df <- patition_df %>% 
    filter(fullVisitorId %in% return_visitor_id)
  
  return_visitor_full_df <- df %>% 
    filter(fullVisitorId %in% return_visitor_paritioned_df$fullVisitorId,
           date >= max_bound + 46, 
           date < max_bound + 46 + 62)
  
  return_visitor_df <- patition_df %>% 
    group_by(fullVisitorId) %>% 
    summarize(target = log(1 + sum(transactionRevenue))) %>% 
    mutate(ret = 1)
  
  nonreturn_visitor_df <- tibble(
    fullVisitorId = patition_df %>% 
      filter(!fullVisitorId %in% return_visitor_id) %>% 
      pull(fullVisitorId) %>% unique(),
    target = 0, 
    ret = 0
  )
  
  partitioned_train <- return_visitor_df %>% 
    bind_rows(nonreturn_visitor_df)
  
  patition_user_info <- patition_df %>% 
    group_by(fullVisitorId) %>%
    summarize(
      channelGrouping = max(ifelse(is.na(channelGrouping), -9999, channelGrouping)),
      first_ses_from_the_period_start = min(date) - min_bound,
      last_ses_from_the_period_end = max_bound - max(date),
      interval_dates = max(date) - min(date),
      unique_date_num = length(unique(date)),
      maxVisitNum = max(visitNumber, na.rm = TRUE),
      browser = max(ifelse(is.na(browser), -9999, browser)),
      operatingSystem = max(ifelse(is.na(operatingSystem), -9999, operatingSystem)),
      deviceCategory = max(ifelse(is.na(deviceCategory), -9999, deviceCategory)),
      continent = max(ifelse(is.na(continent), -9999, continent)),
      subContinent = max(ifelse(is.na(subContinent), -9999, subContinent)),
      country = max(ifelse(is.na(country), -9999, country)),
      region = max(ifelse(is.na(region), -9999, region)),
      metro = max(ifelse(is.na(metro), -9999, metro)),
      city = max(ifelse(is.na(city), -9999, city)),
      networkDomain = max(ifelse(is.na(networkDomain), -9999, networkDomain)),
      source = max(ifelse(is.na(source), -9999, source)),
      medium = max(ifelse(is.na(medium), -9999, medium)),
      isVideoAd_mean = mean(ifelse(is.na(adwordsClickInfo.isVideoAd), 0, 1)),
      isMobile = mean(ifelse(isMobile, 1 , 0)),
      isTrueDirect = mean(ifelse(is.na(isTrueDirect), 0, 1)),
      bounce_sessions = sum(ifelse(is.na(bounces), 0, 1)),
      hits_sum = sum(hits),
      hits_mean = mean(hits),
      hits_min = min(hits),
      hits_max = max(hits),
      hits_median = median(hits),
      hits_sd = sd(hits),
      pageviews_sum = sum(pageviews, na.rm = TRUE),
      pageviews_mean = mean(pageviews, na.rm = TRUE),
      pageviews_min = min(pageviews, na.rm = TRUE),
      pageviews_max = max(pageviews, na.rm = TRUE),
      pageviews_median = median(pageviews, na.rm = TRUE),
      pageviews_sd = sd(pageviews, na.rm = TRUE),
      session_cnt = nrow(visitStartTime),
      transactionRevenue = sum(transactionRevenue),
      transactions  = sum(transactions, na.rm = TRUE)
    )
  
  final_partition <- plyr::join(patition_df_by_users, target_df, by = 'fullVisitorId') %>% 
    as_tibble()
  
  final_partition
}

#' Process Paritioned Dataset
#'
#' @param df 
#'
#' @return
#' @export
#'
#' @examples
prc_partition_train <- function(df) {
  
  df_processed <- df %>% 
    group_by(fullVisitorId) %>%
    summarize(
      channelGrouping = max(ifelse(is.na(channelGrouping), -9999, channelGrouping)),
      first_ses_from_the_period_start = min(date) - min_bound,
      last_ses_from_the_period_end = max_bound - max(date),
      interval_dates = max(date) - min(date),
      unique_date_num = length(unique(date)),
      maxVisitNum = max(visitNumber, na.rm = TRUE),
      browser = max(ifelse(is.na(browser), -9999, browser)),
      operatingSystem = max(ifelse(is.na(operatingSystem), -9999, operatingSystem)),
      deviceCategory = max(ifelse(is.na(deviceCategory), -9999, deviceCategory)),
      continent = max(ifelse(is.na(continent), -9999, continent)),
      subContinent = max(ifelse(is.na(subContinent), -9999, subContinent)),
      country = max(ifelse(is.na(country), -9999, country)),
      region = max(ifelse(is.na(region), -9999, region)),
      metro = max(ifelse(is.na(metro), -9999, metro)),
      city = max(ifelse(is.na(city), -9999, city)),
      networkDomain = max(ifelse(is.na(networkDomain), -9999, networkDomain)),
      source = max(ifelse(is.na(source), -9999, source)),
      medium = max(ifelse(is.na(medium), -9999, medium)),
      isVideoAd_mean = mean(ifelse(is.na(adwordsClickInfo.isVideoAd), 0, 1)),
      isMobile = mean(ifelse(isMobile, 1 , 0)),
      isTrueDirect = mean(ifelse(is.na(isTrueDirect), 0, 1)),
      bounce_sessions = sum(ifelse(is.na(bounces), 0, 1)),
      hits_sum = sum(hits),
      hits_mean = mean(hits),
      hits_min = min(hits),
      hits_max = max(hits),
      hits_median = median(hits),
      hits_sd = sd(hits),
      pageviews_sum = sum(pageviews, na.rm = TRUE),
      pageviews_mean = mean(pageviews, na.rm = TRUE),
      pageviews_min = min(pageviews, na.rm = TRUE),
      pageviews_max = max(pageviews, na.rm = TRUE),
      pageviews_median = median(pageviews, na.rm = TRUE),
      pageviews_sd = sd(pageviews, na.rm = TRUE),
      session_cnt = nrow(visitStartTime),
      transactionRevenue = sum(transactionRevenue),
      transactions  = sum(transactions, na.rm = TRUE)
    )
  
  df_processed
}

