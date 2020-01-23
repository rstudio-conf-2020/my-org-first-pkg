test_that("counting donations works", {
  x <- count_donations(donations_test_data)

  expect_equal(nrow(x), 8)
  expect_named(x, c("sector", "donations"))
})
