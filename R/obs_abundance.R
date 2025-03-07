#' Create observed abundances with detection error per site and year
#'
#' This function simulate sampling with a detection probability per species.
#'
#' @param true_abundance A data.frame, generated by true_abundances()
#' @param sp_responses A data.frame, generated by sp_responses()
#' @param fraction_observed numeric, the fraction of individuals present this day that can be observed. Default 0.5
#' @param noise_frac numeric, noise around fraction observed. Default 0.1
#' @param pantrap Logical, should pantraps be included? Default TRUE
#' @param n_pan numeric, number of pantraps deployed. Default 5
#'
#' @details For each species, site, year and round combination, individuals are sampled without replacement randomly
#'  proportional to its abundance, but weigthed by their probability of detection. the faction observed has built in
#'  noise accounting for "good nad "bad" years. Pantrap observations are
#'  modeled using a binomial distribution where each individual present has a probaility to falling/not falling
#'  in each pantrap. We report for each species, site, year and round, how many pantraps catch a give species.
#'
#' @note This function is slow.
#'
#'
#' @return A vector or data.frame.
#' @export
#'
#' @examples
#' site_years <- define_sites_years(nsp = 100, n_years = 3, n_sites = 10)
#' pars <- sp_responses(site_years = site_years)
#' abun <- true_abundance(n_round = 8,
#'                                  site_years = site_years,
#'                                  sp_responses = pars)
#' obs_abundance(true_abundance = abun, sp_responses = pars)
#'
obs_abundance <- function(true_abundance = NULL, sp_responses, fraction_observed = 0.5, noise_frac = 0.1, pantrap = TRUE, n_pan = 5){
  #set fraction of true abundance observed.
  #fraction_observed <- fraction_observed # we detect i.e. half the existing individuals that day
  #noise can be probably added? Not for now.
  sim_data <- true_abundance
  sim_data$species <- as.character(sim_data$species)
  true_abundance <-  NULL
  pars <- sp_responses
  sp_responses <- NULL
  rounds <- sort(unique(sim_data$jday))
  round_tesaurus <- data.frame(round = 1:length(rounds), jday = rounds)
  site_names <- unique(sim_data$siteID)
  n_years <- max(sim_data$year)
  #alternative that might be faster
  #Add detectabilities
  sim_data <- dplyr::left_join(sim_data, pars[,c("species", "detect", "detect_pan")], by = "species")
  #out <- data.frame(year = NA, siteID = NA, round = NA, jday = NA, species = NA, abundance = NA,
  #                  obs = NA, total_pantraps = NA, presences_pan = NA)
  #loop trough years
  out <- future.apply::future_lapply(1:n_years, function(k){
  #for(k in 1:n_years){
    year_temp <- subset(sim_data, year == k)
    #loop through sites
    siteRes <- lapply(1:length(site_names), function(j){
    #for(j in 1:length(site_names)){
      #select site i
      site_temp <- subset(year_temp, siteID == site_names[j])
      #loop through rounds
      #for(i in 1:max(sim_data$round)){
      roundRes <- lapply(1:max(sim_data$round), function(i){

        sr_temp <- subset(site_temp, round == i)
        #if there are records
        if(nrow(sr_temp) > 0 & sum(sr_temp$abundance) > 0){
          #expand the vector
          sampler <- reshape::untable(sr_temp[,c("year", "siteID", "round", "jday", "species", "detect")],
                   num = sr_temp[,c("abundance")])
          #calculate the number of individuals detected
          #max noise ranges from only observing 0.25 to 0.75.
          fraction_observed_noised <- fraction_observed * abs(rnorm(1, 1, noise_frac)) #fraction observed has noise by year only.
          sample_size <- ceiling(nrow(sampler)*fraction_observed_noised)
          sampler$detect <- round(sampler$detect, 3)
          sampler$detect <- ifelse(sampler$detect == 0, 0.01, sampler$detect)
          #and sample this number from the vector
          obs_raw <- sample(sampler$species, size =  sample_size,
                    replace = FALSE, prob = sampler$detect)
          #pool per sp again
          obs <- table(obs_raw)
          obs <- data.frame(species = names(obs), obs = as.vector(obs))
          sr_temp <- dplyr::left_join(sr_temp, obs, by = "species")
          sr_temp$obs[is.na(sr_temp$obs)] <- 0
          if(pantrap){
            sr_temp$total_pantraps <- n_pan
            #sample
            for(l in 1:length(sr_temp$species)){
              #calculate probability of detecting a species as function of sampling size
              pan_det_prob <- fast_ifelse(sr_temp$abundance[l] * sr_temp$detect_pan[l] < 1, sr_temp$abundance[l] * sr_temp$detect_pan[l], 1)
              per_pantrap <- rbinom(n = sr_temp$total_pantraps[l], size = 1, prob = pan_det_prob)
              sr_temp$presences_pan[l] <- sum(per_pantrap)
              #binomial process with n trials, where n is the number of pan trap
              #locations at each site. The outcome of this process is then the number of traps that contain the species of interest.
            }
          } else{
            sr_temp$total_pantraps <- NA
            sr_temp$presences_pan <- NA
          }
          #out <- dplyr::bind_rows(out, sr_temp[,c(1:6,9,10,11)])
        } else{
          sr_temp$obs <- 0
          if(pantrap){
            sr_temp$total_pantraps <- 0
            sr_temp$presences_pan <- 0
          } else{
            sr_temp$total_pantraps <- NA
            sr_temp$presences_pan <- NA
          }
          #out <- dplyr::bind_rows(out, sr_temp[,c(1:6,9,10,11)])
        }
        #print(paste("round", i ,"calculated at", Sys.time()))
        return(sr_temp[,c(1:6,9,10,11)])
      })
      #print(paste("site", j ,"calculated at", Sys.time()))
      return(do.call(rbind, roundRes))
    })
    print(paste("year", k ,"calculated at", Sys.time()))
    return(do.call(rbind, siteRes))
  }, future.seed=TRUE)
  out <- do.call(rbind, out)
}
