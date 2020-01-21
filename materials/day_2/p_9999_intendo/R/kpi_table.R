#' Create a KPI table with DAU and DAC averaged over weeks
#'
#' The `create_stanard_kpi_table()` function will create a standardized **gt**
#' table with DAU and DAC averaged over standard week numbers (where weeks begin
#' on Sunday). A sequence of `dates` should be supplied over a span of time.
#' For inclusion in reports, the dates should usually go back 60 days from the
#' present day. Incomplete weeks will be culled from the table.
#'
#' @inheritParams get_dau
#'
#' @examples
#' \dontrun{
#' library(lubridate)
#'
#' # Create a DB connection
#' intendo <- db_con()
#'
#' # Get a vector of dates over 30 days
#' end_date <- as.Date("2015-03-01")
#'
#' dates <-
#'   seq(
#'      from = end_date - lubridate::days(30),
#'      to = end_date,
#'      by = 1
#'      ) %>%
#'   as.character()
#'
#' # Get the KPI table for a 30-day period
#' kpi_table <-
#'   create_stanard_kpi_table(
#'     con = intendo,
#'     dates = dates
#'   )
#' }
#'
#' @export
create_stanard_kpi_table <- function(con,
                                     dates) {

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
      dau = get_dau(con = con, dates = date),
      dac = get_dac(con = con, dates = date)
    ) %>%
    dplyr::collect()

  kpi_tbl %>%
    gt::gt(rowname_col = "weeknum") %>%
    gt::cols_merge_range(
      col_begin = gt::vars(day_start),
      col_end = gt::vars(day_end),
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
    gt::fmt_number(columns = gt::vars(dau, dac), decimals = 0) %>%
    gt::grand_summary_rows(
      columns = gt::vars(dau, dac),
      fns = list(MEAN = ~mean(., na.rm = TRUE)),
      missing_text = "",
      formatter = gt::fmt_number,
      decimals = 0
    ) %>%
    gt::tab_options(row.striping.include_table_body = FALSE) %>%
    gt::tab_style(style = gt::cell_text(align = "left"), locations = gt::cells_title("title")) %>%
    gt::tab_style(style = gt::cell_text(align = "left"), locations = gt::cells_title("subtitle"))
}
