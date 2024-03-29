% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sp_responses.R
\name{sp_responses}
\alias{sp_responses}
\title{Create species responses}
\usage{
sp_responses(
  site_years,
  pheno_peak_mean = 120,
  pheno_peak_sd = 50,
  pheno_range_mean = 25,
  pheno_range_sd = 5,
  trend_max = 1.1,
  trend_min = 0.9,
  meanlog = 3.5,
  sdlog = 0.6
)
}
\arguments{
\item{site_years}{A data.frame, generated by define_sites_years()}

\item{pheno_peak_mean}{Numeric, mean of the species phenology peak (in days from 1-365)}

\item{pheno_peak_sd}{Numeric, sd of the species phenology peak}

\item{pheno_range_mean}{Numeric, mean of the species phenology ranges}

\item{pheno_range_sd}{Numeric, sd of the species phenology ranges}

\item{trend_max}{Numeric, minimum slope of linear decline per year. Take values between 0 and infinite, with values < 1 implying declines.}

\item{trend_min}{Numeric, máximum slope of linear decline per year. Take values between 0 and infinite, with values < 1 implying declines.}

\item{meanlog}{Numeric, parameter of the lognormal distribution to generate species abundances. Default 3}

\item{sdlog}{Numeric, parameter of the lognormal distribution to generate species abundances. Default 0.8}
}
\value{
A data.frame.
}
\description{
This function defines for each species its phenology, typical abundance, detectablity and temporal trend.
}
\details{
Species phenological peak activity and phenological range are normally distributed using the provided means and sd.
Species peak abundances are calculated from a lognormal distribution with meanlog = 3 and sdlog = 0.8. This creates
abundance distributions mirroring empirical observed patterns, and within the range of the expected
absolute values for pollinators. Species responses are drawn from an uniform distribution according to the maximum and minimum
values provided. Finally, species detectabilities follow a beta distribution with alpha = 1 and beta = 2
and the probability of detecting an individual in a pantrap (p) is calculated from
p = 1-(1-q)^N, where q is the number of pantraps deployed and N the population abundances,
using TERENO project data we estimate q and N values. According to this data, p is
gamma-distributed with Shape = 1.221913, Rate = 140.532379 and Scale: 0.007115798.
}
\examples{
pool <- sp_pool(50)
site_years <- define_sites_years(pool = pool, n_years = 3, n_sites = 10)
sp_responses(site_years = site_years)
}
