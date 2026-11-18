# Outputs from the Greenland Halibut stock assessment. Run code line-by-line and check plots.
# Change assess_yr each year, the rest is automated.
# greenland_halibut_biomass35 will become the latest assessment results, this is then ongoing for
#  each second year.

# load_all()
assess_yr <- 2025       # Year of the hake assessment; update each year

# The greenland_halibut_biomass35-2024/*.rds files are built automatically from (Kevin)
#  running `aracea_save()` in the greenland_halibut-assessment repo after having just built the document.
# arcea-save() automatically creates the hake-<assess_yr> directory here if it doesn't exist,
#  and puts the files into it, all named with assess_yr.

# One-time code used to save original data objects from 2023 assessments as
#  _2023. Before then adding _2024 and hake_recruitment etc. being the 2024
#  values (by default)

# Fishable biomass >35 cm fork length

greenland_halibut_biomass <- tibble::as_tibble(read.csv("~/GitHub/arcea/data-raw/groundfish/greenland_halibut.csv")) %>%
  select(Year,Index, Index.CV)

# class(greeland_halibut_biomass35_new) <- c("pacea_biomass",
#                              class(hake_biomass_new))

attr(greenland_halibut_biomass, "axis_name") <-
  "Greenland Halibut fishable biomass (million t)"

# Keep if statement so okay to run multiple times
# check_index_changed(greenland_halibut_biomass,
#                     greenland_halibut_biomass35_new)

# if(check_index_changed(greenland_halibut_biomass,
#                        greenland_halibut_biomass35_new)){
# greenland_halibut_biomass <- greenland_halibut_biomass_new

  assign(paste0("greenland_halibut_biomass_", assess_yr),
         greenland_halibut_biomass)

  usethis::use_data(greenland_halibut_biomass,
                    overwrite = TRUE)

  # create_data(paste0("greenland_halibut_biomass_", assess_yr),
  #             get(paste0("greenland_halibut_biomass_", assess_yr)))

  plot(greenland_halibut_biomass)
# }
