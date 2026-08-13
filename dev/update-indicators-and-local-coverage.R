# There is no way to query the number of observations and the minimum and
# maximum year a value is available by indicator and country with the World
# Bank API. This offers a workaround by downloading each indicator (variable)
# and creating a summary for it, then committing it as one JSON file per
# indicator directly to the `data-coverage` branch of this repository.

# THIS SHOULD BE A PART OF THE OFFICIAL DOCUMENTATION
#
# https://dlthub.com/context/source/world-bank-indicators-api
#
# Resource	Endpoint	Method	Data selector	Description
# indicators	/v2/indicator	GET	[1]	Access to nearly 16,000 time series indicators
# countries	/v2/country/all	GET	[1]	All countries
# country_indicator	/v2/country/{country_id}/indicator/{indicator_id}	GET	[1]	Specific indicator for a country
# sources	/v2/source	GET	[1]	All data sources
# source_indicators	/v2/source/{source_id}/indicators	GET	[1]	Indicators for a specific source

library(data.table)
library(wbstats)
library(jsonlite)

pct_complete <- function(x) round(100 * mean(!is.na(x)), 1)

load("./data/wb_cachelist.rda")

class(wb_cachelist)
names(wb_cachelist)

# new cache ----

wb_cachelist_new <- list()

wb_cachelist_new$countries <- NULL
wb_cachelist_new$indicators <- NULL
wb_cachelist_new$sources <- NULL
wb_cachelist_new$topics <- NULL
wb_cachelist_new$regions <- NULL
wb_cachelist_new$income_levels <- NULL
wb_cachelist_new$lending_types <- NULL
wb_cachelist_new$languages <- NULL

# countries ----

# https://worldbank.github.io/template/notebooks/world-bank-api.html

url_countries <- "https://api.worldbank.org/v2/country?format=json&per_page=1000"

fout <- "./dev/countries_2060813.rds"

if (!file.exists(fout)) {
    countries_api <- fromJSON(url_countries)
    saveRDS(countries_api, fout)
} else {
    countries_api <- readRDS(fout)
}

cty <- countries_api[[2]]
cty <- jsonlite::flatten(cty, recursive = TRUE)

if (is.null(names(cty)) || any(names(cty) == "")) {
  names(cty) <- paste0("V", seq_along(cty))
}

wb_cachelist_new$countries <- as.data.table(cty)

colnames(wb_cachelist_new$countries)
colnames(wb_cachelist$countries)

str(wb_cachelist_new$countries[1, ])
str(wb_cachelist$countries[1, ])

setnames(wb_cachelist_new$countries, c("id", "iso2Code", "name", "capitalCity", "region.id", "region.iso2code",
    "region.value", "adminregion.id", "adminregion.iso2code", "adminregion.value", "incomeLevel.id", "incomeLevel.iso2code",
    "incomeLevel.value", "lendingType.id", "lendingType.iso2code", "lendingType.value"),
    c("iso3c", "iso2c", "country", "capital_city", "region_iso3c", "region_iso2c", "region", "admin_region_iso3c",
    "admin_region_iso2c", "admin_region", "income_level_iso3c", "income_level_iso2c", "income_level",
    "lending_type_iso3c", "lending_type_iso2c", "lending_type"))

wb_cachelist_new$countries[, admin_region_iso3c := fifelse(admin_region_iso3c == "", NA, admin_region_iso3c)]
wb_cachelist_new$countries[, admin_region_iso2c := fifelse(admin_region_iso2c == "", NA, admin_region_iso2c)]
wb_cachelist_new$countries[, admin_region := fifelse(admin_region == "", NA, admin_region)]

wb_cachelist_new$countries

# indicators ----

# per_page works, this was a dumb experiment but worked
url_indicators <- "https://api.worldbank.org/v2/indicators?format=json&per_page=30000"

fout <- "./dev/indicators_api_20260813.rds"

if (!file.exists(fout)) {
    indicators_api <- fromJSON(url_indicators)
    
    names(indicators_api)
    names(indicators_api)

    indicators_api[[2]]$id

    saveRDS(indicators_api, fout)
} else {
    indicators_api <- readRDS(fout)
}

names(indicators_api[[2]])

colnames(wb_cachelist$indicators)

ind <- indicators_api[[2]]
ind <- jsonlite::flatten(ind, recursive = TRUE)

if (is.null(names(ind)) || any(names(ind) == "")) {
  names(ind) <- paste0("V", seq_along(ind))
}

wb_cachelist_new$indicators <- as.data.table(ind)

colnames(wb_cachelist_new$indicators)
colnames(wb_cachelist$indicators)

str(wb_cachelist_new$indicators[1, ])
str(wb_cachelist$indicators[1, ])

setnames(wb_cachelist_new$indicators, c("id", "name", "sourceNote", "sourceOrganization", "source.id", "source.value"),
    c("indicator_id", "indicator", "indicator_desc", "source_org", "source_id", "source"))

wb_cachelist_new$indicators[, unit := fifelse(unit == "", NA, unit)]
wb_cachelist_new$indicators[, indicator_desc := fifelse(indicator_desc == "", NA, indicator_desc)]

# Replace empty nested data.frame cells in the `topics` list column with NA
wb_cachelist_new$indicators[, topics := lapply(topics, function(x) {
    if (is.data.frame(x) && ncol(x) == 0L) {
        NA
    } else {
        x
    }
})]

wb_cachelist_new$indicators

# source ----

length(unique(wb_cachelist_new$indicators$source))

url_sources <- "https://api.worldbank.org/v2/source?format=json&per_page=100"

fout <- "./dev/sources_2060813.rds"

if (!file.exists(fout)) {
    sources_api <- fromJSON(url_sources)
    saveRDS(sources_api, fout)
} else {
    sources_api <- readRDS(fout)
}

src <- sources_api[[2]]
src <- jsonlite::flatten(src, recursive = TRUE)

if (is.null(names(src)) || any(names(src) == "")) {
  names(src) <- paste0("V", seq_along(src))
}

wb_cachelist_new$sources <- as.data.table(src)

colnames(wb_cachelist_new$sources)
colnames(wb_cachelist$sources)

str(wb_cachelist_new$sources[1, ])
str(wb_cachelist$sources[1, ])

setnames(wb_cachelist_new$sources, c("id", "lastupdated", "name", "code", "description", "url", "dataavailability",
    "metadataavailability"),
    c("source_id", "last_updated", "source", "source_code", "source_desc", "source_url", "data_available", "metadata_available"))

wb_cachelist_new$sources[, source_desc := fifelse(source_desc == "", NA, source_desc)]
wb_cachelist_new$sources[, source_url := fifelse(source_url == "", NA, source_url)]

wb_cachelist_new$sources

# topics ----

nrow(wb_cachelist$topics)

# TODO: THIS ENDPOINT SHOULD BE DOCUMENTED
url_topics <- "https://api.worldbank.org/v2/topics?format=json&per_page=100"

fout <- "./dev/topics_2060813.rds"

if (!file.exists(fout)) {
    topics_api <- fromJSON(url_topics)
    saveRDS(topics_api, fout)
} else {
    topics_api <- readRDS(fout)
}

tps <- topics_api[[2]]
tps <- jsonlite::flatten(tps, recursive = TRUE)

if (is.null(names(tps)) || any(names(tps) == "")) {
  names(tps) <- paste0("V", seq_along(tps))
}

wb_cachelist_new$topics <- as.data.table(tps)

colnames(wb_cachelist_new$topics)
colnames(wb_cachelist$topics)

str(wb_cachelist_new$topics[1, ])
str(wb_cachelist$topics[1, ])

setnames(wb_cachelist_new$topics, c("id", "value", "sourceNote"), c("topic_id", "topic", "topic_desc"))

wb_cachelist_new$topics

# regions ----

nrow(wb_cachelist$regions)

# TODO: THIS ENDPOINT SHOULD BE DOCUMENTED
url_regions <- "https://api.worldbank.org/v2/regions?format=json&per_page=100"

fout <- "./dev/regions_2060813.rds"

if (!file.exists(fout)) {
    regions_api <- fromJSON(url_regions)
    saveRDS(regions_api, fout)
} else {
    regions_api <- readRDS(fout)
}

rgs <- regions_api[[2]]
rgs <- jsonlite::flatten(rgs, recursive = TRUE)

if (is.null(names(rgs)) || any(names(rgs) == "")) {
  names(rgs) <- paste0("V", seq_along(rgs))
}

wb_cachelist_new$regions <- as.data.table(rgs)

colnames(wb_cachelist_new$regions)
colnames(wb_cachelist$regions)

str(wb_cachelist_new$regions[1, ])
str(wb_cachelist$regions[1, ])

setnames(wb_cachelist_new$regions, c("id", "code", "iso2code", "name"), c("region_id", "iso3c", "iso2c", "region"))

wb_cachelist_new$regions

# income levels ----

nrow(wb_cachelist$income_levels)

# TODO: THIS ENDPOINT SHOULD BE DOCUMENTED
url_income_levels <- "https://api.worldbank.org/v2/incomelevel?format=json&per_page=10"

fout <- "./dev/income_levels_2060813.rds"

if (!file.exists(fout)) {
    income_levels_api <- fromJSON(url_income_levels)
    saveRDS(income_levels_api, fout)
} else {
    income_levels_api <- readRDS(fout)
}

ilv <- income_levels_api[[2]]
ilv <- jsonlite::flatten(ilv, recursive = TRUE)

if (is.null(names(ilv)) || any(names(ilv) == "")) {
  names(ilv) <- paste0("V", seq_along(ilv))
}

wb_cachelist_new$income_levels <- as.data.table(ilv)

colnames(wb_cachelist_new$income_levels)
colnames(wb_cachelist$income_levels)

str(wb_cachelist_new$income_levels[1, ])
str(wb_cachelist$income_levels[1, ])

setnames(wb_cachelist_new$income_levels, c("id", "iso2code", "value"), c("iso3c", "iso2c", "income_level"))

wb_cachelist_new$income_levels

# lending types ----

nrow(wb_cachelist$lending_types)

# TODO: THIS ENDPOINT SHOULD BE DOCUMENTED
url_lending_types <- "https://api.worldbank.org/v2/lendingtypes?format=json&per_page=10"

fout <- "./dev/lending_types_2060813.rds"

if (!file.exists(fout)) {
    lending_types_api <- fromJSON(url_lending_types)
    saveRDS(lending_types_api, fout)
} else {
    lending_types_api <- readRDS(fout)
}

ltp <- lending_types_api[[2]]
ltp <- jsonlite::flatten(ltp, recursive = TRUE)

if (is.null(names(ltp)) || any(names(ltp) == "")) {
  names(ltp) <- paste0("V", seq_along(ltp))
}

wb_cachelist_new$lending_types <- as.data.table(ltp)

colnames(wb_cachelist_new$lending_types)
colnames(wb_cachelist$lending_types)

str(wb_cachelist_new$lending_types[1, ])
str(wb_cachelist$lending_types[1, ])

setnames(wb_cachelist_new$lending_types, c("id", "iso2code", "value"), c("iso3c", "iso2c", "lending_type"))

wb_cachelist_new$lending_types

# languages ----

nrow(wb_cachelist$languages)

# TODO: THIS ENDPOINT SHOULD BE DOCUMENTED
url_languages <- "https://api.worldbank.org/v2/languages?format=json&per_page=100"

fout <- "./dev/languages_2060813.rds"

if (!file.exists(fout)) {
    languages_api <- fromJSON(url_languages)
    saveRDS(languages_api, fout)
} else {
    languages_api <- readRDS(fout)
}

lng <- languages_api[[2]]
lng <- jsonlite::flatten(lng, recursive = TRUE)

if (is.null(names(lng)) || any(names(lng) == "")) {
  names(lng) <- paste0("V", seq_along(lng))
}

wb_cachelist_new$languages <- as.data.table(lng)

colnames(wb_cachelist_new$languages)
colnames(wb_cachelist$languages)

str(wb_cachelist_new$languages[1, ])
str(wb_cachelist$languages[1, ])

setnames(wb_cachelist_new$languages, c("code", "name", "nativeForm"), c("iso2c", "lang", "lang_native"))

wb_cachelist_new$languages

# update ----

names(wb_cachelist)
names(wb_cachelist_new)

class(wb_cachelist)
attributes(wb_cachelist)

class(wb_cachelist_new) <- "wblist"

wb_cachelist <- wb_cachelist_new

usethis::use_data(wb_cachelist, overwrite = TRUE)

# indicators that the GHA flow did not save ----

indicators <- wb_cachelist$indicators$indicator_id
indicators <- toupper(indicators)

indicators_ready <- list.files("~/Documents/wbstats-data-coverage")
indicators_ready <- vapply(indicators_ready, function(x) { toupper(gsub("\\.json", "", x)) }, character(1))

length(indicators)
length(indicators_ready)

indicators_pending <- setdiff(indicators, indicators_ready)

length(indicators_pending)

head(indicators_pending)

n <- length(indicators_pending)

indicators_removed <- c()
j <- 1

for (i in seq_len(n)) {
    # i = 1
    ind <- indicators_pending[i]
    message(sprintf("[%d/%d] %s", i, n, ind))

    # a single indicator failing to download/summarize (network hiccup, no
    # data available, etc.) should not abort the whole run
    out <- tryCatch(
        {
            d <- wb_data(ind)

            if (nrow(d) == 0L) {
                # force an error, this function is not defined
                error()
            }

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
            indicators_removed[j] <<- ind
            j <<- j+1
            message("  skipped: ", conditionMessage(e))
            NULL
        }
    )

    if (!is.null(out) && nrow(out) > 0) {
        outfile <- file.path("~/Documents/wbstats-data-coverage", paste0(ind, ".json"))
        new_json <- as.character(toJSON(out, dataframe = "rows", auto_unbox = TRUE))

         writeLines(new_json, outfile, sep = "", useBytes = TRUE)
    }
}

wb_cachelist$indicators <- wb_cachelist$indicators[!indicator_id %in% indicators_removed]

usethis::use_data(wb_cachelist, overwrite = TRUE)
