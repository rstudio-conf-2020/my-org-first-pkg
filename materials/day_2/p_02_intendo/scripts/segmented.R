library(intendo)
library(tidyverse)

# An idea for a function that segments the `daily_users` table, it's not perfect
# but it's a start.

# Function that can segment the `daily_users` table by:
# - whether a user is a customer or not
# - whether a user has given us a 'high' amount of ad revenue ($2.00)
segment_daily_users <- function(con,
                                is_customer = NULL,
                                high_ad_rev = NULL) {

  daily_users <- tbl_daily_users(con = con)

  # Apply the `is_customer` segment
  if (!is.null(is_customer)) {

    is_customer <- as.integer(is_customer)

    daily_users <-
      daily_users %>%
      dplyr::filter(is_customer == {{ is_customer }})
  }

  # Apply the `high_ad_rev` segment
  if (!is.null(high_ad_rev)) {

    ad_rev_amount <- 2.00

    daily_users <-
      daily_users %>%
      dplyr::filter(ad_revenue >= {{ ad_rev_amount }})
  }

  daily_users
}

# Make a DB connection object (for testing purposes)
intendo <- db_con()

# Here are some tests of that function, the results make sense to me
tbl_daily_users(con = intendo) %>% count()
segment_daily_users(con = intendo) %>% count()

segment_daily_users(con = intendo, is_customer = FALSE) %>% count()
segment_daily_users(con = intendo, is_customer = TRUE) %>% count()


# Here is how `get_dau()` function could be changed to use segmentation
get_dau <- function(con,
                    dates,
                    segment = NULL) {

  if (!is.null(segment)) {

    # Evaluate the segment call
    daily_users <- segment
  } else {
    daily_users <- tbl_daily_users(con = con)
  }

  dau_vals <-
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) {
        daily_users %>%
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


# Tests of the new function

db_con()

get_dau(
  con = intendo,
  dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
  segment = segment_daily_users(con = intendo, high_ad_rev = TRUE)
)

get_dau(
  con = intendo,
  dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
  segment = NULL
)

# What do you think of this change to `get_dau()`?
# Any ways to make it better?
