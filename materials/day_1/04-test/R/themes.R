#' AVALANCHE ggplot2 themes
#'
#' Minimalistic ggplot themes for use on AVALANCHE reports.
#'
#' @inheritParams ggplot2::theme_minimal
#' @param ... Additional arguments passed to [ggplot2::theme_minimal()]
#'
#' @return a ggplot theme.
#' @export
#'
#' @examples
#'
#' ggplot2::qplot(iris$Sepal.Length) + theme_avalanche()
#'
theme_avalanche <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
}

#' @rdname theme_avalanche
#' @export
theme_avalanche_h <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank()
    )
}

#' @rdname theme_avalanche
#' @export
theme_avalanche_v <- function(base_size = 14, ...) {
  ggplot2::theme_minimal(base_size = base_size, ...) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )
}
