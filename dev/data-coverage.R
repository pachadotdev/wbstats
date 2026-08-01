# There is no way to query the the number of observations and the minimum and maximum year a value
# is available by indicator and country with the World Bank API. This offers a workaround by
# downloading each indicator (variable) and creating a summary for it, to then upload it to the
# data-coverage branch in this repository as one JSON file per indicator. This script is run
# weekly and/or triggered manually via GitHub Actions like a cron task on Unix systems.

# DON'T RUN THIS FROM A LAPTOP

# Already installed in data-coverage.yaml
library(data.table)
library(wbstats)
library(jsonlite)

# JSON files are written here (not at the repo root) so the workflow can move
# just this directory over to the orphan `data-coverage` branch. There is no
# need to diff against previously published JSON in R: every file is always
# (re)written, and `git add`/`git commit` will only pick up the files whose
# content actually changed.
outdir <- "data-coverage-output"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

indicators <- wb_indicators()$indicator_id

pct_complete <- function(x) round(100 * mean(!is.na(x)), 1)

n <- length(indicators)

for (i in seq_along(indicators)) {
    ind <- indicators[i]
    message(sprintf("[%d/%d] %s", i, n, ind))

    # a single indicator failing to download/summarize (network hiccup, no
    # data available, etc.) should not abort the whole (multi hour) run
    out <- tryCatch(
        {
            d <- wb_data(ind)

            # one row per location/indicator => direct summary
            d[,
                list(
                    pct_complete = pct_complete(.SD[[ind]]),
                    from = min(.SD[["date"]]),
                    to = max(.SD[["date"]]),
                    nobs = sum(!is.na(.SD[[ind]]))
                ),
                by = c("iso2c", "iso3c", "country")
            ]
        },
        error = function(e) {
            message("  skipped: ", conditionMessage(e))
            NULL
        }
    )

    if (!is.null(out) && nrow(out) > 0) {
        write_json(out, file.path(outdir, paste0(ind, ".json")), dataframe = "rows", auto_unbox = TRUE)
    }
}
