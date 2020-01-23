test_that("label wrapping works", {
  library(ggplot2)

  x <- labs_wrap(
    title = "Here is my really long title. You see, I have a lot to say, you see.",
    width = 30
  )

  p <- ggplot(mtcars, aes(mpg, hp)) + x
  expect_is(x, "labels")
  expect_is(p, "ggplot")
  expect_equal(stringr::str_count(x[[1]]$title, "\n"), 2)
})
