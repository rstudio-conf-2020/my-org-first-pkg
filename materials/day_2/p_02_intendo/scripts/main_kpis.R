# These are functions that can help us get the DAU, MAU, DAC, and ARPU
# over a set of dates

# NOTES:
# - these functions use the rlang curly-curly notation.
#
# - maybe the part in `get_mau()` that makes dates for a month could be
#   put in it's own function?

# The `get_dau()` function
get_dau <- function(con, dates) {

  dau_vals <-
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) {
        tbl_daily_users(con = con) %>%
          dplyr::mutate(date = as.Date(time)) %>%
          dplyr::filter(date == {{ date }}) %>%
          dplyr::select(user_id) %>%
          dplyr::distinct() %>%
          dplyr::summarize(n = dplyr::n()) %>%
          dplyr::collect() %>%
          dplyr::mutate(n = as.numeric(n)) %>%
          dplyr::pull(n)
      })

  mean(dau_vals, na.rm = TRUE)
}

# Make a DB connection object (for testing purposes)
library(intendo)
intendo <- db_con()

# Test the `get_dau()` function
get_dau(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))


# The `get_mau()` function
get_mau <- function(con, year, month) {

  # Get a vector of character-based dates
  days_in_month <-
    seq(
      from = lubridate::make_date(year = year, month = month, day = 1L),
      to = (lubridate::make_date(year = year, month = month + 1, day = 1L) - lubridate::days(1)),
      by = 1
    ) %>%
    as.character()

  # Calculate the the MAU
  tbl_daily_users(con = con) %>%
    dplyr::mutate(date = as.Date(time)) %>%
    dplyr::filter(date %in% {{ days_in_month }}) %>%
    dplyr::select(user_id) %>%
    dplyr::distinct() %>%
    dplyr::summarize(n = dplyr::n()) %>%
    dplyr::collect() %>%
    dplyr::mutate(n = as.numeric(n)) %>%
    dplyr::pull(n)
}

# Test the `get_mau()` function
get_mau(con = intendo, year = 2015, month = 2)


# The `get_dac()` function; this one is not that much different
# than `get_dau()` (we just filter user_ids to those that paid)
# by that date
get_dac <- function(con, dates) {

  dac_vals <-
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) {
        tbl_daily_users(con = con) %>%
          dplyr::mutate(date = as.Date(time)) %>%
          dplyr::filter(date == {{ date }}) %>%
          dplyr::filter(is_customer == 1) %>%
          dplyr::select(user_id) %>%
          dplyr::distinct() %>%
          dplyr::summarize(n = dplyr::n()) %>%
          dplyr::collect() %>%
          dplyr::mutate(n = as.numeric(n)) %>%
          dplyr::pull(n)
      })

  mean(dac_vals, na.rm = TRUE)
}

# Test the `get_dac()` function
get_dac(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))

# Create the `get_arpu()` function
get_arpu <- function(con, dates) {

  dau_period <- get_dau(con = con, dates = dates)

  iap_revenue_period <-
    tbl_daily_users(con = con) %>%
    dplyr::mutate(date = as.Date(time)) %>%
    dplyr::filter(date %in% {{ dates }}) %>%
    dplyr::summarize(iap_rev = sum(iap_revenue, na.rm = TRUE)) %>%
    dplyr::collect() %>%
    dplyr::pull(iap_rev)

  iap_revenue_period / dau_period
}

# Test the `get_arpu()` function
get_arpu(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))

