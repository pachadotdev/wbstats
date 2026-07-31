#' Set the Value of a Missing Function Argument
#'
#' A simple wrapper around ifelse with the condition set to missing(x)
#'
#' @param x A function argument
#' @param true What to return if x is missing. Default is `NA`
#' @param false What to return if x is not missing. Default to return itself
#'
#' @noRd
if_missing <- function(x, true = NA, false = x) {
  ifelse(missing(x), true, false)
}

#' @noRd
unique_na <- function(x, na.rm = TRUE) {
  x_unique <- unique(x)
  if (na.rm) x_unique <- x_unique[!is.na(x_unique)]

  x_unique
}


#' @noRd
format_wb_dates <- function(df) {
  date_vec <- df$date
  new_date_vec <- as.Date(rep(NA, length(date_vec)))
  obs_resolution <- as.character(rep(NA, length(date_vec)))

  # annual ----------
  annual_obs_index <- grep("[M|Q]", date_vec, invert = TRUE, ignore.case = TRUE)

  if (length(annual_obs_index) > 0) {
    annual_date_values <- as.Date(paste0(date_vec[annual_obs_index], "-01-01"))

    new_date_vec[annual_obs_index] <- annual_date_values
    obs_resolution[annual_obs_index] <- "annual"
  }


  # monthly ----------
  monthly_obs_index <- grep("M", date_vec, ignore.case = TRUE)

  if (length(monthly_obs_index) > 0) {
    monthly_str <- date_vec[monthly_obs_index]
    monthly_year <- substr(monthly_str, 1, 4)
    monthly_month <- substr(monthly_str, 6, 7)
    monthly_date_values <- as.Date(paste0(monthly_year, "-", monthly_month, "-01"))

    new_date_vec[monthly_obs_index] <- monthly_date_values
    obs_resolution[monthly_obs_index] <- "monthly"
  }


  # quarterly ----------
  quarterly_obs_index <- grep("Q", date_vec, ignore.case = TRUE)

  if (length(quarterly_obs_index) > 0) {
    # takes a little more work
    qtr_obs <- strsplit(date_vec[quarterly_obs_index], "Q")
    qtr_year <- vapply(qtr_obs, `[`, character(1), 1)
    qtr_num <- as.numeric(vapply(qtr_obs, `[`, character(1), 2))
    qtr_start_month <- (qtr_num - 1) * 3 + 1 # first month of the quarter

    quarterly_date_values <- as.Date(paste0(qtr_year, "-", sprintf("%02d", qtr_start_month), "-01"))

    new_date_vec[quarterly_obs_index] <- quarterly_date_values
    obs_resolution[quarterly_obs_index] <- "quarterly"
  }

  df$date <- new_date_vec
  df$obs_resolution <- obs_resolution

  df
}
