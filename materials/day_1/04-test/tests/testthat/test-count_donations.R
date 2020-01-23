donations_test_data <- data.frame(
  donor_id = 1:15,
  sector = c(7L, 2L, 8L, 6L, 5L, 5L, 8L, 1L, 5L, 4L, 4L, 3L, 7L, 5L, 8L),
  donation = c(
    529.58, 16.64, 410.88, 448.73, 211.62, 642.53, 410.93,
    707.38, 30.19, 573.02, 286.31, 734.73, 971.81, 30, 465.92
  )
)


test_that("counting donations works", {
  x <- count_donations(donations_test_data)

  expect_equal(nrow(x), 8)
  expect_named(x, c("sector", "donations"))
})
