# Initial exploration of the Noise Solution data set
# Gabrielle Schroeder, August 2024

# Set up----
rm(list = ls())
library(dplyr)
library(readxl)
library(janitor)
library(ggplot2)
library(ggforce)

# Load data (ns = Noise Solution) ----

file_ns <- file.path('data', 'Noise_Solution_VFSG_report_FINAL_July_24.xls')
data_ns <- read_xls(file_ns)

# Clean variable names
data_ns <- janitor::clean_names(data_ns)

# Only analyse external members for posts > 0 
# (removes two non-zero values of external members)
data_ns$external_members[data_ns$posts == 0] = NA

# Sort by ID and add participant number from 1 to n
data_ns <- data_ns |>
  dplyr::arrange(uin) |>
  dplyr::mutate(id = row_number())

View(data_ns)

# Compute change in swemwbs ----
data_ns <- data_ns |>
  dplyr::mutate(
    # change
    swemwbs_change = swemwbs_end_score - swemwbs_start_score,
    # whether it increased (boolean)
    swemwbs_increased = swemwbs_change > 0
  )


# check for duplicates ----

data_uin <- data_ns |>
  select(uin) |>
  group_by(uin) |>
  summarise(n = n()) |>
  arrange(desc(n))

View(data_uin)

# Plots: histograms ----

# Histogram of change in swemwbs
ggplot(data = data_ns, mapping = aes(x = swemwbs_change)) +
  geom_histogram(binwidth = 1)

# Start swemwbs
ggplot(data = data_ns, mapping = aes(x = swemwbs_start_score)) +
  geom_histogram(binwidth = 1)

# End swemwbs
ggplot(data = data_ns, mapping = aes(x = swemwbs_end_score)) +
  geom_histogram(binwidth = 1)


# Plots: each participant's change in swemwbs ----

# start and end
ggplot(
  data = data_ns, 
  mapping = aes(
    x = id, 
    xend = id, 
    y = swemwbs_start_score, 
    yend = swemwbs_end_score,
    colour = swemwbs_increased
  )
) +
  geom_segment() +
  coord_radial(expand = FALSE, inner.radius = 0.25)

# change (start at 0)
ggplot(
  data = data_ns, 
  mapping = aes(
    x = id, 
    xend = id, 
    y = 0, 
    yend = swemwbs_change,
    colour = swemwbs_increased
  )
) +
  geom_segment() +
  coord_radial(expand = FALSE, inner.radius = 0.25)

# Plots: change in swemwbs with gradients and circular plots ----
data1 = data_ns |> 
  mutate(y = 0)
data2 = data_ns |>
  mutate(y = swemwbs_change)
data_for_plot = rbind(data1, data2)

max_y = max(abs(data_for_plot$y)) 
ggplot(
  data = data_for_plot, 
  mapping = aes(
    x = id, 
    y = y
  )
) +
  geom_link2(aes(group = id, colour = after_stat(y))) +
  scale_color_gradientn(
    colors = c('#ffe6ff', '#f9b3dc', '#f27cb6', '#e93586', '#b51867', '#7b0c51', '#11449f', '#0d70a2', '#3895b7', '#6db8cf', '#a1dbe7', '#d6ffff'),
    values = c(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
    limits = c(-1 * max_y, max_y)
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(
      fill = "grey10", 
      colour = "grey10"
    )
  ) +
  coord_radial(expand = FALSE, inner.radius = 0.25)

# Plots: change in swemwbs ( = color) and circular plots ----

max_y = max(abs(data_ns$swemwbs_change)) 
ggplot(
  data = data_ns, 
  mapping = aes(
    x = id, 
    xend = id,
    y = 0,
    yend = swemwbs_change,
    color = swemwbs_change
  )
) +
  geom_segment() +
  scale_color_gradientn(
    colors = c('#e31d77', '#f45ea8', '#fe91cc', '#f9c6e1', '#9dd9fd', '#66b8e6', '#3d97c4', '#1b75a1'),
    values = c(0, 0.4, 0.5, 0.6, 1),
    limits = c(-1 * max_y, max_y)
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(
      fill = "grey10", 
      colour = "grey10"
    )
  ) +
  coord_radial(expand = FALSE, inner.radius = 0.25)

# Plots: variable comparisons (scatter plots) ----

# Change in swemwbs vs. posts (posts > 0 only)
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = posts, y = swemwbs_change)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm', formula = y~x)

# Change in swemwbs vs. comments (posts > 0 only)
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = comments, y = swemwbs_change)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm', formula = y~x)

# Change in swemwbs vs. likes (posts > 0 only)
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = likes, y = swemwbs_change)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm', formula = y~x)

# Change in swemwbs vs. number of external members (posts > 0 only)
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = external_members, y = swemwbs_change)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = 'lm', formula = y~x)

# Starting swemwbs vs. number of external members (posts > 0 only)
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = external_members, y = swemwbs_start_score)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = 'lm', formula = y~x)

# number of posts vs starting swemwbs vs. (posts > 0 only)
# i.e., do people who have higher swemwbs post more often? 
# (need to be careful with LM interpretation due to outliers)
ggplot(data = data_ns |> filter(posts > 0), aes(x = swemwbs_start_score, y = posts)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = 'lm', formula = y~x)
# Number of posts does not seem to be related to the start score
