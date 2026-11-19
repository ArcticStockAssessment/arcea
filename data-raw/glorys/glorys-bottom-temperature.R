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

plot(my_data["bottomT", drop = TRUE], col = hcl.colors(100), axes = TRUE)

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

#Convert to tibble
glorys_bottom_temperature <- as_tibble(df)

usethis::use_data(glorys_bottom_temperature, overwrite=TRUE)
message("Done: ", nrow(df), " records.")
