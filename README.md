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

You can install:

The latest release version from CRAN with

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
library(tidyverse)
library(wbstats)

my_indicators <- c(
  life_exp = "SP.DYN.LE00.IN", 
  gdp_capita ="NY.GDP.PCAP.CD", 
  pop = "SP.POP.TOTL"
  )

d <- wb_data(my_indicators, start_date = 2016)

d %>%
  left_join(wb_countries(), "iso3c") %>%
  ggplot() +
  geom_point(
    aes(
      x = gdp_capita, 
      y = life_exp, 
      size = pop, 
      color = region
      )
    ) +
  scale_x_continuous(
    labels = scales::dollar_format(),
    breaks = scales::log_breaks(n = 10)
    ) +
  coord_trans(x = 'log10') +
  scale_size_continuous(
    labels = scales::number_format(scale = 1/1e6, suffix = "m"),
    breaks = seq(1e8,1e9, 2e8),
    range = c(1,20)
    ) +
  theme_minimal() +
  labs(
    title = "An Example of Hans Rosling's Gapminder using wbstats",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy at Birth",
    size = "Population",
    color = NULL,
    caption = "Source: World Bank"
  ) 
```

![](man/figures/readme-chart-1.png)

## Using `ggplot2` to map `wbstats` data

``` r
library(rnaturalearth)
library(tidyverse)
library(wbstats)

ind <- "SL.EMP.SELF.ZS"
indicator_info <- filter(wb_cachelist$indicators, indicator_id == ind)

ne_countries(returnclass = "sf") %>%
  left_join(
    wb_data(
      c(self_employed = ind), 
         mrnev = 1
          ),
    c("iso_a3" = "iso3c")
  ) %>%
  filter(iso_a3 != "ATA") %>% # remove Antarctica
  ggplot(aes(fill = self_employed)) +
  geom_sf() +
  scale_fill_viridis_c(labels = scales::percent_format(scale = 1)) +
  theme(legend.position="bottom") +
  labs(
    title = indicator_info$indicator,
    fill = NULL,
    caption = paste("Source:", indicator_info$source_org) 
  )
```

<img src="man/figures/ggplot2-1.png" style="display: block; margin: auto;" />
