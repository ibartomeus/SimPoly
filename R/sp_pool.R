#' Set species pool
#'
#' This function sets the species pool for a given region
#'
#' @param pool Numeric, number of species
#' @param rarest Numeric, true occupancy of the rarest species from 0-1
#' @param commonest Numeric, true occupancy of the commonest species from 0-1
#'
#' @return A list with a vector of species, and a vector of its distribution.
#' @export
#'
#' @examples
#' sp_pool(pool = 50, rarest = 0.05, commonest = 0.7)
sp_pool <- function(pool = 100, rarest = 0.05, commonest = 0.7){
  #defensive programming here (i.e. check if numeric and range)
  #set number of species
  #pool <- pool #100 is a lower number for an average MS
  #name them
  species <- paste0("Sp_", 1:pool)
  #assign to each species a distribution from widespread to rare.
  distrib <- runif(pool, rarest, commonest) #Default values assuming a max widespread of 70%
  #beta_distrib <- rbeta(pool, 1, 3)
  #hist(beta_distrib) #values of 1 - 3 give decent spread between 0.05 and 0.7
  list(species, distrib)
  }
