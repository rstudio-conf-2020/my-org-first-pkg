library(tidyverse)

tbl_daily_users <- function(con = NULL) {

  tbl(con, "daily_users")
}

tbl_revenue <- function(con = NULL) {

  tbl(con, "revenue")
}

tbl_users <- function(con = NULL) {

  tbl(con, "users")
}
