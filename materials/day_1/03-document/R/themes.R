theme_avalanche <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
}

#' Title
#'
#' @param base_size
#'
#' @return
#' @export
#'
#' @examples
theme_avalanche_h <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank()
    )
}

#' Title
#'
#' @param base_size
#'
#' @return
#' @export
#'
#' @examples
theme_avalanche_v <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )
}
