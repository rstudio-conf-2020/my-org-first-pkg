library(tidyverse)
library(lubridate)
library(gt)

# This is working code that generates a **gt** table with the following:
#   - weekly average KPI values for DAU and DAC going back n number of days
#   - include averages over the entire period
#   - a title and subtitle that automatically displays the information about the table

# Need to make this into a single function and add it to the package

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

# Use the `get_dates_back` function to get dates 60 days back from `2015-09-30`
dates <- get_dates_back(n_days = 14, end_date = lubridate::ymd("2015-09-30"))

# Get a KPI tibble (increasing `n_days` makes this take a long time to complete)
kpi_tbl <-
  dplyr::tibble(date = dates) %>%
  dplyr::arrange(dplyr::desc(date)) %>%
  dplyr::mutate(weeknum = lubridate::week(date)) %>%
  dplyr::group_by(weeknum) %>%
  dplyr::mutate(days_in_week = dplyr::n()) %>%
  dplyr::ungroup() %>%
  dplyr::filter(days_in_week == 7) %>%
  dplyr::group_by(weeknum) %>%
  dplyr::summarize(
    day_start = min(date),
    day_end = max(date),
    dau = get_dau(con = intendo, dates = date),
    dac = get_dac(con = intendo, dates = date)
  ) %>%
  dplyr::collect()


kpi_gt_tbl <-
  kpi_tbl %>%
  gt::gt(rowname_col = "weeknum") %>%
  gt::cols_merge_range(
    col_begin = vars(day_start),
    col_end = vars(day_end),
    sep = " to "
  ) %>%
  gt::cols_label(
    day_start = "Day Range",
    dau = "DAU",
    dac = "DAC"
  ) %>%
  gt::tab_header(
    title = gt::md("**DAU** and **DAC** for *Super Jetroid*"),
    subtitle = gt::md(
      glue::glue("Summary data for Weeks {min(kpi_tbl$weeknum)} to {max(kpi_tbl$weeknum)}.<br><br>")
    )
  ) %>%
  gt::tab_stubhead(label = "Wk.") %>%
  gt::fmt_number(columns = vars(dau, dac), decimals = 0) %>%
  gt::grand_summary_rows(
    columns = vars(dau, dac),
    fns = list(MEAN = ~mean(., na.rm = TRUE)),
    missing_text = "",
    formatter = fmt_number,
    decimals = 0
  ) %>%
  gt::tab_options(row.striping.include_table_body = FALSE) %>%
  gt::tab_style(style = gt::cell_text(align = "left"), locations = gt::cells_title("title")) %>%
  gt::tab_style(style = gt::cell_text(align = "left"), locations = gt::cells_title("subtitle"))
