#' Summarize Data Coverage for World Bank Indicators
#'
#' Given a indicator available from the World Bank API, this functions returns a
#' pre-computed summary stored on GitHub and not available from the API that
#' shows the percentage of non-missing (non-`NA`) observations for every
#' country, the year range per country, and the total number of observations per
#' country. This is useful before downloading a dataset.
#'
#' @param indicator A character string (e.g., `"SP.DYN.LE00.IN"`).
#' @return A `data.table` with one row per country.
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
#' # summary for each indicator
#' wb_indicator_coverage(my_indicators)
#' }
wb_indicator_coverage <- function(indicator) {
  indicators <- wbstats::wb_indicators()$indicator_id
  out <- lapply(indicator,
    function(ind) {
      stopifnot(any(ind %in% indicators))
      d <- fromJSON(sprintf("https://raw.githubusercontent.com/pachadotdev/wbstats/refs/heads/data-coverage/%s.json", ind))
      d$indicator <- ind
      d
    }
  )

  rbindlist(out)
}
