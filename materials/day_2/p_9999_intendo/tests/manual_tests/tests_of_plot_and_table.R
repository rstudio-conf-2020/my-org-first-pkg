library(intendo)
library(lubridate)
library(dplyr)
library(scales)
library(glue)

# Create a DB connection
intendo <- db_con()

# Get a vector of dates over 30 days
end_date <- as.Date("2015-03-01")

dates <-
  seq(
    from = end_date - days(30),
    to = end_date,
    by = 1
  ) %>%
  as.character()

# Get IAP revenue for the dates selected
iap_revenue_period <-
  tbl_daily_users(con = intendo) %>%
  mutate(date = as.Date(time)) %>%
  filter(date %in% {{ dates }}) %>%
  group_by(date) %>%
  summarize(total_revenue = sum(total_revenue, na.rm = TRUE)) %>%
  collect()

# Create the time-series plot for the 30-day period
revenue_plot <-
  create_standard_ts_plot(
    ts_data = iap_revenue_period,
    time_var = "date",
    y_var = "total_revenue",
    scale_y = scales::dollar_format(),
    title = "Revenue plot",
    subtitle = glue("Time period from {min(dates)} to {max(dates)}"),
    caption = glue("Processed on {lubridate::today() %>% as.character()}."),
    y_label = "Total Revenue"
  )

revenue_plot

# Get the KPI table for a 30-day period
kpi_table <-
  create_stanard_kpi_table(
    con = intendo,
    dates = dates
  )

kpi_table
