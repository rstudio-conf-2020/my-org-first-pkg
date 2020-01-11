
# A database access function
# 
# ans_01_02.1

db_con <- function() {
  
  dbname <- ""
  username <- ""
  password <- ""
  host <- ""
  port <- ""
  
  dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = dbname,
    username = username,
    password = password,
    host = host,
    port = port
  )
}

# An alternative with a requirement for password entry
db_con_p <- function(password = askpass::askpass()) {
  
  dbname <- ""
  username <- ""
  host <- ""
  port <- ""
  
  dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = dbname,
    username = username,
    password = password,
    host = host,
    port = port
  )
}

# Three functions that create `tbl_dbi` objects, one for
# each of the tables in the database
# 
# ans_01_02.2

tbl_daily_users <- function() {
  
  con <- db_con()
  tbl(con, "daily_users")
}

tbl_revenue <- function() {
  
  con <- db_con()
  tbl(con, "revenue")
}

tbl_users <- function() {
  
  con <- db_con()
  tbl(con, "users")
}

# Three functions that create `tbl_dbi` objects, one for
# each of the tables in the database
# 
# ans_02_02.1

