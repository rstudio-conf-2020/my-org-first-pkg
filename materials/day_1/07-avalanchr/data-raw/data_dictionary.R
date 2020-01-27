## code to prepare `data_dictionary` dataset goes here
res_dictionary <-
  tibble::tibble(
    database = "residents_per_sector",
    variable = c("sector", "residents"),
    description = c(
      "Midgar Sector #",
      "Number of residents"
    )
  )

reactor_dictionary <-
  tibble::tibble(
    database = "shinra_reactor_output",
    variable = c("reactor", "day", "output"),
    description = c(
      "Reactor ID",
      "Day of year (integer)",
      "Reactor output (gigawatts)"
    )
  )

donations_dictionary <-
  tibble::tibble(
    database = "donations",
    variable = c("donor_id", "sector", "donation"),
    description = c(
      "Donor ID",
      "Midgar Sector # of donor residence",
      "Donation amount (gil)"
    )
  )

data_dictionary <-
  dplyr::bind_rows(res_dictionary, reactor_dictionary, donations_dictionary)

usethis::use_data(data_dictionary, overwrite = TRUE)
