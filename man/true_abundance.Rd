% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/true_abundance.R
\name{true_abundance}
\alias{true_abundance}
\title{Create true abundances per site and year}
\usage{
true_abundance(
  n_round = 8,
  startmonth = 2,
  endmonth = 10,
  site_years = NA,
  sp_responses = NA,
  white_noiseCV = 0.5
)
}
\arguments{
\item{n_round}{Numeric. Number of sampling rounds. Default to 8.}

\item{startmonth}{Numeric. Number of month starting to sample. Default to 2.}

\item{endmonth}{Numeric. Number of month stopping to sample. Default to 10.}

\item{site_years}{A data.frame, generated by define_sites_years()}

\item{sp_responses}{A data.frame, generated by sp_responses()}

\item{white_noiseCV}{Numeric, the expected CV across years. Default to 0.5 (use values 0-1)}
}
\value{
A data.frame.
}
\description{
This function calculate true abundance in each sampling round.
}
\details{
Rounds are distributed homogeneously across the sampling period. Natural yearly fluctuations
(i.e. white noise) are assumed to follow a normal distribution with a mean corresponding to the species
peak abundance and sd calculated from the provided coeficient of variation. Hence, we add white noise
proportional to species abundances. Based on Tereno and BeeFun data, expected CV is around 0.5. Negative values are truncated to 0. Population trends (i.e. red noise)
are incorporated to each species and year by multiplying the species mean abundance by the provided slope
of the linear trend and the number of years modeled. Hence, the more years, the larger the change expected.
Finally, we use coenocliner package to calculate for each species a gausian abundance distribution along each year
with the calculated species peak abundance for each year and site, and its phenological peak and range. From this
distribution we sample at each round using a negative binomial count model. This gives us for each species, site, year
and round a value for the expecued true abundance.
}
\examples{
site_years <- define_sites_years(nsp = 100, n_years = 3, n_sites = 10)
pars <- sp_responses(site_years = site_years)
true_abundance(n_round = 8,
               site_years = site_years,
               sp_responses = pars)
}
