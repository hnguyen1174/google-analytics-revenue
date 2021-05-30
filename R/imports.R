#' @import dplyr
#' @importFrom stringr str_c
#' @importFrom jsonlite fromJSON
#' @importFrom tibble rowid_to_column as_tibble
#' @importFrom purrr map
#' @importFrom tidyr unnest
#' @importFrom tidyselect all_of
#' @importFrom lubridate ymd
#' @importFrom lightgbm lgb.train lgb.importance
#' @importFrom stats predict