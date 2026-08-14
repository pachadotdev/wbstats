#' @title Programmatic Access to Data and Statistics from the World Bank API
#'
#' @description Search and download data from the World Bank Data API. Includes
#'  support for mutliple languages, access to annual, quarterly, and monthly
#'  data.
#'
#' @importFrom data.table as.data.table data.table dcast rbindlist set `.SD` `:=`
#' @importFrom httr content http_error http_status http_type modify_url RETRY timeout user_agent
#' @importFrom jsonlite fromJSON
#' @importFrom utils type.convert
#'
#' @name wbstats
"_PACKAGE"
