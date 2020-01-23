#' Return resident data
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
