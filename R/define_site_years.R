#' Create n sites sampled over t years
#'
#' This function creates for a given species pool, a data.frame of species observed per site and year.
#'
#' @param nsp Numeric, number of species in the region.
#' @param n_years Numeric, number of years
#' @param n_sites Numeric, number of sites (imagine a lattice)
#' @param heterogeneity A number of environmental heterogeneity expected across sites.
#' It can be read as an SD across MS with LX close to 0 and Spain ~1. If MS values are in another scale,
#' we can remove the minimum and divide by max to get 0-1 scale
#'
#' @return A data.frame.
#' @export
#'
#' @details  We use the function rspecies to create a matrix of sites per species, where each species occurrs
#' in different sites according to their distribution (asumer normal occupancies) and sites show more or less similar
#' community composition depending on an envoronmental gradient. Note that we
#' assume no immigration / emigration.
#'
#' @examples
#' define_sites_years(nsp = 100, n_years = 3, n_sites = 10, heterogeneity = 1)
define_sites_years <- function(nsp, n_years, n_sites,
                               heterogeneity = 1){
  #defensive programming here (i.e. check if numeric and range)
  #source("R/Rspecies.R")
  spCoef <- t(data.frame(a = rnorm(n=nsp, mean=-2.5), b= sort(rnorm(nsp))))
  #a = average occ
  #b = species responses to gradient (normal)
  #define the values of the site
  siteSD <- heterogeneity # this parameter defines the heterogeneity among sites.
  siteDat <- data.frame(a = rep(1, n_sites), b = rnorm(n=n_sites, sd=siteSD))
  #a intercept per site (always 1)
  #b is the gradient...
  # get the linear predictor
  lp <- rspecies(n = n_sites, spp = nsp,
                 b = spCoef, x = siteDat)
  # convert to a probability of occupancy
  pOcc <- boot::inv.logit(lp)
  # convert to occupancy
  occ <- t(apply(pOcc, 1, rbinom, n=nsp, size=1))
  #make a list
  data <- melt(occ) #var 1 site, var2 species, value presnece.
  colnames(data) <- c("siteID", "species", "presence")
  data$siteID <- paste0("site_", data$siteID)
  data <- subset(data, presence == 1)
  data <- data[,-3]
  #hist(tapply(data$siteID, as.factor(data$species), length))
  print(paste("FYI, richness mean is:", mean(tapply(data$siteID, as.factor(data$species), length))))
  data$species <- paste0("Sp_", data$species)

  #And then simply stack as many years as needed
  #We assume no immigration / emigration at this point. i.e. closed populations
  #But species can get extinct over time (see next functions).
  data$year <- 1 #fill first year
  base <- data
  for(i in 1:(n_years-1)){
    newdata <- base
    newdata$year <- i+1
    data <- rbind(data, newdata)
  }
  #head(data)
  data
}
