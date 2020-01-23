#' Wrap ggplot labels
#'
#' `labs_wrap()` wraps [stringr::str_wrap()] around any argument passed to
#' [ggplot2::labs()], thus wrapping it.
#'
#' @param ... Arguments passed to [ggplot2::labs()]
#' @param width The width of the characters to wrap to.
#'
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, hp)) +
#' labs_wrap(title =
#'   "Here is my really long title. You see, I have a lot to say, you see.",
#'   width = 30)
