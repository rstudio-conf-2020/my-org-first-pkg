library(tidyverse)
library(gt)

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

# Make a DB connection object (for testing purposes)
db_con()

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






# - Create a function that generates a **ggplot** with the following:
#   - revenue going back a fixed number of days
#   - text annotations of total revenue for every standard week
#   - average revenue lines for the above
#   - a title and a subtitle that automatically displays the right info about the plot
#
# ans_04_01.1


# First, create a function to get total revenue for specific dates
get_total_revenue_by_date <- function(con, dates) {
  
  iap_revenue_period <-
    tbl_daily_users(con = con) %>%
    dplyr::mutate(date = as.Date(time)) %>%
    dplyr::filter(date %in% {{ dates }}) %>%
    group_by(date) %>%
    dplyr::summarize(total_revenue = sum(total_revenue, na.rm = TRUE)) %>%
    dplyr::collect()
}

# Create a function to get a set of dates back from a specific date
get_dates_back <- function(n_days = 30,
                           end_date = lubridate::today()) {
  
    seq(
      from = end_date - lubridate::days(n_days),
      to = end_date,
      by = 1
    ) %>%
    as.character()
}

# Use the `get_dates_back` function to get dates 30 days back from `2015-09-30`
dates <- get_dates_back(end_date = lubridate::ymd("2015-09-30"))

# Use the `get_total_revenue_by_date()` function to revenue values for the `dates`
ts_data <- get_total_revenue_by_date(con = intendo, dates = dates)


# Create a general function for timeseries plotting
create_standard_ts_plot <- function(ts_data,
                                    time_var,
                                    y_var,
                                    scale_y = NULL,
                                    title = NULL,
                                    subtitle = NULL,
                                    caption = NULL,
                                    y_label = NULL,
                                    incl_means = TRUE) {
  
  # Create symbols from the `time_var` and `y_var` string values
  time_var <- rlang::sym(time_var)
  y_var <- rlang::sym(y_var)
  
  # Augment the `ts_data` table with `dow`, `day_type`, and `color`
  ts_data <-
    ts_data %>%
    dplyr::mutate(
      dow = lubridate::wday({{ time_var }}, label = TRUE, abbr = FALSE)) %>%
    dplyr::mutate(day_type = ifelse(
      dow %in% c("Friday", "Saturday", "Sunday"), "weekend", "weekday")) %>%
    dplyr::mutate(color = ifelse(day_type == "weekend", "darkmagenta", "green"))
  
  # Create the plot layer with just the daily data points
  plot <- 
    ggplot() +
    geom_point(
      aes(x = {{ time_var }}, y = {{ y_var }}, color = ts_data$color),
      data = ts_data
    )
  
  # If we choose to plot the mean value lines per week number,
  # then create a new dataset and apply the line to the plot
  if (incl_means) {
    
    ts_data_means <- 
      ts_data %>%
      dplyr::select({{ time_var }}, {{ y_var }}) %>%
      dplyr::mutate(weeknum = lubridate::week({{ time_var }})) %>%
      dplyr::group_by(weeknum) %>%
      dplyr::mutate(days_in_week = n()) %>%
      dplyr::ungroup() %>%
      dplyr::filter(days_in_week == 7) %>%
      dplyr::group_by(weeknum) %>%
      dplyr::mutate(avg_value = mean({{ y_var }}, na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::select({{ time_var }}, avg_value, weeknum)
    
    plot <-
      plot +
      geom_line(
        aes(x = date, y = avg_value),
        data = ts_data_means,
        color = "orange", size = 1, alpha = 0.5
      )
  }
  
  # Scale the x values and applying theme elements
  plot <-
    plot +
    scale_x_date(
      date_breaks = "10 days",
      date_minor_breaks = "1 day",
      date_labels = "%b %d\n%Y"
    ) + 
    theme_minimal() +
    theme(
      axis.text = element_text(color = "grey25"),
      axis.text.x = element_text(color = "grey25", size = 6.5),
      axis.text.y = element_text(color = "grey25", size = 8),
      axis.title = element_text(color = "grey25"),
      axis.title.x = element_text(color = "grey25"),
      axis.title.y = element_text(color = "grey25"),
      legend.title = element_text(color = "grey25"),
      legend.text = element_text(color = "grey25"),
      panel.grid.major = element_line(color = "grey85", size = 0.4),
      panel.grid.minor = element_line(color = "grey90", size = 0.2),
      plot.title = element_text(color = "grey25", size = 14),
      plot.subtitle = element_text(color = "grey25", size = 12),
      plot.caption = element_text(color = "grey25", size = 6),
      plot.margin = unit(c(20, 20, 20, 20), "points"),
      legend.box.spacing = unit(2, "points"),
      legend.position = "none"
    )
  
  # Optionally transform plot label components
  if (!is.null(title)) plot <- plot + labs(title = title)
  if (!is.null(subtitle)) plot <- plot + labs(subtitle = subtitle)
  if (!is.null(caption)) plot <- plot + labs(caption = caption)
  if (!is.null(y_label)) plot <- plot + labs(y = y_label)
  
  # Optionally scale the y values if a `scales::*_format()` fcn is provided
  if (!is.null(scale_y) && is.function(scale_y)) {
    plot <- plot + scale_y_continuous(labels = scale_y)
  }
  
  plot
}

# Test of the function
create_standard_ts_plot(
  ts_data = ts_data,
  time_var = "date",
  y_var = "total_revenue",
  scale_y = scales::dollar_format(),
  title = "Revenue plot",
  subtitle = glue::glue("Time period from {min(dates)} to {max(dates)}"),
  caption = glue::glue("Processed on {lubridate::today() %>% as.character()}."),
  y_label = "Total Revenue"
)







# - Create a function that generates a **gt** table with the following:
#   - weekly average KPI values for DAU, MAU, DAC, ARPU going back 60 days
#   - total revenue (IAP revenue + advertising revenue)
#   - include averages over the entire period and grand total sum of revenue
#   - a title and subtitle that automatically displays the information about the table
#
# ans_04_01.2


