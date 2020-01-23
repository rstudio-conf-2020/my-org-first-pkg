get_resident_data <- function() {
  residents_per_sector <- db_con("residents_per_sector")

  tibble::as_tibble(residents_per_sector)
}
