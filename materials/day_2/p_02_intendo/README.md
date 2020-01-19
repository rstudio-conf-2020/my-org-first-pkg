
<!-- README.md is generated from README.Rmd. Please edit that file -->

# intendo

<!-- badges: start -->

<!-- badges: end -->

The goal of the **intendo** R package is to make it much easier to work
with our own data. Here at Intendo.

## A Example of How to Use **intendo**

Get the appropriate environment variables set in your system (ask us how
to do that). Then, you can make a connection to the database with
`db_con()`

``` r
intendo <- db_con()
```

Then we can get access to a specific table, creating a `tbl_dbi` object:

``` r

daily_users <- tbl_daily_users(con = intendo)
daily_users
#> Warning: partial match of 'user' to 'username'
#> # Source:   table<daily_users> [?? x 14]
#> # Database: mysql
#> #   [student@intendo-db.csa7qlmguqrf.us-east-1.rds.amazonaws.com:NA/intendo]
#>    user_id session_id time                total_sessions total_time
#>    <chr>   <chr>      <dttm>              <int64>             <dbl>
#>  1 BRLHQD… BRLHQ_gsh… 2015-01-01 03:35:11 1                    14  
#>  2 RKPXJC… RKPXJ_gsh… 2015-01-01 03:35:11 1                     8.8
#>  3 RKPXJC… RKPXJ_gsh… 2015-01-01 03:35:11 2                    19  
#>  4 UYHDSP… UYHDS_gsh… 2015-01-01 03:35:11 1                    17  
#>  5 UYHDSP… UYHDS_gsh… 2015-01-01 03:35:11 2                    37.4
#>  6 ZFWUBK… ZFWUB_gsh… 2015-01-01 03:35:11 1                    11.4
#>  7 MPJULY… MPJUL_axw… 2015-01-01 04:57:32 1                    31.2
#>  8 PAYGJQ… PAYGJ_axw… 2015-01-01 04:57:32 1                    33.8
#>  9 YZIXBL… YZIXB_axw… 2015-01-01 04:57:32 1                    21.4
#> 10 HFTALE… HFTAL_epu… 2015-01-01 05:08:34 1                    38.8
#> # … with more rows, and 9 more variables: level_reached <int64>, at_eoc <int>,
#> #   in_ftue <int>, is_customer <int>, iap_revenue <dbl>, ad_revenue <dbl>,
#> #   total_revenue <dbl>, iap_count <int64>, ad_count <int64>
```

Now with `daily_users` and a little **dplyr**, we can easily query the
table for specific information.

``` r
daily_users %>%
  mutate(date = as.Date(time)) %>%
  filter(date == "2015-10-31", at_eoc == 1) %>%
  select(user_id, total_revenue) %>%
  group_by(user_id) %>%
  summarize(total_revenue = max(total_revenue, na.rm = TRUE)) %>%
  arrange(desc(total_revenue))
#> Warning: partial match of 'user' to 'username'
#> # Source:     lazy query [?? x 2]
#> # Database:   mysql
#> #   [student@intendo-db.csa7qlmguqrf.us-east-1.rds.amazonaws.com:NA/intendo]
#> # Ordered by: desc(total_revenue)
#>    user_id      total_revenue
#>    <chr>                <dbl>
#>  1 EMVJZSXPOFUC          470.
#>  2 ZCBWGXTSQNRL          449.
#>  3 CWQDZNKJLYPU          415.
#>  4 BHDNCMEKOLJA          394.
#>  5 IPEYVCGFLUSQ          379.
#>  6 RQHGOANPCWTZ          372.
#>  7 QWMUTZIKJXEV          368.
#>  8 MJCXIOUZBWRV          365.
#>  9 RQHXTWSVMCJF          355.
#> 10 TKENXYIAQVCP          350.
#> # … with more rows
```

And this is only the beginning. The development team is working toward
adding functions that get us our KPIs, help us generate reports, and
much more.
