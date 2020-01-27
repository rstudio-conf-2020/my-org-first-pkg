test_that("segmented reactor data returns correctly", {
  segmented_reactor_data <- segment_reactor_output(7)

  # `segmented_reactor_data` is a tibble, isn't empty, and has the correct columns
  expect_is(segmented_reactor_data, c("tbl_df", "tbl", "data.frame"))
  expect_gt(nrow(segmented_reactor_data), 0)
  expect_named(segmented_reactor_data, c("reactor", "day", "output"))

  # `segmented_reactor_data` is returning the correct filtered data
  reactors <- unique(segmented_reactor_data$reactor)
  expect_length(reactors, 1)
  expect_equal(reactors, 7)
})
