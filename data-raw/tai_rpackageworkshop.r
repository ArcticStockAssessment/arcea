# 2026-11-19
# script for setting things things up in arcea package

# load development package
library(devtools)
devtools::load_all()

##### loaded datasets to the package
# view the attached dataset to the package
head(greenland_halibut_biomass)
class(greenland_halibut_biomass)

# check that the plot function works with specific class
plot(x = greenland_halibut_biomass)
plot.arcea_biomass(x = greenland_halibut_biomass)

##### help files
# check that help files were created
# data object help files are created in the data.R file and will be created in the man folder when the package is built `build()`
# function help files are created in the file the function is writted in, within the `R` folder and will be created in the man folder when the package is built `build()`
#  function help files are created using roxygen2 comments above the function definition (go to code menu in RStudio and select `Insert Roxygen Skeleton` to create the roxygen2 comments above the function definition)
?greenland_halibut_biomass
?plot.arcea_biomass()
# plot.arcea_biomass() is the function that is called when plot() is called on an object of class arcea_biomass which uses ggplot2
# will need to change the help file so that the plot.arcea_biomass() help file lists ggplot2 as a dependency and that the plot() function is called on an object of class arcea_biomass

# import ggplot2 package to the package namespace so that it is available when the package is loaded
# this will write to namespace file and add ggplot2 to the Imports field in the DESCRIPTION file
# usethis::use_package("ggplot2", type = "Imports") # commented out for now in case you don't actually want to add ggplot2 as a dependency to the package

##### testing the plot function
# set up test folder and testthat subfolder
usethis::use_testthat()

# create a specific test file for the plot function
usethis::use_test("plot_arcea_biomass") # will create a test file called test-plot_arcea_biomass.R in the tests/testthat folder

# run all tests in the package
devtools::test()

# run a specific test file
devtools::test_file("tests/testthat/test-plot_arcea_biomass.R")

