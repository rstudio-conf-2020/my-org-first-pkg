#' Return various data used in AVALANCHE analyses
#'
#' @param data_table Logical. Return a `data.table`?
#'
#' @return Either a `tibble` or a `data.table`
#' @export
#'
#' @examples
#'
#' get_resident_data(data_table = TRUE)
#'
get_resident_data <- function(data_table = FALSE) {
  residents_per_sector <- db_con("residents_per_sector")

  if (data_table) return(data.table::as.data.table(residents_per_sector))

  tibble::as_tibble(residents_per_sector)
}

#' @export
#' @rdname get_resident_data
hack_shinra_data <- function(data_table = FALSE) {
  shinra_reactor_output <- db_con("shinra_reactor_output")

  if (data_table) return(data.table::as.data.table(shinra_reactor_output))

  tibble::as_tibble(shinra_reactor_output)
}

#' @export
#' @rdname get_resident_data
get_donation_data <- function(data_table = FALSE) {
  donations <- db_con("donations")

  if (data_table) return(data.table::as.data.table(donations))

  tibble::as_tibble(donations)
}


