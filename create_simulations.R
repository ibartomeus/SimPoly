#create datasets

#Note simulations of 10 years - 40 sites are slow, about 1-2 minutes.
#Plan ahead when creating 100 scenarios in a loop.

#create data
library(SimPoly)
#example of a stable population with 3 year data-----
pool <- sp_pool(100)
site_years <- define_sites_years(pool = pool, n_years = 3, n_sites = 40,
                                 rich_mean = 40, rich_sd = 20)
pars <- sp_responses(site_years = site_years,
                     pheno_peak_mean = 120, pheno_peak_sd = 30,
                     pheno_range_mean = 30, pheno_range_sd = 15,
                     trend_max = 1.1, trend_min = 0.9)
abun <- true_abundance(rounds = 8, startmonth = 2, endmonth = 10,
                      site_years = site_years,
                      sp_responses = pars)
dat_obs <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = T, n_pan = 5)
dat_obs$obs2 <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = F)$obs

head(dat_obs)

#Use atributes to specify the scenarios.
attr(dat_obs, "trend") <- "no"
attr(dat_obs, "pantraps") <- "5"
attr(dat_obs, "transects") <- "2"
attr(dat_obs, "rounds") <- "8"
attr(dat_obs, "sites") <- "40"
attr(dat_obs, "years") <- "3"
attr(dat_obs, "sp_pool") <- "100"

str(dat_obs)

#save data as rds

saveRDS(dat_obs, "outputs/test_100sp3y40si8r2tr5ptOtrend.rds")


#example of a stable population with 10 year data----
pool <- sp_pool(100)
site_years <- define_sites_years(pool = pool, n_years = 10, n_sites = 40,
                                 rich_mean = 40, rich_sd = 20)
pars <- sp_responses(site_years = site_years,
                     pheno_peak_mean = 120, pheno_peak_sd = 30,
                     pheno_range_mean = 30, pheno_range_sd = 15,
                     trend_max = 1.1, trend_min = 0.9)
abun <- true_abundance(rounds = 8, startmonth = 2, endmonth = 10,
                       site_years = site_years,
                       sp_responses = pars)
dat_obs <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = T, n_pan = 5)
dat_obs$obs2 <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = F)$obs

head(dat_obs); tail(dat_obs)

#Use atributes to specify the scenarios.
attr(dat_obs, "trend") <- "no"
attr(dat_obs, "pantraps") <- "5"
attr(dat_obs, "transects") <- "2"
attr(dat_obs, "rounds") <- "8"
attr(dat_obs, "sites") <- "40"
attr(dat_obs, "years") <- "10"
attr(dat_obs, "sp_pool") <- "100"

str(dat_obs)

#save data as rds

saveRDS(dat_obs, "outputs/test_100sp10y40si8r2tr5ptOtrend.rds")

#example of a declining population with 6 year data----
pool <- sp_pool(100)
site_years <- define_sites_years(pool = pool, n_years = 6, n_sites = 40,
                                 rich_mean = 40, rich_sd = 20)
pars <- sp_responses(site_years = site_years,
                     pheno_peak_mean = 120, pheno_peak_sd = 30,
                     pheno_range_mean = 30, pheno_range_sd = 15,
                     trend_max = 1, trend_min = 0.7)
abun <- true_abundance(rounds = 8, startmonth = 2, endmonth = 10,
                       site_years = site_years,
                       sp_responses = pars)
dat_obs <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = T, n_pan = 5)
dat_obs$obs2 <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = F)$obs

head(dat_obs); tail(dat_obs)

#test if trend is visible
s_dat <- summary_poms(dat_obs, var_name = "obs")
head(s_dat)
scatter.smooth(s_dat$obs_abund ~ s_dat$year, las = 1)

#Use atributes to specify the scenarios.
attr(dat_obs, "trend") <- "declining"
attr(dat_obs, "pantraps") <- "5"
attr(dat_obs, "transects") <- "2"
attr(dat_obs, "rounds") <- "8"
attr(dat_obs, "sites") <- "40"
attr(dat_obs, "years") <- "6"
attr(dat_obs, "sp_pool") <- "100"

str(dat_obs)

#save data as rds

saveRDS(dat_obs, "outputs/test_100sp6y40si8r2tr5ptNtrend.rds")


#example of a declining population with 6 year of data and 15 sites and 10 pantraps----
pool <- sp_pool(100)
site_years <- define_sites_years(pool = pool, n_years = 6, n_sites = 15,
                                 rich_mean = 40, rich_sd = 20)
pars <- sp_responses(site_years = site_years,
                     pheno_peak_mean = 120, pheno_peak_sd = 30,
                     pheno_range_mean = 30, pheno_range_sd = 15,
                     trend_max = 1, trend_min = 0.7)
abun <- true_abundance(rounds = 8, startmonth = 2, endmonth = 10,
                       site_years = site_years,
                       sp_responses = pars)
dat_obs <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = T, n_pan = 10)
dat_obs$obs2 <- obs_abundance(true_abundance = abun, sp_responses = pars, pantrap = F)$obs

head(dat_obs); tail(dat_obs)

#test if trend is visible
s_dat <- summary_poms(dat_obs, var_name = "obs")
head(s_dat)
scatter.smooth(s_dat$obs_abund ~ s_dat$year, las = 1)

#Use atributes to specify the scenarios.
attr(dat_obs, "trend") <- "declining"
attr(dat_obs, "pantraps") <- "10"
attr(dat_obs, "transects") <- "2"
attr(dat_obs, "rounds") <- "8"
attr(dat_obs, "sites") <- "15"
attr(dat_obs, "years") <- "6"
attr(dat_obs, "sp_pool") <- "100"

str(dat_obs)

#save data as rds

saveRDS(dat_obs, "outputs/test_100sp6y15si8r2tr10ptNtrend.rds")

