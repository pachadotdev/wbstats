<!-- README.md is generated from README.Rmd. Please edit that file -->

# wbstats: An R package for searching and downloading data from the World Bank API <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/wbstats)](https://CRAN.R-project.org/package=wbstats)
[![Monthly](https://cranlogs.r-pkg.org/badges/wbstats)](https://CRAN.R-project.org/package=wbstats)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![R-CMD-check](https://github.com/pachadotdev/wbstats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pachadotdev/wbstats/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

You can install the latest release version from CRAN with

``` r
install.packages("wbstats")
```

or

The latest development version from github with

``` r
remotes::install_github("pachadotdev/wbstats")
```

# Downloading data from the World Bank

``` r
library(wbstats)

# Population for every country from 1960 until present
d <- wb_data("SP.POP.TOTL")
    
head(d)
#> # A tibble: 6 × 9
#>   iso2c iso3c country    date SP.POP.TOTL unit  obs_status footnote last_updated
#>   <chr> <chr> <chr>     <dbl>       <dbl> <chr> <chr>      <chr>    <date>      
#> 1 AF    AFG   Afghanis…  2024    42647492 <NA>  <NA>       <NA>     2025-07-01  
#> 2 AF    AFG   Afghanis…  2023    41454761 <NA>  <NA>       <NA>     2025-07-01  
#> 3 AF    AFG   Afghanis…  2022    40578842 <NA>  <NA>       <NA>     2025-07-01  
#> 4 AF    AFG   Afghanis…  2021    40000412 <NA>  <NA>       <NA>     2025-07-01  
#> 5 AF    AFG   Afghanis…  2020    39068979 <NA>  <NA>       <NA>     2025-07-01  
#> 6 AF    AFG   Afghanis…  2019    37856121 <NA>  <NA>       <NA>     2025-07-01
```

## Hans Rosling’s Gapminder using `wbstats`

``` r
library(wbstats)
library(data.table)

my_indicators <- c(
  life_exp = "SP.DYN.LE00.IN",
  gdp_capita ="NY.GDP.PCAP.CD",
  pop = "SP.POP.TOTL"
)

d <- wb_data(my_indicators, start_date = 2016)
d <- merge(d, wb_countries(), "iso3c")
d <- na.omit(d)

png(file="man/figures/readme-gdppc-vs-lifexp.png", width = 900, height = 600)
tinyplot(
  life_exp ~ gdp_capita | region,
  data = d,
  cex = d$pop,
  pch = 19,
  alpha = 0.7,
  palette = "tableau",
  log = "x",
  xaxl = "$",
  main = "An Example of Hans Rosling's Gapminder using wbstats",
  xlab = "GDP per Capita (log scale)",
  ylab = "Life Expectancy at Birth",
  cap = "Source: World Bank"
)
dev.off()
```

![](man/figures/readme-gdppc-vs-lifexp.png)
