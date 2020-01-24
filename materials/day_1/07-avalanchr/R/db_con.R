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
#' @importFrom stats runif
#'
db_con <- function(dbname = c("residents_per_sector", "shinra_reactor_output", "donations")) {
  dbname <- match.arg(dbname)
  # We will set up real database connections later. For now, we'll just return
  # some hard-coded data instead.
  if (dbname == "residents_per_sector") {
    x <- data.frame(
      sector = as.factor(1:8),
      residents = c(1000, 2034, 4594, 2304, 8093, 1200, 300, 2398)
    )
  }

  if (dbname == "shinra_reactor_output") {
    x <- data.frame(
      reactor = sort(rep(1:8, 365)),
      day = rep(1:365, 8),
      output = floor(runif(2920, 1000, 10000))
    )

    x[x$reactor == 7, "output"] <- 0
  }

  if (dbname == "donations") {
    x <- data.frame(
      donor_id = 1:100,
      sector = sample(as.factor(1:8), 100, replace = TRUE),
      donation = round(runif(100, 1, 1000), 2)
    )
  }

  x
}

