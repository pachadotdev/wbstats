# ============================
# THIS IS VERY IMPORTANT:
# DON'T RUN THIS FROM A LAPTOP
# ============================

# There is no way to query the number of observations and the minimum and
# maximum year a value is available by indicator and country with the World
# Bank API. This offers a workaround by downloading each indicator (variable)
# and creating a summary for it, then committing it as one JSON file per
# indicator directly to the `data-coverage` branch of this repository.
#
# This script is one shard of a GitHub Actions matrix job (see
# .github/workflows/data-coverage.yaml): the `prepare` job builds the full
# indicator list (dev/indicators.rds) and splits it into ranges, and each
# matrix job runs this script with WB_SHARD_START/WB_SHARD_END set to its
# 1-based, inclusive slice of that list. Each shard:
#   - branches off `data-coverage` into its OWN branch
#     (data-coverage-shard-<start>-<end>), checked out into a git worktree so
#     it doesn't disturb the main checkout the R package was installed from.
#     Every shard owning a distinct branch means there's no contention/retries
#     when pushing, even with ~200 shards running in parallel.
#   - writes one JSON file per indicator, skipping any whose content is
#     identical to what's already committed on `data-coverage`,
#   - commits and (force-)pushes every 10 indicators (batch_size) to its own
#     shard branch.
# A separate `merge-shards` job (run after all shards finish) then merges
# every shard branch into `data-coverage` one at a time, so that merge step
# never has concurrent pushes to contend with either.

# Already installed in data-coverage.yaml
library(data.table)
library(wbstats)
library(jsonlite)

base_branch <- "data-coverage"
worktree_dir <- "data-coverage-checkout"
batch_size <- 10

pct_complete <- function(x) round(100 * mean(!is.na(x)), 1)

# --- this shard's indicators -------------------------------------------------
indicators <- readRDS("dev/indicators.rds")

start <- as.integer(Sys.getenv("WB_SHARD_START", unset = "1"))
end <- as.integer(Sys.getenv("WB_SHARD_END", unset = as.character(length(indicators))))
end <- min(end, length(indicators))
indicators <- indicators[start:end]

n <- length(indicators)

branch <- sprintf("data-coverage-shard-%d-%d", start, end)

# --- branch off `data-coverage` into this shard's own branch, into its own
# worktree, sharing the credentials actions/checkout already configured for
# `origin` in the main checkout -----------------------------------------------
system2("git", c("fetch", "origin", base_branch))
system2("git", c("worktree", "add", "-B", branch, worktree_dir, paste0("origin/", base_branch)))
system2("git", c("-C", worktree_dir, "config", "user.email", "action@github.com"))
system2("git", c("-C", worktree_dir, "config", "user.name", "GitHub Action"))

# this shard is the only writer of its own branch, so a plain (force) push
# with a couple of retries for transient network errors is enough - no
# pull/rebase dance needed
git_push <- function(tries = 3) {
    for (i in seq_len(tries)) {
        ok <- system2("git", c("-C", worktree_dir, "push", "--force", "origin", paste0("HEAD:", branch))) == 0
        if (ok) {
            return(invisible(TRUE))
        }
        message("  push failed, retrying...")
        Sys.sleep(5)
    }
    stop("failed to push to ", branch, " after ", tries, " tries")
}

commit_batch <- function(batch_indicators) {
    changed <- system2("git", c("-C", worktree_dir, "status", "--porcelain"), stdout = TRUE)
    if (length(changed) == 0) {
        message("  no changes in this batch, skipping commit")
        return(invisible(FALSE))
    }

    system2("git", c("-C", worktree_dir, "add", "-A"))
    msg <- sprintf(
        "%s to %s +%s",
        batch_indicators[1],
        batch_indicators[length(batch_indicators)],
        format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    )
    system2("git", c("-C", worktree_dir, "commit", "-q", "-m", shQuote(msg)))
    git_push()
    invisible(TRUE)
}

batch_indicators <- character(0)

for (i in seq_along(indicators)) {
    ind <- indicators[i]
    message(sprintf("[%d/%d] %s", i, n, ind))

    # a single indicator failing to download/summarize (network hiccup, no
    # data available, etc.) should not abort the whole run
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
        outfile <- file.path(worktree_dir, paste0(ind, ".json"))
        new_json <- as.character(toJSON(out, dataframe = "rows", auto_unbox = TRUE))

        # skip files whose content is identical to what's already committed,
        # so batches only ever contain indicators that actually changed. No
        # trailing newline is written, so the round-trip comparison is exact.
        old_json <- if (file.exists(outfile)) readChar(outfile, file.info(outfile)$size, useBytes = TRUE) else NA_character_
        if (identical(old_json, new_json)) {
            message("  unchanged, skipping")
        } else {
            writeLines(new_json, outfile, sep = "", useBytes = TRUE)
        }
    }

    batch_indicators <- c(batch_indicators, ind)

    if (length(batch_indicators) >= batch_size || i == n) {
        commit_batch(batch_indicators)
        batch_indicators <- character(0)
    }
}
