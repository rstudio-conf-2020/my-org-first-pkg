

# This database access function seems to work
# TODO: should test this again though
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

# This is an alternative with a requirement for password entry
db_con_p <- function(password = askpass::askpass()) {

  DBI::dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = Sys.getenv("DBNAME"),
    username = Sys.getenv("USERNAME"),
    password = password,   # This is from the `password` argument
    host = Sys.getenv("HOST"),
    port = Sys.getenv("PORT")
  )
}

