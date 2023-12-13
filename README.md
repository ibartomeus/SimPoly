
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8223668.svg)](https://doi.org/10.5281/zenodo.8223668)

# SimPoly

The goal of SimPoly is to simulate a EU-PoMS like datasets with known
parameters and appropriate built in stochasticity.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("ibartomeus/SimPoly")
```

## Example

``` r
library(SimPoly)
set.seed(32468)
```

This is a basic example to show how we build one dataset:

First we define the number of species, sites and years to simulate. We
do this using the `define_sites_years()` functions. The `pool` argument
is a call to `sp_pool()`, which simply defines the number of species
(here `pool = 100`), and the occupancy of the `rarest` and `commonest`
species.

``` r
site_years <- define_sites_years(pool = sp_pool(pool = 1000, 
                                                mean_occ = 0.25),
                                 n_years = 7, n_sites = 100)
```

Let’s take a closer look at the data.

``` r
str(site_years)
head(site_years)
length(unique(site_years$siteID))
length(unique(site_years$species))
```

Note that the number of species in the dataset is only `89`, compared
with `100` in the species pool. This reflects stochasticity in how the
species are assigned to sites.

Second, we specify species attributes such as phenology, abundance and
detectability

``` r
pars <- sp_responses(site_years = site_years,
                     pheno_peak_mean = 120, pheno_peak_sd = 50,
                     pheno_range_mean = 25, pheno_range_sd = 5,
                     trend_max = 1, trend_min = 0.8)
str(pars)
hist(pars$h)
head(pars)
```

There is one row per species, with the following columns:  
`opt` = day since 1 january of maximum abundance.  
`tol` = spread -\> range. `h` = expected species abundance along a
dominant-rare log normal distribution.  
`slope` = trend in abundance per year on the abundance scale.  
`detect` = detectability in probability of a species being detected in a
transect (independent of its abundance).  
`detect_pan` = detectability in probability of a specimen falling in a
pantrap.

Third, we sample the true abundance values expected at each sampling
point.

``` r
dat <- true_abundance(n_round = 8,
                      site_years = site_years,
                      sp_responses = pars, white_noiseCV = 0.5)
str(dat)
head(dat)
```

There as many observations per species per site.  
`year`: an integer from 1-3 (as defined by n_years, above). `siteID`:
which site is it. `round`: month of the year of this survey. `species`:
which species.  
`abundance`: abundance during that visit.

From this table we can calculate species richness per site

``` r
library(reshape2)
(rich <- dcast(dat, siteID ~ "richness", value.var = 'species', function(x) length(unique(x))))
#and persistance (% of years where the species is present)
hist((persistence <- dcast(dat, siteID + species ~ "persistence", value.var = 'abundance', function(x) length(which(x == 0))/length(x)))$persistence, las = 1)
#average persistence over rounds, not over years.
yearly <- dcast(dat, year + siteID + species ~ "abundance", value.var = 'abundance', sum)
hist(yearly$abundance) #up to 400 indiv per year seems realistic
hist((persistence <- dcast(yearly, siteID + species ~ "persistence", value.var = 'abundance', function(x) length(which(x == 0))/length(x)))$persistence, las = 1)
```

Finally, we sample with detection error from the true values.

``` r
dat_obs <- obs_abundance(true_abundance = dat, sp_responses = pars, fraction_observed = 0.1)
head(dat_obs)
plot(dat_obs$obs, dat_obs$abundance) #nice expected correlation, but more noisy.
plot(dat_obs$obs, dat_obs$presences_pan) #nice expected correlation, but more noisy.
```

We can simulate a second transect if desired:

``` r
dat_obs$obs2 <- obs_abundance(true_abundance = dat, sp_responses = pars, fraction_observed = 0.1)$obs #note order is preserved
head(dat_obs)
plot(dat_obs$obs, dat_obs$obs2) #nice expected correlation.
```

This is the final output:

``` r
head(dat_obs)
```

``` r
plot(dat_obs$abundance ~ dat_obs$obs, las = 1, xlim = c(0,max(dat_obs$abundance)), 
     ylim = c(0,max(dat_obs$abundance))) 
#you can summarize observed variables per species, site and year
s_dat <- summary_poms(dat_obs, var_name = "obs")
head(s_dat)
scatter.smooth(s_dat$obs_abund ~ s_dat$year, las = 1)
#This can be easily loop to obtain several simulations
```

## Citation

If using this package, please cite it:

``` r
citation("SimPoly")

To cite SimPoly in publications use:

  Bartomeus I, Isaac N and Schweiger O. 2023. SimPoly: Generating
  EU-PoMS like datasets https://github.com/ibartomeus/SimPoly

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {SimPoly: Generating EU-PoMS like datasets},
    author = {Ignasi Bartomeus and Nick Isaac and Oliver Schweiger},
    year = {2023},
    url = {https://github.com/ibartomeus/SimPoly},
  }
```

## Acknowledgements

STING, JRC and specially Nick Isaac and Oliver Schweiger and the
coenocliner package.
