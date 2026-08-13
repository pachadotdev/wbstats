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
d <- wb_country_coverage("gross domestic product", c("Mexico", "Chile"), 2010, 2020)
d

#      iso2c  iso3c country pct_complete  from    to  nobs         indicator
#     <char> <char>  <char>        <num> <int> <int> <int>            <char>
#  1:     CL    CHL   Chile         56.5  1960  2100    52     CC.EG.INTS.KW
#  2:     MX    MEX  Mexico         56.5  1960  2100    52     CC.EG.INTS.KW
#  3:     CL    CHL   Chile         34.8  1960  2025    23 EG.EGY.PRIM.PP.KD
#  4:     MX    MEX  Mexico         34.8  1960  2025    23 EG.EGY.PRIM.PP.KD
#  5:     CL    CHL   Chile         53.0  1960  2025    35 EG.GDP.PUSE.KO.PP
# ---                                                                       
# 82:     MX    MEX  Mexico         54.5  1960  2025    36    PA.NUS.PRVT.PP
# 83:     CL    CHL   Chile         53.0  1960  2025    35 SL.GDP.PCAP.EM.KD
# 84:     MX    MEX  Mexico         53.0  1960  2025    35 SL.GDP.PCAP.EM.KD
# 85:     CL    CHL   Chile        100.0  2004  2023    20   SPI.D5.2.5.HOUS
# 86:     MX    MEX  Mexico         40.0  2004  2023     8   SPI.D5.2.5.HOUS

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

## How I create the package data

What worked for me to query the data was to use the `format` and `per_page` arguments. You *do not* need this to work with the package.

Endpoints used for the package data:

* https://api.worldbank.org/v2/indicators?format=json&per_page=30000
* https://api.worldbank.org/v2/source?format=json&per_page=100
* https://api.worldbank.org/v2/topics?format=json&per_page=100
* https://api.worldbank.org/v2/regions?format=json&per_page=100
* https://api.worldbank.org/v2/incomelevel?format=json&per_page=10
* https://api.worldbank.org/v2/lendingtypes?format=json&per_page=10
* https://api.worldbank.org/v2/languages?format=json&per_page=100

Parts of this API endpoints description comes from https://dlthub.com/context/source/world-bank-indicators-api and other were just testing things like "language" and "languages" tp update `wbstats`. I did not create this package, I just assumed its maintenance as it is a very valuable resoure.

Resource          | Endpoint	                                        | Method |	Description
------------------|---------------------------------------------------|--------|------------------------------------------
indicators        |	/v2/indicator 	                                  | GET	   | Access to nearly 28,000 series indicators
countries         |	/v2/country/all                                   | GET	   | All countries
country_indicator |	/v2/country/{country_id}/indicator/{indicator_id} |	GET	   | Specific indicator for a country
sources	          | /v2/source                                        | GET	   | All data sources
source_indicators |	/v2/source/{source_id}/indicators                 |	GET	   | Indicators for a specific source
topics            | /v2/topics                                        | GET    | Metadata about indicator topics
regions           |	/v2/country/all                                   | GET	   | All regions
income_levels     |	/v2/country/income_levels                         | GET	   | All income levels
lending_types     |	/v2/country/lending_types                         | GET	   | All lending types
languages         |	/v2/country/languages                             | GET	   | All languages

I added this sub-section because I did not find much information in the official documentation.
