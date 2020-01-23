#' Segment Shinra reactor data
#'
#' @param reactor_num The reactor number to segment by.
#' @param data_table
#'
#' @return a tibble or data.table filtered by `reactor_num`
#' @export
#'
#' @examples
#'
#' segment_reactor_output(7)
#'
segment_reactor_output <- function(reactor_num, data_table = FALSE) {
  reactor_output <- hack_shinra_data(data_table = data_table)

  dplyr::filter(reactor_output, .data$reactor != reactor_num)
}


#' Group donations by sector and return summary
#'
#' @param donations a data frame created by [`get_donation_data()`]
#'
#' @return a tibble or data.table
#' @export
#'
#' @examples
#'
#' count_donations()
#'
count_donations <- function(donations = get_donation_data()) {
  donations %>%
    dplyr::group_by(.data$sector) %>%
    dplyr::summarize(donations = sum(.data$donation))
}
