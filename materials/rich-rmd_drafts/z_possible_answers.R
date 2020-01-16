library(tidyverse)


# A database access function
# 
# ans_01_02.1

db_con <- function() {
  
  dbname <- ""
  username <- ""
  password <- ""
  host <- ""
  port <- ""
  
  conn <- 
    dbConnect(
      drv = RMariaDB::MariaDB(),
      dbname = dbname,
      username = username,
      password = password,
      host = host,
      port = port
    )
  
  assign(
    x = "intendo",
    value = conn,
    envir = .GlobalEnv
  )
}

# An alternative with a requirement for password entry
db_con_p <- function(password = askpass::askpass()) {
  
  dbname <- ""
  username <- ""
  host <- ""
  port <- ""
  
  conn <- 
    dbConnect(
      drv = RMariaDB::MariaDB(),
      dbname = dbname,
      username = username,
      password = password,
      host = host,
      port = port
    )
  
  assign(
    x = "intendo",
    value = conn,
    envir = .GlobalEnv
  )
}





# Three functions that create `tbl_dbi` objects, one for
# each of the tables in the database
# 
# ans_01_02.2

tbl_daily_users <- function(con = NULL) {
  
  dplyr::tbl(con, "daily_users")
}

tbl_revenue <- function(con = NULL) {
  
  dplyr::tbl(con, "revenue")
}

tbl_users <- function(con = NULL) {
  
  dplyr::tbl(con, "users")
}






# Three functions that create `tbl_dbi` objects, one for
# each of the tables in the database
# 
# ans_02_01.1

# Create the `get_dau()` function
get_dau <- function(con, dates) {
  
  dau_vals <- 
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) { 
        tbl_daily_users(con = con) %>%
          dplyr::mutate(date = as.Date(time)) %>%
          dplyr::filter(date == {{ date }}) %>%
          dplyr::select(user_id) %>%
          dplyr::distinct() %>%
          dplyr::summarize(n = dplyr::n()) %>%
          dplyr::collect() %>%
          dplyr::mutate(n = as.numeric(n)) %>%
          dplyr::pull(n)
      })
  
  mean(dau_vals, na.rm = TRUE)
}

# Test the `get_dau()` function
get_dau(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03")) # 4224


# Create the `get_mau()` function
get_mau <- function(con, year, month) {
  
  # Get a vector of character-based dates
  days_in_month <- 
    seq(
      from = lubridate::make_date(year = year, month = month, day = 1L),
      to = (lubridate::make_date(year = year, month = month + 1, day = 1L) - lubridate::days(1)),
      by = 1
    ) %>%
    as.character()
  
  # Calculate the the MAU
  tbl_daily_users(con = con) %>%
    dplyr::mutate(date = as.Date(time)) %>%
    dplyr::filter(date %in% {{ days_in_month }}) %>%
    dplyr::select(user_id) %>%
    dplyr::distinct() %>%
    dplyr::summarize(n = dplyr::n()) %>%
    dplyr::collect() %>%
    dplyr::mutate(n = as.numeric(n)) %>%
    dplyr::pull(n)
}

# Test the `get_mau()` function
get_mau(con = intendo, year = 2015, month = 2) # 103200


# Create the `get_dac()` function
get_dac <- function(con, dates) {

  dac_vals <- 
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) { 
        tbl_daily_users(con = con) %>%
          dplyr::mutate(date = as.Date(time)) %>%
          dplyr::filter(date == {{ date }}) %>%
          dplyr::filter(is_customer == 1) %>%
          dplyr::select(user_id) %>%
          dplyr::distinct() %>%
          dplyr::summarize(n = dplyr::n()) %>%
          dplyr::collect() %>%
          dplyr::mutate(n = as.numeric(n)) %>%
          dplyr::pull(n)
      })
  
  mean(dac_vals, na.rm = TRUE)
}

# Test the `get_dac()` function
get_dac(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03")) # 1824.33

# Create the `get_arpu()` function
get_arpu <- function(con, dates) {
  
  dau_period <- get_dau(con = con, dates = dates)

  iap_revenue_period <-
    tbl_daily_users(con = con) %>%
    dplyr::mutate(date = as.Date(time)) %>%
    dplyr::filter(date %in% {{ dates }}) %>%
    dplyr::summarize(iap_rev = sum(iap_revenue, na.rm = TRUE)) %>%
    dplyr::collect() %>%
    dplyr::pull(iap_rev)
  
  iap_revenue_period / dau_period
}

# Test the `get_arpu()` function
get_arpu(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03")) # 68.73342





# A function that segments the `daily_users` table
# 
# ans_02_02.1

# Create a function that can segment the `daily_users`
# table by whether a user is a customer or not
segment_daily_users <- function(con,
                                is_customer = NULL,
                                high_ad_rev = NULL) {
  
  daily_users <- tbl_daily_users(con = con)
  
  # Apply the `is_customer` segment
  if (!is.null(is_customer)) {
    
    is_customer <- as.integer(is_customer)
    
    daily_users <-
      daily_users %>%
      dplyr::filter(is_customer == {{ is_customer }})
  }
  
  # Apply the `high_ad_rev` segment
  if (!is.null(high_ad_rev)) {
    
    ad_rev_amount <- 2.00
    
    daily_users <-
      daily_users %>%
      dplyr::filter(ad_revenue >= {{ ad_rev_amount }})
  }
  
  daily_users
}


# Some rigorous testing of the function
tbl_daily_users(con = intendo) %>% dplyr::count()      # 1969139
segment_daily_users(con = intendo) %>% dplyr::count()  # 1969139

segment_daily_users(con = intendo, is_customer = FALSE) %>% dplyr::count() # 772603
segment_daily_users(con = intendo, is_customer = TRUE) %>% dplyr::count() # 1196536


# Augment the `get_dau()` function created earlier to use segmentation
# 
# ans_02_02.2

# Modify the `get_dau()` function to accept a segment
get_dau_2 <- function(con,
                      dates,
                      segment = NULL) {
  
  if (!is.null(segment)) {
    # Evaluate the segment call
    daily_users <- segment
  } else {
    daily_users <- tbl_daily_users(con = con)
  }
  
  dau_vals <- 
    vapply(
      dates,
      FUN.VALUE = numeric(1),
      USE.NAMES = FALSE,
      FUN = function(date) { 
        daily_users %>%
          dplyr::mutate(date = as.Date(time)) %>%
          dplyr::filter(date == {{ date }}) %>%
          dplyr::select(user_id) %>%
          dplyr::distinct() %>%
          dplyr::summarize(n = dplyr::n()) %>%
          dplyr::collect() %>%
          dplyr::mutate(n = as.numeric(n)) %>%
          dplyr::pull(n)
      })
  
  mean(dau_vals, na.rm = TRUE)
}


get_dau_2(
  con = intendo,
  dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
  segment = segment_daily_users(con = intendo, high_ad_rev = TRUE)
) # 122

get_dau_2(
  con = intendo,
  dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
  segment = NULL
) # 3845

