# Functions for cleaning and manipulating Noise Solution data
# Gabrielle M. Schroeder
# August 2024

library(dplyr)
library(readxl)
library(janitor)

# Load and prep Noise Solution data
load_and_prep_noise_solution_data <- function(file_ns) {
  data_ns <- read_xls(file_ns)
  
  # Clean variable names
  data_ns <- janitor::clean_names(data_ns)
  
  # Sort by ID and add session number from 1 to n
  data_ns <- data_ns |>
    dplyr::arrange(uin) |>
    dplyr::mutate(id = row_number()) # session id
  # duplicate UINs are repeat sessions with the same participant
  
  return(data_ns)
}

# Compute change in SWEMWBS score
compute_swemwbs_change <- function(data_ns) {
  
  # Compute change in swemwbs
  data_ns <- data_ns |>
    dplyr::mutate(
      # Change
      swemwbs_change = swemwbs_end_score - swemwbs_start_score,
      # Whether score increased (boolean)
      swemwbs_increased = swemwbs_change > 0
    )
  
  return(data_ns)
}

