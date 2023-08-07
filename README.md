
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SimPoly

The goal of SimPoly is to simulate a EU-PoMS like datasets with known
parameters and apropiate built in stochasticity.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("EcologyR/ibartomeus/SimPoly")
```

## Example

This is a basic example to show how we build one dataset:

``` r
# library(SimPoly)
#First we define the number of species, sites and years to simulate.
site_years <- define_sites_years(pool = sp_pool(pool = 100, 
                                                rarest = 0.05, commonest = 0.7),
                   n_years = 3, n_sites = 10)
head(site_years)
#Second, we specify species attributes such as phenology, abundance and detectability
pars <- sp_responses(site_years = site_years,
               pheno_peak_mean = 120, pheno_peak_sd = 50,
               pheno_range_mean = 25, pheno_range_sd = 5,
               trend_max = 0, trend_min = -2)
head(pars)
#Third, we sample the true abundance values expected at each sampling point.
dat <- true_abundance(rounds = 8,
                      site_years = site_years,
                      sp_responses = pars)
head(dat)
#Finally, we sample with detection error from the true values.
dat_obs <- obs_abundance(true_abundance = dat, sp_responses = pars)
head(dat_obs)
#We can simulate a second transect
dat_obs$obs2 <- obs_abundance(true_abundance = dat, sp_responses = pars)$obs #note order is preserved
head(dat_obs)
plot(dat_obs$obs, dat_obs$obs2) #nice expected correlation.
#Or pan traps. Let's assume a different detectability
pars_pantrap <- pars
pars_pantrap$detect <- runif(n = length(pars_pantrap$detect)) #this assume independent detectabilities
dat_obs$obs_pantrap <- obs_abundance(true_abundance = dat, sp_responses = pars_pantrap)$obs #note order is preserved
#this is the final output
head(dat_obs)
plot(dat_obs$abundance, dat_obs$obs, las = 1, xlim = c(0,max(dat_obs$abundance)), 
     ylim = c(0,max(dat_obs$abundance))) 
#you can summarize observed variables per species, site and year
s_dat <- summary_poms(dat_obs, var_name = "obs")
head(s_dat)
scatter.smooth(s_dat$obs_abund ~ s_dat$year)
#This can be easily loop to obtain several simulations
```

## Citation

If using this package, please cite it:

``` r
citation("SimPoly")

To cite SimPoly in publications use:

  Bartomeus I, 2023. SimPoly. https://github.com/ibartomeus/SimPoly

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {SimPoly},
    author = {Ignasi Bartomeus},
    year = {2023},
    url = {https://github.com/ibartomeus/SimPoly},
  }
```

## Acknowledgements

STING
