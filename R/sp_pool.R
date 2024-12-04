#' Set species pool
#'
#' This function sets the species pool for a given region. Currently not used.
#'
#' @param pool Numeric, number of species to simulate
#' @param mean_occ Numeric, DEPRECIATED; mean expected occupancy (0-1). Default 0.25, which creates realistic occupancy values ranging from 0 to ~0.75
#'
#' @return A list with a vector of species, and a vector of its distribution.
#' @export
#'
#' @details Species distribution follow a beta distribution. The beta distribution
#' has two parameters. We fixed alpha to 1 and calculate beta from the desired mean occupancy.
#' This distribution ensures most species have narrow distributions and there are few widespread
#' species, as expected based on bee ecological knowledge. In the current implementation distribution is not used.
#'
#' @examples
#' sp_pool(pool = 50, mean_occ = 0.25)
sp_pool <- function(pool = 100, mean_occ = 0.25){
  #defensive programming here (i.e. check if numeric and range)
  #set number of species
  #pool <- pool # 100 is a lower number for an average MS
  #name them
  species <- paste0("Sp_", 1:pool)
  #we fix alpha to ensure a left skewed distribution (most species are rare)
  alpha <-  1
  #calculate beta knowing mean_occ = alpha / alpha+beta
  beta <- (alpha -alpha*mean_occ)/mean_occ
  distrib <- rbeta(pool, alpha, beta)
  #hist(rbeta(1000, 1, 3)) #values of 1 - 3 give decent spread between 0.05 and 0.7
  list(species, distrib)
  }
