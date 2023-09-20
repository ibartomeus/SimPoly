#' Set species pool
#'
#' This function sets the species pool for a given region
#'
#' @param pool Numeric, number of species
#' @param mean_occ Numeric, mean expected occupancy (0-1). Default 0.25, which creates occupancy values ranging from 0 to ~0.75
#'
#' @return A list with a vector of species, and a vector of its distribution.
#' @export
#'
#' @examples
#' sp_pool(pool = 50, mean_occ = 0.25)
sp_pool <- function(pool = 100, mean_occ = 0.25){
  #defensive programming here (i.e. check if numeric and range)
  #set number of species
  #pool <- pool #100 is a lower number for an average MS
  #name them
  species <- paste0("Sp_", 1:pool)
  #we fix alpha to ensure a left skewed distribution (most species are rare)
  alpha <-  1
  #calculate beta knowing mean_occ = alpha / alpha+beta
  beta <- (alpha -alpha*mean_occ)/mean_occ
  distrib <- rbeta(pool, alpha, beta) #1,3
  #hist(rbeta(pool, 1, 2.3)) #values of 1 - 3 give decent spread between 0.05 and 0.7
  list(species, distrib)
  }
