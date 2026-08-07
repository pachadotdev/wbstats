<!-- README.md is generated from README.Rmd. Please edit that file -->

# wbstats: An R package for searching and downloading data from the World Bank API <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/wbstats)](https://CRAN.R-project.org/package=wbstats)
[![Monthly](https://cranlogs.r-pkg.org/badges/wbstats)](https://CRAN.R-project.org/package=wbstats)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![Test
coverage](https://raw.githubusercontent.com/pachadotdev/wbstats/test-coverage/badges/coverage.svg)](https://github.com/pachadotdev/wbstats/actions/workflows/test-coverage.yaml)
[![R-CMD-check](https://github.com/pachadotdev/wbstats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pachadotdev/wbstats/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

You can install the latest release version from CRAN with

```r
install.packages("wbstats")
```

or

The latest development version from github with

```r
remotes::install_github("pachadotdev/wbstats")
```

# Downloading data from the World Bank

```r
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

The current World Bank API does not provide summaries of data availability. I added the
`wb_country_coverage()` function to supply that, which reads pre-computed summaries
from GitHub.

```r
d <- wb_country_coverage("GDPCAP", c("Mexico", "Chile"), 2010, 2020)
d

#      iso2c  iso3c country pct_complete  from    to  nobs                  indicator
#     <char> <char>  <char>        <num> <int> <int> <int>                     <char>
#  1:     CL    CHL   Chile         17.8  1960  2100    18  UIS.XUNIT.GDPCAP.02.FSGOV
#  2:     MX    MEX  Mexico         12.9  1960  2100    13  UIS.XUNIT.GDPCAP.02.FSGOV
#  3:     CL    CHL   Chile         18.8  1960  2100    19   UIS.XUNIT.GDPCAP.1.FSGOV
#  4:     MX    MEX  Mexico         19.8  1960  2100    20   UIS.XUNIT.GDPCAP.1.FSGOV
#  5:     CL    CHL   Chile         15.8  1960  2100    16    UIS.XUNIT.GDPCAP.1.FSHH
#  6:     MX    MEX  Mexico         15.8  1960  2100    16    UIS.XUNIT.GDPCAP.1.FSHH
#  7:     CL    CHL   Chile         17.8  1960  2100    18   UIS.XUNIT.GDPCAP.2.FSGOV
#  8:     MX    MEX  Mexico         18.8  1960  2100    19   UIS.XUNIT.GDPCAP.2.FSGOV
#  9:     CL    CHL   Chile         17.8  1960  2100    18  UIS.XUNIT.GDPCAP.23.FSGOV
# 10:     MX    MEX  Mexico         18.8  1960  2100    19  UIS.XUNIT.GDPCAP.23.FSGOV
# 11:     CL    CHL   Chile         15.8  1960  2100    16   UIS.XUNIT.GDPCAP.23.FSHH
# 12:     MX    MEX  Mexico         16.8  1960  2100    17   UIS.XUNIT.GDPCAP.23.FSHH
# 13:     CL    CHL   Chile         17.8  1960  2100    18   UIS.XUNIT.GDPCAP.3.FSGOV
# 14:     MX    MEX  Mexico         18.8  1960  2100    19   UIS.XUNIT.GDPCAP.3.FSGOV
# 15:     CL    CHL   Chile         18.8  1960  2100    19 UIS.XUNIT.GDPCAP.5T8.FSGOV
# 16:     MX    MEX  Mexico         18.8  1960  2100    19 UIS.XUNIT.GDPCAP.5T8.FSGOV
# 17:     CL    CHL   Chile         15.8  1960  2100    16  UIS.XUNIT.GDPCAP.5T8.FSHH
# 18:     MX    MEX  Mexico         16.8  1960  2100    17  UIS.XUNIT.GDPCAP.5T8.FSHH

# countries with less than 15% coverage for any variable
d[pct_complete < 15, ]

#     iso2c  iso3c country pct_complete  from    to  nobs                 indicator
#    <char> <char>  <char>        <num> <int> <int> <int>                    <char>
# 1:     MX    MEX  Mexico         12.9  1960  2100    13 UIS.XUNIT.GDPCAP.02.FSGOV
```

## Hans Rosling’s Gapminder using `wbstats`

```r
library(wbstats)
library(data.table)
library(tinyplot)

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
