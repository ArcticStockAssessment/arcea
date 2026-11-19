# Outputs from the Greenland Halibut stock assessment. Run code line-by-line and check plots.
# Change assess_yr each year, the rest is automated.
# greenland_halibut_biomass will become the latest assessment results, this is then ongoing for each second year.

# load_all()
library(tidyverse)
assess_yr <- 2025       # Year of the hake assessment; update each year

# Fishable biomass >35 cm fork length

greenland_halibut_biomass <- tibble::as_tibble(read.csv("~/GitHub/arcea/data-raw/groundfish/greenland_halibut.csv")) %>%
  select(Year,Index, Index.CV)

# class(greeland_halibut_biomass) <- c("pacea_biomass",
#                              class(hake_biomass_new))

greenland_halibut_biomass <- tibble::as_tibble(read.csv("./data-raw/groundfish/greenland_halibut.csv")) %>%
  select(Year,Index, Index.CV)

# change class to arcea_biomass so that plot() works with it
class(greenland_halibut_biomass) <- c("arcea_biomass",
                             class(greenland_halibut_biomass))

attr(greenland_halibut_biomass, "axis_name") <-
  "Greenland Halibut fishable biomass (million t)"

# Keep if statement so okay to run multiple times
# check_index_changed(greenland_halibut_biomass,
#                     greenland_halibut_biomass_new)

# if(check_index_changed(greenland_halibut_biomass,
#                        greenland_halibut_biomass_new)){
# greenland_halibut_biomass <- greenland_halibut_biomass_new

  assign(paste0("greenland_halibut_biomass_", assess_yr),
         greenland_halibut_biomass)

  usethis::use_data(greenland_halibut_biomass,
                    overwrite = TRUE)

  create_data(paste0("greenland_halibut_biomass_", assess_yr),
              get(paste0("greenland_halibut_biomass_", assess_yr)))

  plot(greenland_halibut_biomass)
# }
