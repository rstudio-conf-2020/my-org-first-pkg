test_that("segmentation works", {

  intendo <- db_con()

  expect_equal(
    tbl_daily_users(con = intendo) %>%
      dplyr::summarize(n = dplyr::n()) %>%
      dplyr::collect() %>%
      dplyr::mutate(n = as.numeric(n)) %>%
      dplyr::pull(n),
    segment_daily_users(con = intendo) %>%
      dplyr::summarize(n = dplyr::n()) %>%
      dplyr::collect() %>%
      dplyr::mutate(n = as.numeric(n)) %>%
      dplyr::pull(n)
  )

  expect_gt(
    segment_daily_users(con = intendo, is_customer = FALSE) %>%
      dplyr::summarize(n = dplyr::n()) %>%
      dplyr::collect() %>%
      dplyr::mutate(n = as.numeric(n)) %>%
      dplyr::pull(n),
    770000
  )

  expect_gt(
    segment_daily_users(con = intendo, is_customer = TRUE) %>%
      dplyr::summarize(n = dplyr::n()) %>%
      dplyr::collect() %>%
      dplyr::mutate(n = as.numeric(n)) %>%
      dplyr::pull(n),
    1190000
  )

  expect_lt(
    get_dau(
      con = intendo,
      dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
      segment = segment_daily_users(con = intendo, high_ad_rev = TRUE)
    ),
    get_dau(
      con = intendo,
      dates = c("2015-08-01", "2015-08-02", "2015-08-03"),
      segment = NULL
    )
  )
})
