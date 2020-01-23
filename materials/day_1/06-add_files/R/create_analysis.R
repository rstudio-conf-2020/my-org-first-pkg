#' Create a directory for standard AVALANCHE anlyses
#'
#' `create_analysis()` creates a project template that incudes `packages.R`,
#' `analysis.R`, and `report.Rmd`.
#'
#' @param path The directory path
#' @param folder The name of the new analysis project
#' @param author The author's name
#' @param title The title of the report
#'
#' @return invisibly, the path of the analysis directory
#' @export
#'
#' @examples
create_analysis <- function(path = ".", folder = "avalanche_analysis", author = "Author", title = "Untitled Analysis") {
  analysis_path <- fs::path(path, folder)
  if (fs::dir_exists(analysis_path)) fs::dir_delete(analysis_path)

  usethis::ui_done("Writing {usethis::ui_path(folder)}")
  fs::dir_create(analysis_path)

  use_avalanche_template("__________", folder = folder)
  use_avalanche_template("__________", folder = folder)
  use_avalanche_template(
    "__________",
    folder = folder,
    data = list("__________")
  )

  invisible(analysis_path)
}

use_avalanche_template <- function(template, folder, data = list()) {
  usethis::use_template(
    template = template,
    save_as = fs::path(folder, template),
    data = data,
    package = "__________"
  )
}


