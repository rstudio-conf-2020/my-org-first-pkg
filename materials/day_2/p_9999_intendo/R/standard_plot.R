#' Create a standard plot using a time-series tibble
#'
#' The `create_standard_ts_plot()` provides a means to generate a standardized
#' time series plot. The requirement is a tibble that has a column with R `Date`
#' values (`time_var`) and some other numeric column to be used as the y value
#' (`y_var`). We can add the plot `title`, `subtitle`, and `caption` here if so
#' desired. The y-axis label can be defined with the `y_label` option (the
#' x-axis label is not shown). Mean values for standard weeks can be optionally
#' shown by supplying `TRUE` to the `incl_means` argument. Finally, we can scale
#' y values by providing the appropriate **scales** function to `scale_y`.
#'
#' @param ts_data A tibble (`tbl_df`) object that contains R `Date` values and
#'   at least a numeric column to serve as y values.
#' @param time_var The name of the column in `ts_data` that contains the R
#'   `Date` values.
#' @param y_var The name of the column in `ts_data` that contains the y values.
#' @param scale_y An optional **scales** function to apply to the y values.
#' @param title,subtitle,caption Optional string values for the table's title,
#'   subtitle, and caption (appears lower right).
#' @param y_label An optional custom label for the y-axis label.
#' @param incl_means Should lines for weekly means be shown? If `TRUE`, they
#'   will be shown in an orange color.
#'
#' @examples
#' \dontrun{
#' library(lubridate)
#' library(dplyr)
#' library(glue)
#'
#' # Create a DB connection
#' intendo <- db_con()
#'
#' # Get a vector of dates over 30 days
#' end_date <- as.Date("2015-03-01")
#'
#' dates <-
#'   seq(
#'      from = end_date - days(30),
#'      to = end_date,
#'      by = 1
#'      ) %>%
#'   as.character()
#'
#' # Get IAP revenue for the dates selected
#' iap_revenue_period <-
#'   tbl_daily_users(con = intendo) %>%
#'   mutate(date = as.Date(time)) %>%
#'   filter(date %in% {{ dates }}) %>%
#'   group_by(date) %>%
#'   summarize(total_revenue = sum(total_revenue, na.rm = TRUE)) %>%
#'   collect()
#'
#' # Create the time-series plot for the 30-day period
#' revenue_plot <-
#"   create_standard_ts_plot(
#"     ts_data = iap_revenue_period,
#"     time_var = "date",
#"     y_var = "total_revenue",
#"     scale_y = scales::dollar_format(),
#"     title = "Revenue plot",
#"     subtitle = glue("Time period from {min(dates)} to {max(dates)}"),
#"     caption = glue("Processed on {lubridate::today() %>% as.character()}."),
#"     y_label = "Total Revenue"
#"   )
#' }
#'
#' @import ggplot2
#' @import rlang
#' @export
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
