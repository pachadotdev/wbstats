# Builds the canonical indicator list used by the data-coverage workflow and
# splits it into contiguous shards (e.g. 1-100, 101-200, ...) for the GitHub
# Actions matrix strategy in .github/workflows/data-coverage.yaml. Every
# matrix job downloads this same list as an artifact so all shards agree on
# indexing, then processes only its own [start, end] range.

library(wbstats)
library(jsonlite)

chunk_size <- as.integer(Sys.getenv("WB_CHUNK_SIZE", unset = "100"))

indicators <- wb_indicators()$indicator_id
saveRDS(indicators, "dev/indicators.rds")

n <- length(indicators)
starts <- seq(1L, n, by = chunk_size)
ends <- pmin(starts + chunk_size - 1L, n)

shards <- Map(function(s, e) list(start = s, end = e), starts, ends)
names(shards) <- NULL

matrix_json <- toJSON(shards, auto_unbox = TRUE)
message(sprintf("%d indicators split into %d shard(s) of up to %d", n, length(shards), chunk_size))

gh_output <- Sys.getenv("GITHUB_OUTPUT")
if (nzchar(gh_output)) {
    cat(sprintf("matrix=%s\n", matrix_json), file = gh_output, append = TRUE)
}
