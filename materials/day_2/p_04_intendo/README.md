
<!-- README.md is generated from README.Rmd. Please edit that file -->

# The **intendo** R package

<!-- badges: start -->

<!-- badges: end -->

The goal of the **intendo** R package is to make it much easier to work
with our own data. We can get a connection for the Intendo MySQL
database with either of two functions: `db_con()` or `db_con_p()`. To
join in on the fun, ask your manager for permission to the database
credentials and we’ll be sure to get them to you. After you have that
information, you need to have that credentials info available as
environment variables (the data team can also help you with that setup
step).

There are three tables in the MySQL database that holds all of our game
information (for that super fun and addictive game known as *Super
Jetroid*). We make it easy to access those tables with three different
functions that work to get us a `tbl_dbi` object from each. The object
obtained can be used with the **dplyr** R package and associated
packages for data analysis. We hold monthly training sessions on R and
how to use it for data analysis, so, send the development team
(available in Slack in the `#rpackage` channel) a message if you’re
interested in attending\! We hope to show you how to use this package to
get information from our data.

The package is still in active development but we’re excited to say that
the main KPIs we constantly focus on (DAU, MAU, DAC, and ARPU) can be
obtained quite easily using this package (examples available in the next
section of this README). We hope to put a lot more useful functionality
in this package and have the methods used therein be the source of truth
throughout the company. If you’re interested in contributing, we would
welcome that wholeheartedly. The Slack channel mentioned is suitable for
that. We are planning on getting either GitHub or GitLab, which is where
any issues would then be posted (for now, Slack is the best way).

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

We can get the average DAU for a span of days. This is how we can do it:

``` r
get_dau(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))
#> [1] 4224
```

And this is only the beginning. The development team is working toward
adding functions that get us our KPIs, help us generate reports, and
much more.

## Installation

This is still in development but if you’re keen to try the
in-development package, there’s a link in the `#rpackage` Slack channel
that leads to the source `.tar.gz` file. We hope to make this easier in
the future but, for now, this is the best we could do.

## License

MIT (c) Intendo
