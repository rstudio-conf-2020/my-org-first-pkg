labs_wrap <- function(..., width = 80) {
  x <- tibble::enframe(c(...))
  x <- x %>%
    dplyr::mutate(value = stringr::str_wrap(value, width = width)) %>%
    tibble::deframe() %>%
    as.list()

  ggplot2::labs(x)
}
