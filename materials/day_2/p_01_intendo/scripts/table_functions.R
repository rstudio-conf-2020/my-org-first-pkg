library(tidyverse)

# These are functions for accessing each of the tables in the intendo DB

tbl_daily_users <- function(con = NULL) {

  tbl(con, "daily_users")
}

tbl_revenue <- function(con = NULL) {

  tbl(con, "revenue")
}

tbl_users <- function(con = NULL) {

  tbl(con, "users")
}
