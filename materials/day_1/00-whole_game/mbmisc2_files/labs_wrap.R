labs_wrap <- function(..., width = 80) {
  x <- tibble::enframe(c(...))
  x <- dplyr::mutate(x, value = stringr::str_wrap(value, width = width))
  x <- tibble::deframe(x)
  
  ggplot2::labs(!!!x)
}
