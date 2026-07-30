#' Summarize Data Coverage for World Bank Indicators
#'
#' Given a `data.table`/`data.frame` as returned by [wb_data()], this function
#' reports, for each group defined by `by`, the percentage of non-missing
#' (non-`NA`) observations available per indicator. This is useful for
#' quickly comparing data coverage across countries or over time for a set
#' of indicators, without having to download each indicator separately and
#' calculate coverage manually.
#'
#' @param data A `data.table`/`data.frame` as returned by [wb_data()], in
#' either wide format (default) or long format (`return_wide = FALSE`)
#' @param by Character vector of column names in `data` to group by. Default
#' is `c("iso2c", "iso3c", "country")`, which reports, for each location, the
#' % of dates with non-missing data for each indicator. Pass `"date"` instead
#' to report, for each date, the % of locations with non-missing data for
#' each indicator
#'
#' @return A `data.table` with one row per group in `by`, and one column per
#' indicator giving the percentage (0-100) of non-missing values within that
#' group
#'
#' @md
#' @export
#'
#' @examples
#' \dontrun{
#' my_indicators <- c(
#'   life_exp   = "SP.DYN.LE00.IN",
#'   gdp_capita = "NY.GDP.PCAP.CD",
#'   pop        = "SP.POP.TOTL"
#' )
#'
#' d <- wb_data(my_indicators, start_date = 2000, end_date = 2020)
#'
#' # % of years (2000-2020) with data, per country, per indicator
#' wb_data_coverage(d)
#'
#' # % of countries with data, per year, per indicator
#' wb_data_coverage(d, by = "date")
#' }
wb_data_coverage <- function(data, by = c("iso2c", "iso3c", "country")) {
  if (!is.data.frame(data)) stop("data must be a data.frame/data.table, such as the result of wb_data()")

  by <- by[by %in% names(data)]
  if (length(by) == 0) stop("None of the columns in 'by' were found in 'data'")

  pct_complete <- function(x) round(100 * mean(!is.na(x)), 1)

  if (all(c("indicator_id", "value") %in% names(data))) {
    # long format: one row per location/indicator/date, so first summarize
    # by indicator_id, then reshape so each indicator gets its own column
    out <- data[, list(pct_complete = pct_complete(.SD[["value"]])), by = c(by, "indicator_id")]
    out <- dcast(out, ... ~ indicator_id, value.var = "pct_complete")
  } else {
    exclude_cols <- c("iso2c", "iso3c", "country", "date",
                      "unit", "obs_status", "footnote", "last_updated", "obs_resolution")
    value_cols <- setdiff(names(data), c(by, exclude_cols))

    if (length(value_cols) == 0) stop("No indicator columns were found to summarize coverage for")

    out <- data[, lapply(.SD, pct_complete), by = by, .SDcols = value_cols]
  }

  out
}
