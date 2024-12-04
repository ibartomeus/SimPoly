#https://rdrr.io/rforge/rspecies/man/rspecies.html
rspecies <-
  function(n, spp, b=rep(0, spp), x=rep(1, n), type=c("glm", "glm.nb", "glmm"),
           family=gaussian, sigma=1, cor=diag(1, n, n), theta=1,
           attrib=TRUE, seed=NULL)
  {
    if (!exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
      runif(1)
    if (is.null(seed))
      RNGstate <- get(".Random.seed", envir = .GlobalEnv)
    else {
      R.seed <- get(".Random.seed", envir = .GlobalEnv)
      set.seed(seed)
      RNGstate <- structure(seed, kind = as.list(RNGkind()))
      on.exit(assign(".Random.seed", R.seed, envir = .GlobalEnv))
    }
    type <- match.arg(type)
    if (is.function(family))
      family <- family()
    if (!(family$family %in% c("gaussian", "poisson", "binomial"))) {
      print(family)
      stop("'family' not allowed")
    }
    if (is.matrix(b)) {
      b <- lapply(1:spp, function(z) b[, z])
    }
    if (type == "glm.nb") {
      if (length(theta == 1))
        theta <- rep(theta, spp)
      lambda <- lapply(1:spp, function(i) pmax(exp(data.matrix(x) %*% b[[i]]), .Machine$double.eps))
      shape <- lapply(1:spp, function(i) lambda[[i]] / theta[i])
      y <- sapply(shape, function(z) rpois(n, rgamma(n, z, scale=theta)))
    } else {
      mu <- lapply(1:spp, function(i) data.matrix(x) %*% b[[i]])
      if (length(sigma == 1))
        sigma <- rep(sigma, spp)
      dia <- sigma^2
      if (type == "glmm") {
        SIGMA <- lapply(1:spp, function(i) dia[i] * cor)
        require(MASS)
        mu <- lapply(1:spp, function(i) MASS::mvrnorm(1, mu[[i]], SIGMA[[i]]))
      }
      if (family$family == "gaussian" && type == "glm") {
        y <- sapply(1:spp, function(i) rnorm(n, family$linkinv(mu[[i]]), dia[[i]]))
      } else {
        RFUN <- switch(family$family,
                       "gaussian" = function(z) return(z),
                       "poisson" = function(z) rpois(n, family$linkinv(z)),
                       "binomial" = function(z) rbinom(n, 1, family$linkinv(z)))
        y <- sapply(mu, RFUN)
      }
    }
    out <- matrix(y, n, spp)
    if (attrib) {
      class(out) <- c("rspecies", "matrix")
      attr(out, "call") <- match.call()
      attr(out, "seed") <- seed
    }
    out
  }

