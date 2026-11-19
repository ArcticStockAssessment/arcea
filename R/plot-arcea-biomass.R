#' Plot ARCEA Biomass Data
#'
#' Creates a plot of ARCEA biomass data, displaying the biomass index
#' over time using points and lines.
#'
#' @param x An object of class `arcea_biomass`.
#' @param ... Additional arguments passed to [ggplot2::geom_point()] and
#'   [ggplot2::geom_line()].
#'
#' @return A ggplot object displaying the biomass index over time.
#'
#' @export
plot.arcea_biomass <- function(x, ...){
  # x is an arcea_biomass object
  # ... are additional arguments to pass to ggplot2::geom_point() and geom_line()
  # Check that x is an arcea_biomass object
  if(!inherits(x, "arcea_biomass")){
    stop("x must be an arcea_biomass object")
  }
  # Extract the axis name from the attributes of x
  axis_name <- attr(x, "axis_name")
  # Create a ggplot object with Year on the x-axis and Index on the y-axis
  p <- ggplot2::ggplot(x, ggplot2::aes(x = Year, y = Index)) +
    ggplot2::geom_point(...) +
    ggplot2::geom_line(...) +
    ggplot2::labs(y = axis_name) +
    ggplot2::theme_minimal()
  return(p)
}
