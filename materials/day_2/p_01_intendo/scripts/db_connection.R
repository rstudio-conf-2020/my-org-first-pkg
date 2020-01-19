library(tidyverse)
library(gt)

# This database access function seems to work
# TODO: should test this again though
db_con <- function() {

  conn <-
    DBI::dbConnect(
      drv = RMariaDB::MariaDB(),
      dbname = Sys.getenv("DBNAME"),
      username = Sys.getenv("USERNAME"),
      password = Sys.getenv("PASSWORD"),
      host = Sys.getenv("HOST"),
      port = Sys.getenv("PORT")
    )

  # Using `assign()` means we don't have to
  # think of a name for the DB connection
  # TODO: does everybody agree this is a good name?
  assign(
    x = "intendo",
    value = conn,
    envir = .GlobalEnv
  )
}

# This is an alternative with a requirement for password entry
db_con_p <- function(password = askpass::askpass()) {

  dbname <- Sys.getenv("DBNAME")
  username <- Sys.getenv("USERNAME")
  host <- Sys.getenv("HOST")
  port <- Sys.getenv("PORT")

  conn <-
    DBI::dbConnect(
      drv = RMariaDB::MariaDB(),
      dbname = Sys.getenv("DBNAME"),
      username = Sys.getenv("USERNAME"),
      password = password,   # This is from the `password` argument
      host = Sys.getenv("HOST"),
      port = Sys.getenv("PORT")
    )

  assign(
    x = "intendo",
    value = conn,
    envir = .GlobalEnv
  )
}

