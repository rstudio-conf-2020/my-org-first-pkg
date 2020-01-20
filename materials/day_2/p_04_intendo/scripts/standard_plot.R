library(tidyverse)
library(lubridate)

# This is a set of functions that generates a **ggplot** with the following:
#   - revenue going back a fixed number of days
#   - text annotations of total revenue for every standard week
#   - average revenue lines for the above
#   - a title and a subtitle that automatically displays the right info about the plot

# Need to add this to the package

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

# A function to get a set of dates back from a specific date
get_dates_back <- function(n_days,
                           end_date = lubridate::today()) {

  seq(
    from = end_date - lubridate::days(n_days),
    to = end_date,
    by = 1
  ) %>%
    as.character()
}

# Use the `get_dates_back` function to get dates 30 days back from `2015-09-30`
dates <- get_dates_back(n_days = 30, end_date = lubridate::ymd("2015-09-30"))

# Use the `get_total_revenue_by_date()` function to revenue values for the `dates`
ts_data <- get_total_revenue_by_date(con = intendo, dates = dates)

# Create a general function for timeseries plotting; this way any table with
# a `date` column and some metric can be plotted in a standard way
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

