#' Get the average DAU value over a particular set of dates
#'
#' This function uses data from the **intendo** database to get the DAU (daily
#' active users) on a single day, or, the average over a set of days. You need
#' to supply the database connection object and a vector of dates in ISO format.
#'
#' We can choose to get a segmented value for DAU (by default, no segmentation
#' occurs). Support is currently limited, see the help file for the
#' [segment_daily_users()] function for details on which segmentation options
#' are available.
#'
#' @param con A connection to the **intendo** database. We can use either of the
#'   [db_con()] or [db_con_p()] functions to generate this.
#' @param dates A vector of dates.
#' @param segment An optional call to the [segment_daily_users()] function,
#'   which will segment the `daily_users` DB table in order to return a
#'   segmented DAU value.
#'
#' @import rlang
#' @export
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

#' Get the MAU value for a particular month of data
#'
#' This function uses data from the **intendo** database to get the MAU (monthly
#' active users) for a specified month. You need to supply the `year` and the
#' `month` (any value from `1` to `12`).
#'
#' @inheritParams get_dau
#' @param year,month The year and month number for the MAU calculation.
#'
#' @import rlang
#' @export
get_mau <- function(con,
                    year,
                    month) {

  # Get a vector of dates
  days_in_month <-
    seq(
      from = lubridate::make_date(year = year, month = month, day = 1L),
      to = lubridate::make_date(year = year, month = month + 1, day = 1L) -
        lubridate::days(1),
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

#' Get the average DAC value over a particular set of dates
#'
#' This function uses data from the **intendo** database to get the DAC (daily
#' active customers) on a single day, or, the average over a set of days. You
#' need to supply the database connection object and a vector of dates in ISO
#' format.
#'
#' @inheritParams get_dau
#'
#' @import rlang
#' @export
get_dac <- function(con,
                    dates) {

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


#' Get the ARPU value over a particular set of dates
#'
#' This function uses data from the **intendo** database to get the ARPU
#' (average revenue per user) on a single day or over a set of days. You need to
#' supply the database connection object and a vector of dates in ISO format.
#'
#' @inheritParams get_dau
#'
#' @import rlang
#' @export
get_arpu <- function(con,
                     dates) {

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
