
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8223668.svg)](https://doi.org/10.5281/zenodo.8223668)

# SimPoly

The goal of SimPoly is to simulate a EU-PoMS like datasets with known
parameters and appropriate built in stochasticity. The only goal is to explore 
how different types of variability affect model performance under strong simplified assumptions 
and should be interpreted as such. 

DISCLAIMER: This is work in progress and the assumptions used to build the simulations can be enhanced. 

##Example

See `README.Rmd`

## Installation

``` r
# install.packages("devtools")
devtools::install_github("ibartomeus/SimPoly")
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
