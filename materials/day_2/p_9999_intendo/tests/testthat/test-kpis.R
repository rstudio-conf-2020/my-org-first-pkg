test_that("KPI calculations work", {

  intendo <- db_con()

  dau_val <- get_dau(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))
  mau_val <- get_mau(con = intendo, year = 2015, month = 2)
  dac_val <- get_dac(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))
  arpu_val <- get_arpu(con = intendo, dates = c("2015-01-01", "2015-01-02", "2015-01-03"))

  expect_is(dau_val, "numeric")
  expect_is(mau_val, "numeric")
  expect_is(dac_val, "numeric")
  expect_is(arpu_val, "numeric")

  expect_equal(dau_val, 4224L)
  expect_equal(mau_val, 103200)
  expect_gt(dac_val, 1820)
  expect_lt(dac_val, 1830)
  expect_gt(arpu_val, 65)
  expect_lt(arpu_val, 70)
})
