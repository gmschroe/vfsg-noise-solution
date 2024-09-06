# Define plot colours
# Gabrielle M. Schroeder

get_plot_clrs <- function(){
  clrs <- list()
  
  clrs$map_neg <- c(
    '#e000a1',
    '#f6008c',
    '#ff2176',
    '#ff3e61',
    '#ff594d',
    '#ff733a'
  )
  clrs$map_neg <- rev(clrs$map_neg)
  
  clrs$map_pos <- c(
    '#009de0',
    '#00b2ee',
    '#00c5ed',
    '#00d6db',
    '#00e6bb',
    '#00f290'
  )

  clrs$acid_green <- c("#beff00")
  clrs$violet <- c("#8c5cff")
  clrs$white <- c("white")
  clrs$light_grey <- c("#caced0")
  clrs$background <- c("#091116") 
    
  return(clrs)
}