library(reticulate)
library(dplyr)
library(stars)
library(sf)
library(tidyr)
library(lubridate)
library(stringr)
library(CopernicusMarine)

# library CopernicusMarine is required but may not be available through CRAN
# install.packages("CopernicusMarine", repos = c('https://pepijn-devries.r-universe.dev', 'https://cloud.r-project.org'))

# username <- Sys.getenv("CMEMS_USERNAME")
# password <- Sys.getenv("CMEMS_PASSWORD")
# my_ds    <- "cmems_mod_glo_phy_my_0.083deg_P1M-m"
# myint_ds <- "cmems_mod_glo_phy_myint_0.083deg_P1M-m"

#Smaller extent for testing
lonmin <- -80; lonmax <- -50
latmin <- 50;  latmax <- 83.5

#Arctic extents
# lonmin <- -141.5; lonmax <- -50
# latmin <- 51;  latmax <- 83.5

#Shorter timeframe for testing
start10 <- Sys.Date() - years(1)
# start10 <- Sys.Date() - years(10)
end10   <- Sys.Date()

my_data <-
  cms_download_subset(
    product       = "GLOBAL_MULTIYEAR_PHY_001_030",
    layer         = "cmems_mod_glo_phy_my_0.083deg_P1M-m_202311",
    variable      = c("bottomT"),
    region        = c(lonmin, latmin, lonmax, latmax),
    timerange     = c(start10, end10),
    verticalrange = c(0, -0.5),
    progress      = FALSE
  )

# reticulate::use_virtualenv("CopernicusMarine", required = TRUE)
# cmt <- reticulate::import("copernicusmarine")
# cmt$login(username, password)
# sf_use_s2(FALSE)
# all_long <- list()
# # Create temporary file for download
# temp_nc1 <- tempfile(fileext = ".nc")

# Download data
# cmt$subset(
#   dataset_id = "cmems_mod_glo_phy_my_0.083deg_P1M-m",
#   variables = list("bottomT"),
#   minimum_longitude = lonmin,
#   maximum_longitude = lonmax,
#   minimum_latitude = latmin,
#   maximum_latitude = latmax,
#   start_datetime = paste0(start10, "T00:00:00"),
#   end_datetime = paste0(end10,   "T23:59:59"),
#   output_directory = dirname(temp_nc1),
#   output_filename = basename(temp_nc1)
# )

# temp_nc2 <- tempfile(fileext = ".nc")
#
# cmt$subset(
#   dataset_id = "cmems_mod_glo_phy_myint_0.083deg_P1M-m",
#   variables = list("bottomT"),
#   minimum_longitude = lonmin,
#   maximum_longitude = lonmax,
#   minimum_latitude = latmin,
#   maximum_latitude = latmax,
#   start_datetime = paste0(start10, "T00:00:00"),
#   end_datetime = paste0(end10,   "T23:59:59"),
#   output_directory = dirname(temp_nc2),
#   output_filename = basename(temp_nc2)
# )

clean_glorys_nc <- function(nc_file, var_name = "bottomT", digits = 6) {
  # Disable spherical geometry for sf operations
  sf_use_s2(FALSE)

  # Read and process the netCDF file
  # full <- stars::read_ncdf(nc_file, var = var_name)
  full <- nc_file

  # Convert to sf and drop units
  full_sf <- st_as_sf(full) %>%
    units::drop_units()

  # Clean up column names
  old_names <- names(full_sf)
  new_names <- gsub("-", "_",
                    stringr::str_sub(old_names[-length(full_sf)], start = 1, end = 7)) %>%
    sub("_0", "_", .)

  names(full_sf) <- c(new_names, "geometry")

  # Round values and reconstruct sf object
  processed_sf <- full_sf %>%
    sf::st_drop_geometry() %>%
    round(digits = digits) %>%
    sf::st_as_sf(geometry = sf::st_geometry(full_sf))

  # Pivot to long format and clean up
  time_columns <- setdiff(names(processed_sf), "geometry")

  result <- processed_sf %>%
    tidyr::pivot_longer(
      cols = all_of(time_columns),
      names_to = "time_descriptor",
      values_to = "value"
    ) %>%
    mutate(
      time_descriptor = gsub("X", "", time_descriptor),  # Remove X prefix
      time_descriptor = gsub("_", "-", time_descriptor)  # Convert underscores to dashes
    ) %>%
    filter(!is.na(value))  # Remove rows with NA values

  return(result)
}

df <- clean_glorys_nc(my_data, var_name = "bottomT")
# df1 <- clean_glorys_nc(temp_nc1, var_name = "bottomT")
# df2 <- clean_glorys_nc(temp_nc2, var_name = "bottomT")
# df <- bind_rows(df1, df2)

# add year and month columns
df <- df %>%
  mutate(
    year = str_sub(time_descriptor, 1, 4),
    month = str_sub(time_descriptor, 6, 7)
  )

attr(df,"units") <- "Temperature (degC)"
attr(df,"region") <- "Northwest Atlantic"
attr(df,"source") <- "Copernicus Marine Environment Monitoring Service (CMEMS)"
attr(df,"time_descriptor") <- sprintf("Monthly data %s→%s", start10, end10)

aug_data <- my_data["bottomT",month=8]
plot(my_data["bottomT", drop = TRUE], col = hcl.colors(100), axes = TRUE)
my_data["bottomT",month=1]

#Create s4
# glorys_bottom_temperature <- as_ea_st(
#   x = df,
#   value_col    = "value",
#   data_type    = "Bottom Temperature",
#   region       = "Canadian Arctic",
#   time_descriptor = "monthly",
#   units        = "degC",
#   source_citation = "CMEMS Global Ocean Physics Reanalysis",
#   temporal_coverage = sprintf("%s to %s", start10, end10),
#   variable_name= "bottomT",
#   dataset_id   = paste(my_ds, myint_ds, sep="; ")
# )

#Convert to tibble
glorys_bottom_temperature <- as_tibble(df)

plot(glorys_bottom_temperature["value", drop = TRUE], col = hcl.colors(100), axes = TRUE)

usethis::use_data(glorys_bottom_temperature, overwrite=TRUE)
message("Done: ", nrow(df), " records.")
