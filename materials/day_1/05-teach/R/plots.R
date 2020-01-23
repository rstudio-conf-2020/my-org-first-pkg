#' Plot donation counts by sector
#'
#' @param ... Arguments passed to [`count_donations()`]
#'
#' @return a ggplot
#' @export
#'
#' @examples
#'
#' plot_donation()
#'
plot_donations <- function(...) {
  x <- count_donations(...)

  ggplot2::ggplot(x, ggplot2::aes(
    forcats::fct_reorder(sector, donations),
    donations)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::xlab("sector") +
    theme_avalanche_v()
}
