# run jags ======================================================================

# make data.frame from data 
fish.data.df <- fish.data %>% as.data.frame()

# data formatted for jags
jags.data <- list('l.obs' = fish.data.df[ , c("length.1", "length.2")] %>% as.matrix,
                  'n.obs' = fish.data.df %>% dim %>% `[`(1),
                  'n.years' = n.years,
                  'year.obs' = fish.data.df$year,
                  'dens' = fish.data.df$dens,
                  'wt' = wt.temp,
                  'dates.delta' = fish.data.df$date.delta,
                  'day.fished.year' = fish.data.df[ , c("date.1", "date.2")] %>% `names<-`(NULL) %>% .[duplicated(.) == FALSE, ] %>% as.matrix(),
                  'dates.delta.year' = fish.data.df$date.delta %>% `[`(fish.data.df$year %>% duplicated() %>% `!`),
                  't.min' = t.min,
                  't.max' = t.max,
                  't.opt' = t.opt)

# parameters saved
jags.par <- c('l.inf', 'k.opt', 'beta.dens', 'sd.vbgm')

# model file name
jags.model <- 'model.vb.dens.temp.txt'

# MCMC settings
mcmc.burn <- as.integer(10000)
mcmc.chainLength <- as.integer(20000)  # burn-in plus post-burn
mcmc.thin = 5
mcmc.chains = 3 # needs to be at least 2 for DIC

### run model
jags.outputs <- jags(jags.data, parameters.to.save = jags.par, model.file = jags.model, 
                     n.chains = mcmc.chains, n.burnin = mcmc.burn, n.thin = mcmc.thin, n.iter = mcmc.chainLength,
                     refresh = mcmc.burn / 20,
                     #digits = 1,
                     #inits = jags.inits,
                     DIC = TRUE) 

# jags outputs =======================================================================

print(jags.outputs)

# some visual checks
par(mfrow = c(2, 2))
jags.outputs$BUGSoutput$sims.list$k.opt %>% hist(main = 'k.opt posterior and true value')
abline(v = k.opt, col = 'red', lwd = 2)
jags.outputs$BUGSoutput$sims.list$l.inf %>% hist(main = 'l.inf posterior and true value')
abline(v = l.inf, col = 'red', lwd = 2)
jags.outputs$BUGSoutput$sims.list$beta.dens %>% hist(main = 'beta.dens posterior and true value')
abline(v = beta.dens, col = 'red', lwd = 2)
jags.outputs$BUGSoutput$sims.list$sd.vbgm %>% hist(main = 'sd.vbgm posterior and true value')
abline(v = sd.vbgm, col = 'red', lwd = 2)

# save results and diagnostics ==================================================================

# create save folder 
save.folder <- paste0(getwd(), '/jags.results/')
dir.create(save.folder,recursive = TRUE )

# save summary of parameters estimates
write.table(jags.outputs$BUGSoutput$summary, file = "0.param.summary.txt")

# save mcmc chains
list.var <- c(dimnames(jags.outputs$BUGSoutput$sims.array)[3])[[1]] #list des var
list.var <- gsub("[^[:alnum:]]", "", list.var)
for (i in 1:dim(jags.outputs$BUGSoutput$sims.array)[3]){
  assign(paste0(list.var[i], "1"), mcmc(jags.outputs$BUGSoutput$sims.array[ , 1, i]))
  assign(paste0(list.var[i], "2"), mcmc(jags.outputs$BUGSoutput$sims.array[ , 2, i]))
  assign(paste0(list.var[i], "3"), mcmc(jags.outputs$BUGSoutput$sims.array[ , 3, i]))
  assign(list.var[i], mcmc.list(list(eval(parse(text = paste0(list.var[i], "1"))), 
                                     eval(parse(text = paste0(list.var[i], "2"))),
                                     eval(parse(text = paste0(list.var[i], "3"))))))
  write.table(do.call(eval(parse(text = list.var[i])), what = c), 
              file = paste0(save.folder, list.var[i], ".txt"))
}

# plot mcmc gelman, autocor, density and trace
pdf(file = paste0(save.folder, "/0.mcmc.plots.pdf"), onefile = TRUE, height = 8.25, width = 11.6)
par(mfrow = c(2, 2))
for (i in 1:length(list.var)){
  gelman.plot(eval(parse(text = list.var[i])), main = list.var[i], auto.layout = FALSE)
  autocorr.plot(eval(parse(text = list.var[i])), main = list.var[i], auto.layout = FALSE)
  hist(eval(parse(text = list.var[i])) %>% unlist, main = list.var[i], xlab = '')
  traceplot(eval(parse(text = list.var[i])), main = list.var[i])
}
dev.off()
