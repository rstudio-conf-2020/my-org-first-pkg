#' Connect to a database
#'
#' @param dbname The database name
#'
#' @return a data frame
#' @export
#'
#' @examples
#'
#' db_con("residents_per_sector")
#'
db_con <- function(dbname = "residents_per_sector") {
  dbname <- match.arg(dbname)
  # We will set up real database connections later. For now, we'll just return
  # some hard-coded data instead.
  data.frame(
    sector = as.factor(1:8),
    residents = c(1000, 2034, 4594, 2304, 8093, 1200, 300, 2398)
  )
}
