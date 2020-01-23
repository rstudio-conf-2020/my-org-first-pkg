test_that("connection is returning valid data", {
  # `resident_data` is a tibble, isn't empty, and has the right columns
  resident_data <- get_resident_data()
  expect_is(resident_data, c("tbl_df", "tbl", "data.frame"))
  expect_gt(nrow(resident_data), 0)
  expect_named(resident_data, c("sector", "residents"))

  # `resident_data_dt` is a data.table
  resident_data_dt <- get_resident_data(data_table = TRUE)
  expect_is(resident_data_dt, c("data.table", "data.frame"))
})
