# Viz For Social Good: Noise Solution
# Ring of SWEMWBS changes
# Gabrielle Schroeder, August 2024

# Set up----
rm(list = ls())
library(ggplot2)
library(svglite)
library(showtext)

# Custom functions for data manipulation, colours, and vis
source(file.path('lib', 'lib_colours.R'))
source(file.path('lib', 'lib_data.R'))
source(file.path('lib', 'lib_vis.R'))

# Load and prep data (ns = Noise Solution) ----

file_ns <- file.path('data', 'VFSG Noise Solution Report Aug 24.xls')
data_ns <- load_and_prep_noise_solution_data(file_ns)
data_ns <- compute_swemwbs_change(data_ns)
n <- nrow(data_ns)
View(data_ns)

# Plot: change in swemwbs scores ----

# Add font
showtext::showtext_auto()
font_family = "DM Sans"
sysfonts::font_add_google("DM Sans", font_family)

# Create ring
p_ring <- plot_swemwbs_ring(
  data_ns, 
  plot_labels = TRUE, 
  fontsize_axis = 10, 
  font_family = font_family,
  transparent = FALSE,
  axis_text_rel_loc = 0.125
)

# Save ---
plot_dir <- "plots"
dpi <- 600
showtext::showtext_opts(dpi = dpi)

size <- 20

# PNG
ggplot2::ggsave(
  file.path(plot_dir,'ns_ring.png'), 
  width = size, 
  height = size, 
  units = "cm", dpi = dpi
)

# SVG
ggplot2::ggsave(
  file.path(plot_dir,'ns_ring.svg'), 
  width = size, 
  height = size, 
  units = "cm"
)

# Stats for plot ----

print(paste("Number of participants: ", length(unique(data_ns$uin))))

print(paste("Mean change: ", mean(data_ns$swemwbs_change)))

print(paste("Number of sets of sessions: ", nrow(data_ns)))