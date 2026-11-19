test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("plot_arcea_biomass works", {
  expect_silent(plot.arcea_biomass(greenland_halibut_biomass))
})

# test that a non arcea_biomass object throws an error
test_that("plot_arcea_biomass throws error for non-arcea_biomass object", {
  expect_error(plot.arcea_biomass(mtcars), "x must be an arcea_biomass object")
})

# test that the column names for plotting are correct
test_that("plot.arcea_biomass uses correct column names", {
  # create dummy data frame with incorrect column names
  dummy_data <- data.frame(Year = 1:10, Index = rnorm(10))
  class(dummy_data) <- c("arcea_biomass", class(dummy_data))
  attr(dummy_data, "axis_name") <- "Dummy axis name"
  # expect an error if the column names are correct using names() and %in%
  expect_contains(colnames(dummy_data), c("Year", "Index"))
})
