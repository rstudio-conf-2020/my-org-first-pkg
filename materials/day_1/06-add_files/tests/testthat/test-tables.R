test_that("donations table is correct", {
  x <- gt_donations(donations_test_data)

  expect_is(x, "gt_tbl")
})
