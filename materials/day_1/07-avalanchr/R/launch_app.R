#' Launch Reactor Data Shiny App
#'
#' @return a shiny app
#' @export
launch_app <- function() {
  app_dir <- system.file(
    "shinyapps",
    "shiny_reactor_report",
    package = "avalanchr",
    mustWork = TRUE
  )
  shiny::runApp(app_dir)
}
