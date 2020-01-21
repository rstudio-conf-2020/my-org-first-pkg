test_that("connections to the database work", {

  intendo <- db_con()

  expect_is(intendo, "MariaDBConnection")
})

test_that("the correct tables can be accessed as `tbl_dbi` objects", {

  intendo <- db_con()

  daily_users <- tbl_daily_users(intendo)
  revenue <- tbl_revenue(intendo)
  users <- tbl_users(intendo)

  expect_is(daily_users, c("tbl_MariaDBConnection", "tbl_dbi", "tbl_sql", "tbl_lazy", "tbl"))
  expect_is(revenue, c("tbl_MariaDBConnection", "tbl_dbi", "tbl_sql", "tbl_lazy", "tbl"))
  expect_is(users, c("tbl_MariaDBConnection", "tbl_dbi", "tbl_sql", "tbl_lazy", "tbl"))

  expect_equal(
    daily_users %>% head() %>% dplyr::collect() %>% colnames(),
    DBI::dbListFields(intendo, "daily_users")
  )

  expect_equal(
    revenue %>% head() %>% dplyr::collect() %>% colnames(),
    DBI::dbListFields(intendo, "revenue")
  )

  expect_equal(
    users %>% head() %>% dplyr::collect() %>% colnames(),
    DBI::dbListFields(intendo, "users")
  )
})
