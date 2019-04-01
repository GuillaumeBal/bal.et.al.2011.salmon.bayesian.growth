rm(list = ls())

require(magrittr)
require(R2jags)

wd <- "C:/Users/gbal/Desktop/salmon.bayesian.growth" %T>% setwd()

# create simulations
"1.data.sim.r" %>% source

#fit model
"2.vbgm.fit.r" %>% source