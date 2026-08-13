#' Summarize Data Coverage for World Bank Indicators
#'
#' Given a indicator available from the World Bank API, this functions returns a
#' pre-computed summary stored on GitHub and not available from the API that
#' shows the percentage of non-missing (non-`NA`) observations for every
#' country, the year range per country, and the total number of observations per
#' country. This is useful before downloading a dataset.
#'
#' @param pattern A character string or regular expression (e.g., `"GDP"`).
#'
#' @param country Character vector of country, region, or special value codes for the
#' locations you want to return data for. Permissible values can be found in the
#' countries data frame in [wb_cachelist] or by running [wb_countries()] directly.
#' Specifically, values listed in the following fields `iso3c`, `iso2c`, `country`,
#' `region`, `admin_region`, `income_level` and all of the `region_*`,
#' `admin_region_*`, `income_level_*`, columns. As well as the following special values
#' * `"countries_only"` (Default)
#' * `"regions_only"`
#' * `"admin_regions_only"`
#' * `"income_levels_only"`
#' * `"aggregates_only"`
#' * `"all"`
#'
#' @param start_date Numeric or character. If numeric it must be in `%Y` form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1". This also accepts a special value of "YTD", useful for more frequently
#'  updated subannual indicators.
#'
#' @param end_date Numeric or character. If numeric it must be in `%Y` form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1".
#'
#' @param cache List of data frames returned from [wb_cache()]. If omitted,
#' [wb_cachelist] is used
#'
#' @return A `data.table` with one row per country.
#'
#' @md
#' @export
#'
#' @examples
#' \dontrun{
#' wb_country_coverage("gross domestic product", c("Mexico", "Chile"), 2010, 2020)
#' }
wb_country_coverage <- function(pattern, country, start_date, end_date, cache) {
  if (missing(cache)) cache <- wbstats::wb_cachelist
  indicators <- cache$indicators
  indicators_j <- grep(pattern, indicators$indicator_desc, value = FALSE)
  indicators <- indicators[indicators_j, c("indicator_desc", "indicator_id")]

  country_param <- format_wb_country(country, cache = cache)
  country_param <- toupper(unlist(strsplit(country_param, split = ";")))

  out <- lapply(indicators$indicator_id,
    function(ind) {
      d <- tryCatch({
        fromJSON(sprintf("https://raw.githubusercontent.com/pachadotdev/wbstats/refs/heads/data-coverage/%s.json", ind))
      }, error = function(e) {
        message(sprintf("URL failed for %s. Error: %s", ind, e$message))
        NULL
      })

      if (is.null(d)) return(NULL)
      if (nrow(d) == 0L) return(NULL)

      d <- as.data.table(d)
      
      d <- d[iso3c %in% country_param]

      if (any("start_date" %in% colnames(d))) {
        d <- d[start_date >= from & end_date]
      }
      
      if (nrow(d) == 0) return(NULL)
      d[, indicator := ind]
      d
    }
  )

  rbindlist(out)
}
