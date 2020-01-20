#' Segment the `daily_users` table in one or more ways
#'
#' This function works in tandem with the `segment` argument (which may be
#' available in certain KPI-reporting functions). So far, we can segment with
#' the following options:
#' \itemize{
#' \item is_customer: whether the user is a customer (i.e., ever made a purchase
#' through an in-app purchase).
#' \item high_ad_rev: whether a user has earned Intendo high ad revenue (above
#' $2.00).
#' }
#'
#' @inheritParams get_dau
#' @param is_customer Segment by whether or not (`TRUE`/`FALSE`) users are
#'   customers.
#' @param high_ad_rev Segment by whether or not (`TRUE`/`FALSE`) users have
#'   accrued more than $2.00 of ad revenue.
#'
#' @import rlang
#' @export
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
