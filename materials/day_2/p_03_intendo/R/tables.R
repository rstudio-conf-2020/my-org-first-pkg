#' Create `tbl` objects for the intendo DB tables
#'
#' The `tbl_daily_users()`, `tbl_revenue()`, and `tbl_users()` functions will
#' give use `tbl_dbi` objects that can be used with **dplyr**. We can use the
#' **dplyr** API to work with our data and opt to `dplyr::collect()` any
#' summary tables we produce from them. The only requirement is to provide these
#' functions with a connection object, and this will be `intendo` (if we use the
#' [db_con()] or [db_con_p()] functions from this package).
#'
#' @param con the name of the connection object.
#'
#' @name tbl_functions
#' @export
tbl_daily_users <- function(con) {
  dplyr::tbl(con, "daily_users")
}

#' @rdname tbl_functions
#' @export
tbl_revenue <- function(con) {
  dplyr::tbl(con, "revenue")
}

#' @rdname tbl_functions
#' @export
tbl_users <- function(con) {
  dplyr::tbl(con, "users")
}
