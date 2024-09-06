# Plotting functions for Noise Solution visualisations
# Gabrielle M. Schroeder
# August 2024

library(dplyr)
library(ggplot2)
library(ggforce)
library(ggnewscale)
library(ggrepel)


source(file.path('lib', 'lib_colours.R'))

# Theme, all plots ----

noise_solution_theme <- function(font_family = "DM Sans", transparent = FALSE) {
  
  # Colours
  clrs <- get_plot_clrs()
  
  # Without or with background
  if (transparent) {
    custom_theme <- theme(
      panel.background = element_rect(fill = "transparent", colour = NA),
      plot.background = element_rect(fill = "transparent", colour = NA),
      text = element_text(family = font_family),
      legend.position = "none"
    )
  } else {
    custom_theme <- theme(
      plot.background = element_rect(
        fill = clrs$background, 
        colour = clrs$background
      ),
      text = element_text(family = font_family),
      legend.position = "none"
    )
  }
  
  ns_theme <- list(
    # Theme void to start with blank slate
    theme_void(),
    # Background colour, remove legends
    custom_theme
  )
  
  return(ns_theme)
}

# SWEMWBS changes (ring) ----

# Ring axis lines and text
ring_axis <- function(
    max_y, # absolute max swemwbs change, for colourmap limits
    orientation = 1, # positive (1) or negative (-1) lines
    y_shift = 0.75, # shift from zero
    to = 20,
    by = 10, 
    alpha = 0.1,
    text_alpha = 0.6,
    text_x = 0,
    text_r = 0.2,
    fontsize = 14,
    font_family = "DM Sans"
) {
  
  # Locations to draw lines
  axis_y = seq(from = 0, to = to*orientation, by = by*orientation)
  n_y = length(axis_y)
  
  # Get colours
  clrs <- get_plot_clrs()
  
  if (orientation == 1) {
    gen_clr <- colorRamp(clrs$map_pos)
  } else if (orientation == -1) {
    gen_clr <- colorRamp(clrs$map_neg)
  }
  
  axis_clrs = rep(0, n_y)
  for (i in 1:length(axis_y)) {
    axis_clrs[i] <- rgb(gen_clr((orientation*axis_y[i])/max_y), maxColorValue = 255)
  }
  if (orientation == -1) {
    axis_clrs <- rev(axis_clrs)
  }
  
  # Axis lines
  axis_lines <- geom_hline(
    yintercept = axis_y + (y_shift * orientation),
    colour = axis_clrs,
    alpha = alpha
  )
  
  # Text labels (excluding first line at 0)
  text_df <- data.frame(
    x = rep(text_x, n_y - 1),
    y = axis_y[2:n_y] + (y_shift*orientation),
    label = sapply(axis_y[2:n_y], toString)
  )
  if (orientation == 1) {
    text_df <- text_df |>
      mutate(label = paste0("+", label))
  }
  axis_text <- ggrepel::geom_text_repel(
    mapping = aes(x = x, y = y, label = label),
    data = text_df,
    color = axis_clrs[2:n_y],
    alpha = text_alpha,
    bg.colour = clrs$background, 
    bg.r = text_r, 
    force = 0,
    size = fontsize/.pt,
    family = font_family
  )
  
  return(list(lines = axis_lines, text = axis_text))
}

# SWEMWBS changes - ring
plot_swemwbs_ring <- function(
    data_ns,
    plot_labels = TRUE,
    y_shift = 0.75, 
    axis_text_rel_loc = 0.875,
    font_family = "DM Sans",
    fontsize_axis = 14,
    transparent = TRUE
  ) {
  
  # Prep data ---
  n_sessions <- nrow(data_ns)
  
  # For ggforce geom_link2, need row for each end point of a line segment
  data1 = data_ns |> 
    mutate(y = 0) # start points
  data2 = data_ns |>
    mutate(y = swemwbs_change) # end points
  data_for_plot = rbind(data1, data2) # combine into one data frame
  
  # Colours ---
  clrs <- get_plot_clrs()
  max_y = max(abs(data_for_plot$y)) # max absolute change (for setting colour scales)
  
  # Axis lines ---
  axis_pos <- ring_axis(
    max_y = max_y,
    orientation = 1,
    text_x = n_sessions*axis_text_rel_loc,
    y_shift = y_shift,
    fontsize = fontsize_axis,
    font_family = font_family
  )
  axis_neg <- ring_axis(
    max_y = max_y, 
    orientation = -1, 
    text_x = n_sessions*axis_text_rel_loc, 
    y_shift = y_shift,
    fontsize = fontsize_axis,
    font_family = font_family
  )
  
  # Geoms and scales for ring ---
  ring_geoms_and_scales <- list(
    # Points inside ring
    ring_points <- geom_point(
      data = data_ns,
      aes(x = id, y = 0),
      colour = clrs$violet,
      size = 0.05,
      shape = 20
    ),
    # positive changes
    ggforce::geom_link2(
      data = data_for_plot |> filter(swemwbs_change >= 0), 
      mapping = aes(x = id, y = y + y_shift, group = id, colour = after_stat(y - y_shift)),
      linewidth = 0.5,
      n = 250
    ),
    # positive changes color scale
    scale_color_gradientn(
      colors = clrs$map_pos,
      limits = c(0, max_y)
    ),
    # new colour scale
    ggnewscale::new_scale_color(),
    # negative changes
    ggforce::geom_link2(
      data = data_for_plot |> filter(swemwbs_change < 0), 
      mapping = aes(x = id, y = y - y_shift, group = id, colour = after_stat(y + y_shift)),
      linewidth = 0.5,
      n = 250
      ),
    # negative changes colour scale
    scale_color_gradientn(
      colors = clrs$map_neg,
      limits = c(-1 * max_y, 0)
    )
  )
    
  # Theme and coordinates ---
  ring_theme <- noise_solution_theme(font_family = font_family, transparent = transparent)
  ring_coord <- coord_radial(
    expand = FALSE, 
    inner.radius = 0.3, 
    clip = "off",
  )
  
  # Create full visualisation
  if (plot_labels) {
    p_ring <- ggplot() +
      # axis lines
      axis_pos$lines +
      axis_neg$lines +
      # SWEMWBS changes
      ring_geoms_and_scales +
      # axis text
      axis_pos$text +
      axis_neg$text +
      # Theme and coordinates
      ring_theme +
      ring_coord
  } else {
    p_ring <- ggplot() +
      # SWEMWBS changes
      ring_geoms_and_scales +
      # Theme and coordinates
      ring_theme +
      ring_coord
  }

  return(p_ring)
}