#' Connect to the intendo database using stored credentials
#'
#' With the appropriate environment variables in place (ask your manager for
#' access to these values), this function simply creates a connection object.
#'
#' If you don't have the environment variables set (but have the values) the
#' easiest way to do this is to use the `usethis::edit_r_environ()` function.
#' That puts you into your `.REnviron` file. You need to have the `DBNAME`,
#' `USERNAME`, `PASSWORD`, `HOST`, and `PORT` environment variables set with the
#' appropriate values. If you don't wish to store the DB password on your
#' system, you can use the [db_con_p()] function (which asks for the password
#' with every use but requires every other environment variable to be available).
#'
#' @examples
#' # Get a connection to the `intendo`
#' # DB with the `db_con()` function
#' db_con()
#'
#' @export
db_con <- function() {

  DBI::dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = Sys.getenv("DBNAME"),
    username = Sys.getenv("USERNAME"),
    password = Sys.getenv("PASSWORD"),
    host = Sys.getenv("HOST"),
    port = Sys.getenv("PORT")
  )
}


#' Connect to the intendo database using stored credentials plus a password
#'
#' The `db_con_p()` function is much like the [db_con()] function except that it
#' requires a password to be supplied at every use. The purpose of the function
#' is to create a connection object to the **intendo** database.
#'
#' @param password By default, you will be asked for the password.
#'
#' @export
db_con_p <- function(password = askpass::askpass()) {

  DBI::dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = Sys.getenv("DBNAME"),
    username = Sys.getenv("USERNAME"),
    password = password,
    host = Sys.getenv("HOST"),
    port = Sys.getenv("PORT")
  )
}
