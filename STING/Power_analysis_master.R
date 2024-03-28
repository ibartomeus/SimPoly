## This script aims to answer which sample size is needed to detect a given decline per MS.
## Original code prepared by Nick Isaac on 2020-03-19; minimally adapted by Chiara Polce
## to plot and save the results for the 27 MS and further edited by Nacho Bartomeus.

## install/load these libraries----

library(reshape2)
library(ggplot2)
library(gridExtra)
library(tidyverse)
library(ggforce)

## Read the results----
# Results generated using SimPoly 1.3 with parameters read from XXXX.csv file and run with XXX.R file.
# Chiara, can you fill the XXXX above and send to me those files to keep them toguether?

resultsdir <-"STING/All_Results/"
resFiles <- list.files(resultsdir, recursive = TRUE)
length(resFiles) #[1] 6480
## There are 810 files of results: 27MS * 10 replicates * 3 trends * 8 levels of number of sites

## Read them all into one object (list)

results <- lapply(resFiles, function(filename) {
  readRDS(file.path(resultsdir, filename))
})

#explore the data structure
str(results[[1]])
results[[1]]$md$simpars #trend is pre-calculated here,
    #and IB thinks can be re-interpreted to 1%, 5% 10% as here we are using a wrong parameter.
    #done below.

## Prepare output----
## Create a dataframe with one row per simulation file. Populate it initially
# from the data object
data <- lapply(results, function(x) cbind(name  = x$outFileName, x$md$simpars, x$md$settings))
data <- do.call(rbind, data)
## There is some information stored in the name of the file that was not captured in the metadata. Extract this.

temp <- strsplit(data$name, split = "_")
data$MS <- sapply(temp, function(x) x[[1]])
#nSite is not updated in the file names; this can be possible fixed during the process, but IB is
    #fixing it below.
#data$nSite <- as.numeric(gsub(sapply(temp, function(x) x[[4]]), patt = "sites", repl=""))
data$nSite <- NA
data$replicate <- as.numeric(sapply(temp, function(x) x[[7]]))

## Take a look at the contents

str(data)
summary(data)

## The trend is the multispecies growth rate per year fixed at 1, 5 and 10%. See below.
## Note that all files in this set have the same number of transects, rounds and years.
## As noted above, the true trend might be not properly calculated.

## Trend Estimates-----
## First, define a function to extract the information we want to get from each file.

getStats <- function(x, nsim = 100) {
  eff <- x$modelEff
  # simulate a distribution of values given
  temp <- apply(eff, 1, function(sptrend) {
    rnorm(n = nsim, mean = sptrend["Estimate"], sd = sptrend["Std. Error"])
  })
  ms_post <- apply(temp, 1, mean)
  return(ms_post)
}

## This function returns four numbers:
## - The first column is a simple mean across species.
## - The second column is the mean accounting for uncertainty in the species trends.
## - The third column is the standard deviation around that mean (a quasi-Bayesian estimate).
## - This fourth column is the proportion of the simulated multispecies trends that are below zero
## There is also an attribute (post) that contains the full distribution.

#eff <- results[[1]]$modelEff #for debuging
getStats(results[[1]], nsim = 10)

# The function only returns the simple mean as far as IB can tell.

#Calculate mean trend for 200 sims
temp <- do.call(rbind, lapply(results, getStats, nsim=200))
str(temp)

#Add the trend estimate and sd
data$meanTrendEst <- apply(temp, 1, mean)
data$sdTrendEst <- apply(temp, 1, sd)

#Fix number of sites
unique(data$sites)
data$nSite <- data$sites
data$nSite <- ifelse(data$nSite > 350, 400, data$nSite)
data$nSite <- ifelse(data$nSite > 300 & data$nSite < 350, 350, data$nSite)
data$nSite <- ifelse(data$nSite > 250 & data$nSite < 300, 300, data$nSite)
unique(data$nSite)

#Fix the trends issue:
unique(data$trend)
data$Ttrend <- ifelse(data$trend == 0.91, -0.10, NA)
data$Ttrend <- ifelse(data$trend == 1.00, -0.01, data$Ttrend)
data$Ttrend <- ifelse(data$trend == 0.96, -0.05, data$Ttrend)

#calculate a simple measure of error
data$error <- abs(data$Ttrend - data$meanTrendEst)

#a manual example to see how it goes
#head(data)
data01AU <- subset(data, Ttrend == -0.10 & MS == "AU")
scatter.smooth(data01AU$error ~ data01AU$nSite)
abline(h = 0.01, col = "red") # a plausible margin of error
data005AU <- subset(data, Ttrend == -0.05 & MS == "AU")
scatter.smooth(data005AU$error ~ data005AU$nSite)
abline(h = 0.01, col = "red")
data001AU <- subset(data, Ttrend == -0.01 & MS == "AU")
scatter.smooth(data001AU$error ~ data001AU$nSite)
abline(h = 0.01, col = "red")

#Several ways to calculate power... but n = 10 replicates...
#Which % meanTrendEst have less than 0.01 absolute error.
data$power <- ifelse(data$Ttrend == -0.1 & data$error < 0.01, 1, 0)
data$power <- ifelse(data$Ttrend == -0.05 & data$error < 0.01, 1, data$power)
data$power <- ifelse(data$Ttrend == -0.01 & data$error < 0.01, 1, data$power)

#Or which true trend falls outside % meanTrendEst + sdTrendEst
#This option gives very low power overall, and no trend with nSite
#data$power <- ifelse(data$Ttrend == -0.1 &
 #                      (data$meanTrendEst - data$sdTrendEst) < -0.1 &
  #                     -0.1 < (data$meanTrendEst + data$sdTrendEst), 1, 0)
#data$power <- ifelse(data$Ttrend == -0.05 &
 #                      (data$meanTrendEst - data$sdTrendEst) < -0.05 &
  #                     -0.05 < (data$meanTrendEst + data$sdTrendEst), 1, data$power)
#data$power <- ifelse(data$Ttrend == -0.01 &
 #                      (data$meanTrendEst - data$sdTrendEst) < -0.01 &
  #                     -0.01 < (data$meanTrendEst + data$sdTrendEst), 1, data$power)

powers <- dcast(data = data, formula = MS + nSite + Ttrend ~ "power", value.var = "power", fun.aggregate = function(x){sum(x)/length(x)})

for(i in unique(powers$MS)){
  for(j in unique(powers$Ttrend)){
  temp <- subset(powers, MS == i & Ttrend == j)
  plot(temp$power ~ temp$nSite, main = paste(i, j), ylim = c(0,1), las = 1)
  abline(h = 0.8, col = "red")
  }
}
#Note power not always scales monotonically with nSite!! BUT n= 10


#And raw error
powers <- dcast(data = data, formula = MS + nSite + Ttrend ~ "error", value.var = "error", fun.aggregate = function(x){mean(x)})

for(i in unique(powers$MS)){
  for(j in unique(powers$Ttrend)){
    temp <- subset(powers, MS == i & Ttrend == j)
    plot(temp$error ~ temp$nSite, main = paste(i, j), ylim = c(0,0.05), las = 1)
    abline(h = 0.01, col = "red")
  }
}
#In this case, error doeas not decrease much with sSites







### OLD code by Nick / Chiara adapted to different number of sites...----
fullPost <- melt(cbind(data[,c("trend","MS","sites","replicate")], temp), id=1:4)
fullPost$MS_sites <- paste(fullPost$MS, fullPost$sites, sep = "_")

#fix sites levels
unique(fullPost$sites)
fullPost$nSite <- fullPost$sites
fullPost$nSite <- ifelse(fullPost$nSite > 350, 400, fullPost$nSite)
fullPost$nSite <- ifelse(fullPost$nSite > 300 & fullPost$nSite < 350, 350, fullPost$nSite)
fullPost$nSite <- ifelse(fullPost$nSite > 250 & fullPost$nSite < 300, 300, fullPost$nSite)
unique(fullPost$nSite)

#Fix the trends issue:
unique(fullPost$trend)
fullPost$Ttrend <- ifelse(fullPost$trend == 0.91, -0.05, NA)
fullPost$Ttrend <- ifelse(fullPost$trend == 1.00, -0.01, fullPost$Ttrend)
fullPost$Ttrend <- ifelse(fullPost$trend == 0.96, -0.10, fullPost$Ttrend)
head(fullPost)

#Calculate error
fullPost$error <- fullPost$Ttrend - fullPost$value
fullPost$RMSE <- sqrt((fullPost$Ttrend - fullPost$value)*(fullPost$Ttrend - fullPost$value))
fullPost[which(fullPost$RMSE > 5),] #nice
hist(fullPost$RMSE)

#subset trend = 0.1
fullPost01AU <- subset(fullPost, Ttrend == -0.10 & MS == "AU")
str(fullPost01AU)
scatter.smooth(fullPost01AU$error ~ fullPost01AU$nSite)

#OLD summary without sites....
summary <- acast(fullPost %>%
                   group_by(MS, trend) %>%
                   summarise(pNeg = mean(value < 0)),
                 MS~trend, value.var = "pNeg")


## Saving summary and full data:
write.csv(summary, "Power_400.csv", row.names = TRUE)
write.csv(fullPost, "fullPost_400.csv", row.names = F)


## Plot the results and save them to multiple pages pdf

n_pages <- ceiling(
  length(unique(fullPost$MS_sites)) /3)

n_pages
pdf("All_Results.pdf", onefile = T)
for (i in seq_len(n_pages)){
  print(ggplot(data = fullPost, aes(x=value, col=factor(trend))) +
        geom_freqpoly(bins=100) +
        facet_wrap_paginate (~MS_sites, nrow = 3, ncol = 1, page = i) +
        geom_vline(aes(xintercept = log(trend), col=factor(trend))) +
        theme_bw() +
        xlab("trend estimate"))
}
dev.off()

## This is a bit noisy. Let’s put the individual replicates on the plot:

bp <- ggplot(data = fullPost, aes(x=value, col=factor(replicate))) +
  geom_freqpoly(bins=100) +
  facet_grid(trend~MS) +
  geom_vline(aes(xintercept = log(trend))) +
  theme_bw() +
  xlab("trend estimate")

## Split the plots to multiple-pages pdf
n_pages <- ceiling(
  length(unique(fullPost$trend)) * length(unique(fullPost$MS)) /2)

pdf("Results_400sites_10repl.pdf", onefile = T)
for (i in seq_len(n_pages)) {
  print(ggplot(data = fullPost, aes(x=value, col=factor(replicate))) +
          geom_freqpoly(bins=100) +
          facet_wrap_paginate(trend~MS,nrow = 2, ncol = 1, page = i) +
          geom_vline(aes(xintercept = log(trend))) +
          theme_bw() +
          xlab("trend estimate"))
}
dev.off()





