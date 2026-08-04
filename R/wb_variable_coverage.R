#' Summarize Data Coverage for World Bank Indicators
#'
#' Given a variable available from the World Bank API, this functions returns a
#' pre-computed summary stored on GitHub and not available from the API that
#' shows the percentage of non-missing (non-`NA`) observations available per
#' variable for every country, the year range per country, and the total number
#' of observations per country. This is useful before downloading the actual
#' indicators.
#'
#' @param variable A character string (e.g., `"SP.DYN.LE00.IN"`).
#' @return A `data.table` with one row per country.
#'
#' @md
#' @export
#'
#' @examples
#' \dontrun{
# ' my_indicators <- c(
# '   life_exp   = "SP.DYN.LE00.IN",
# '   gdp_capita = "NY.GDP.PCAP.CD",
# '   pop        = "SP.POP.TOTL"
# ' )
#'
#' # summary for each variable
#' wb_variable_coverage(d)
#' }
wb_variable_coverage <- function(variable) {
  out <- lapply(variable,
    function(v) {
      d <- fromJSON(sprintf("https://raw.githubusercontent.com/pachadotdev/wbstats/refs/heads/data-coverage/%s.json", v))
      d$variable <- v
      d
    }
  )

  rbindlist(out)
}
