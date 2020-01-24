#' Create gt table for donations by sector
#'
#' @inheritParams count_donations
#'
#' @return a `gt` table
#' @export
gt_donations <- function(donations = get_donation_data()) {
  gt::gt(donations)
}

#' Create gt table for the data dictionary
#'
#' @return a `gt` table
#' @export
gt_data_dictionary <- function() {
  gt::gt(data_dictionary)
}
