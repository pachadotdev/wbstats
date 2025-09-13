https://cran-archive.r-project.org/web/checks/2025/2025-08-25_check_results_wbstats.html

Check Details

Version: 1.0.4
Check: CRAN incoming feasibility
Result: NOTE
  Maintainer: ‘Jesse Piburn <piburnjo@ornl.gov>’
  
  Package CITATION file contains call(s) to old-style personList() or
  as.personList().  Please use c() on person objects instead.
  Package CITATION file contains call(s) to old-style citEntry().  Please
  use bibentry() instead.

* using log directory ‘/data/blackswan/ripley/R/packages/tests-devel/wbstats.Rcheck’
* using R Under development (unstable) (2025-08-07 r88529)
* using platform: x86_64-pc-linux-gnu
* R was compiled by
    gcc (GCC) 14.2.1 20240912 (Red Hat 14.2.1-3)
    GNU Fortran (GCC) 14.2.1 20240912 (Red Hat 14.2.1-3)
* running under: Fedora Linux 40 (Workstation Edition)
* using session charset: UTF-8
* checking for file ‘wbstats/DESCRIPTION’ ... OK
* checking extension type ... Package
* this is package ‘wbstats’ version ‘1.0.4’
* package encoding: UTF-8
* checking package namespace information ... OK
* checking package dependencies ... OK
* checking if this is a source package ... OK
* checking if there is a namespace ... OK
* checking for executable files ... OK
* checking for hidden files and directories ... OK
* checking for portable file names ... OK
* checking for sufficient/correct file permissions ... OK
* checking whether package ‘wbstats’ can be installed ... OK
* checking package directory ... OK
* checking ‘build’ directory ... OK
* checking DESCRIPTION meta-information ... OK
* checking top-level files ... OK
* checking for left-over files ... OK
* checking index information ... OK
* checking package subdirectories ... OK
* checking code files for non-ASCII characters ... OK
* checking R files for syntax errors ... OK
* checking whether the package can be loaded ... OK
* checking whether the package can be loaded with stated dependencies ... OK
* checking whether the package can be unloaded cleanly ... OK
* checking whether the namespace can be loaded with stated dependencies ... OK
* checking whether the namespace can be unloaded cleanly ... OK
* checking loading without being on the library search path ... OK
* checking whether startup messages can be suppressed ... OK
* checking dependencies in R code ... OK
* checking S3 generic/method consistency ... OK
* checking replacement functions ... OK
* checking foreign function calls ... OK
* checking R code for possible problems ... OK
* checking Rd files ... OK
* checking Rd metadata ... OK
* checking Rd line widths ... OK
* checking Rd cross-references ... OK
* checking for missing documentation entries ... OK
* checking for code/documentation mismatches ... OK
* checking Rd \usage sections ... OK
* checking Rd contents ... OK
* checking for unstated dependencies in examples ... OK
* checking contents of ‘data’ directory ... OK
* checking data for non-ASCII characters ... OK
* checking LazyData ... OK
* checking data for ASCII and uncompressed saves ... OK
* checking R/sysdata.rda ... OK
* checking installed files from ‘inst/doc’ ... OK
* checking files in ‘vignettes’ ... OK
* checking examples ... OK
* checking examples with --run-donttest ... [7s/155s] ERROR
Running examples in ‘wbstats-Ex.R’ failed
The error most likely occurred in:

> ### Name: wb_data
> ### Title: Download Data from the World Bank API
> ### Aliases: wb_data
> 
> ### ** Examples
> 
> 
> 
> # gdp for all countries for all available dates
> ## No test: 
> df_gdp <- wb_data("NY.GDP.MKTP.CD")
> ## End(No test)
> 
> # Brazilian gdp for all available dates
> ## No test: 
> df_brazil <- wb_data("NY.GDP.MKTP.CD", country = "br")
> ## End(No test)
> 
> # Brazilian gdp for 2006
> ## No test: 
> df_brazil_1 <- wb_data("NY.GDP.MKTP.CD", country = "brazil", start_date = 2006)
> ## End(No test)
> 
> # Brazilian gdp for 2006-2010
> ## No test: 
> df_brazil_2 <- wb_data("NY.GDP.MKTP.CD", country = "BRA",
+                        start_date = 2006, end_date = 2010)
> ## End(No test)
> 
> # Population, GDP, Unemployment Rate, Birth Rate (per 1000 people)
> ## No test: 
> my_indicators <- c("SP.POP.TOTL",
+                    "NY.GDP.MKTP.CD",
+                    "SL.UEM.TOTL.ZS",
+                    "SP.DYN.CBRT.IN")
> ## End(No test)
> 
> ## No test: 
> df <- wb_data(my_indicators)
> ## End(No test)
> 
> # you pass multiple country ids of different types
> # Albania (iso2c), Georgia (iso3c), and Mongolia
> ## No test: 
> my_countries <- c("AL", "Geo", "mongolia")
> df <- wb_data(my_indicators, country = my_countries,
+               start_date = 2005, end_date = 2007)
> ## End(No test)
> 
> # same data as above, but in long format
> ## No test: 
> df_long <- wb_data(my_indicators, country = my_countries,
+                    start_date = 2005, end_date = 2007,
+                    return_wide = FALSE)
> ## End(No test)
> 
> # regional population totals
> # regions correspond to the region column in wb_cachelist$countries
> ## No test: 
> df_region <- wb_data("SP.POP.TOTL", country = "regions_only",
+                      start_date = 2010, end_date = 2014)
> ## End(No test)
> 
> # a specific region
> ## No test: 
> df_world <- wb_data("SP.POP.TOTL", country = "world",
+                     start_date = 2010, end_date = 2014)
Error in curl::curl_fetch_memory(url, handle = handle) : 
  Timeout was reached [api.worldbank.org]:
Operation timed out after 20002 milliseconds with 0 bytes received
Calls: wb_data ... request_fetch.write_memory -> <Anonymous> -> raise_libcurl_error
Execution halted
* checking for unstated dependencies in vignettes ... OK
* checking package vignettes ... OK
* checking re-building of vignette outputs ... OK
* checking PDF version of manual ... OK
* checking for non-standard things in the check directory ... OK
* checking for detritus in the temp directory ... OK
* checking for new files in some other directories ... OK
* DONE

Status: 1 ERROR
See
  ‘/data/blackswan/ripley/R/packages/tests-devel/wbstats.Rcheck/00check.log’
for details.

Command exited with non-zero status 1
Time 4:34.99, 69.15 + 56.44
