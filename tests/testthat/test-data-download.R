## Use testthat 3rd edition API
testthat::local_edition(3)

# Focused tests using the recorded cassette to validate basic contract of wb_data
test_that("wb_data returns expected structure and date range for Brazil 2006-2010", {
  vcr::use_cassette(name = "wb_gdp_bra", {
    df <- wb_data("NY.GDP.MKTP.CD", country = "BRA", start_date = 2006, end_date = 2010)

    # basic expectations
    expect_s3_class(df, "data.frame")
    expect_gt(nrow(df), 0)
    expect_true(is.numeric(df$date) || inherits(df$date, "Date"))

    # column expectations (wide format for a single indicator)
    expect_true(all(c("iso3c", "country", "date") %in% names(df)))
    expect_true("NY.GDP.MKTP.CD" %in% names(df))

    # date range checks - when not using date_as_class_date dates are numeric years
    if (is.numeric(df$date)) {
      expect_equal(min(df$date, na.rm = TRUE), 2006)
      expect_equal(max(df$date, na.rm = TRUE), 2010)
    } else {
      # if dates are class Date, extract year
      yrs <- as.integer(format(df$date, "%Y"))
      expect_equal(min(yrs, na.rm = TRUE), 2006)
      expect_equal(max(yrs, na.rm = TRUE), 2010)
    }

    # ensure the data is for Brazil (iso3c)
    expect_true(all(unique(na.omit(df$iso3c)) == "BRA"))
  })
})


# Expanded tests mirroring the examples from the documentation. Each test
# always uses a cassette (same style as the first test)

test_that("gdp for all countries (all dates) - example", {
  vcr::use_cassette(name = "wb_gdp_all", {
    df <- wb_data("NY.GDP.MKTP.CD")
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0)
    expect_true("NY.GDP.MKTP.CD" %in% names(df) || "value" %in% names(df))
  })
})

test_that("Brazil GDP all dates - example", {
  vcr::use_cassette(name = "wb_brazil_all", {
    df <- wb_data("NY.GDP.MKTP.CD", country = "br")
    expect_s3_class(df, "data.frame")
    expect_true(all(unique(na.omit(df$iso3c)) == "BRA"))
  })
})

test_that("Brazil GDP 2006 - example", {
  vcr::use_cassette(name = "wb_brazil_2006", {
    df <- wb_data("NY.GDP.MKTP.CD", country = "brazil", start_date = 2006)
    expect_s3_class(df, "data.frame")
    yrs <- if (is.numeric(df$date)) df$date else as.integer(format(df$date, "%Y"))
    expect_true(all(yrs >= 2006))
  })
})

test_that("multiple indicators (wide) - example", {
  vcr::use_cassette(name = "wb_multi_indicators", {
    my_indicators <- c("SP.POP.TOTL", "NY.GDP.MKTP.CD", "SL.UEM.TOTL.ZS", "SP.DYN.CBRT.IN")
    df <- wb_data(my_indicators)
    expect_s3_class(df, "data.frame")
    expect_true(any(c("SP.POP.TOTL", "NY.GDP.MKTP.CD") %in% names(df)))
  })
})

test_that("multiple country ids mixed types - example", {
  vcr::use_cassette(name = "wb_multi_countries", {
    my_indicators <- c("SP.POP.TOTL", "NY.GDP.MKTP.CD")
    my_countries <- c("AL", "Geo", "mongolia")
    df <- wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007)
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0)
  })
})

test_that("long format return_wide = FALSE - example", {
  vcr::use_cassette(name = "wb_long_format", {
    my_indicators <- c("SP.POP.TOTL", "NY.GDP.MKTP.CD")
    my_countries <- c("AL", "Geo", "mongolia")
    df <- wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007, return_wide = FALSE)
    expect_s3_class(df, "data.frame")
    expect_true(all(c("indicator_id", "value", "date") %in% names(df)))
  })
})

test_that("regions only - example", {
  vcr::use_cassette(name = "wb_region_totals", {
    df <- wb_data("SP.POP.TOTL", country = "regions_only", start_date = 2010, end_date = 2014)
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0)
  })
})

test_that("world aggregate - example", {
  vcr::use_cassette(name = "wb_world", {
    df <- wb_data("SP.POP.TOTL", country = "world", start_date = 2010, end_date = 2014)
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0)
  })
})

test_that("named indicators become column names (wide) - example", {
  vcr::use_cassette(name = "wb_named_vector_wide", {
    my_indicators <- c("pop" = "SP.POP.TOTL", "gdp" = "NY.GDP.MKTP.CD", "unemployment_rate" = "SL.UEM.TOTL.ZS", "birth_rate" = "SP.DYN.CBRT.IN")
    df <- wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014)
    expect_s3_class(df, "data.frame")
    expect_true(all(c("pop", "gdp") %in% names(df)))
  })
})

test_that("named indicators ignored in long format - example", {
  vcr::use_cassette(name = "wb_named_vector_long", {
    my_indicators <- c("pop" = "SP.POP.TOTL", "gdp" = "NY.GDP.MKTP.CD")
    df <- wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014, return_wide = FALSE)
    expect_s3_class(df, "data.frame")
    expect_true(all(c("indicator_id", "indicator") %in% names(df)))
  })
})

test_that("named indicators long format with language - example", {
  vcr::use_cassette(name = "wb_named_vector_long_bg", {
    my_indicators <- c("pop" = "SP.POP.TOTL", "gdp" = "NY.GDP.MKTP.CD")
    df <- wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014, return_wide = FALSE, lang = "bg")
    expect_s3_class(df, "data.frame")
    expect_true("indicator" %in% names(df))
  })
})
