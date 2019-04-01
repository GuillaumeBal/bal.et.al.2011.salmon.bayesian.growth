# the simulations are mean lengthes

# data structure ===========================================
# mimicking the one in article
n.years <- 20
n.stations <- 5
n.days <- 365
n.samples.year <- 2

# details of vbgm ===================================================
# chosen rather close to estimates in article
l.inf <- 200
k.opt <- 0.004
beta.dens <- 0.005
sd.vbgm <- 5
t.min <- 6.8
t.opt <- 17.6
t.max <- 23.9

# get data into fish.data list() ====================================
fish.data <- list()
fish.data$year <- rep(1:n.years, each = n.stations)
fish.data$station <- rep(1:n.stations, n.years)

# get some densities ================================================
# fairly wide range, no stations effect
fish.data$dens <- runif(n.years * n.stations, 5, 60) %>% round(1)

# fishing dates =====================================================
# coded as day of the year
fish.data$date.1 <- sample(80:100, size = n.years, replace = FALSE) %T>% 
  assign(value = ., x = 'day.fished.year.1', envir = .GlobalEnv) %>% rep(., each = n.stations)
fish.data$date.2 <- sample(220:240, size = n.years, replace = FALSE) %T>% 
  assign(value = ., x = 'day.fished.year.2', envir = .GlobalEnv) %>% rep(., each = n.stations)
fish.data$date.delta <- fish.data$date.2 - fish.data$date.1

# water temp time series ============================================
alpha.temp <- runif(n.years, 12, 15)
beta.temp <- runif(n.years, 5, 7)
wt.temp <- matrix(NA, nrow = n.years, ncol = n.days)
for(y in 1:n.years){ # did not bother with AR1 residuals
  wt.temp[y , ] <- rnorm(365, 
                         mean = alpha.temp[y] + beta.temp[y] * sin(2 * pi * (1:n.days - n.days / 4) / n.days),
                         sd = 2) %>% round(1) #%T>% plot(type = 'l')
}

# temperature dependent growth rate =================================
fish.data$temp.effect <- rep(NA, n.years)
for(y in 1:n.years) fish.data$temp.effect[y] <- wt.temp[y, (day.fished.year.1[y] + 1):(day.fished.year.2[y])] %>%
{(. - t.min) * ( . - t.max)/(( . - t.min) * (. - t.max) - (. - t.opt) ^ 2)} %>% 
  replace(., . < 0, 0) %>% mean
fish.data$temp.effect %<>% rep(., each = n.stations) 

# simulate size data ================================================
# first date length assumed to be normally distributed
fish.data$length.1  <- rnorm(n.years * n.stations, mean = 70, sd = 5) %>% round(1)
# second capture length
fish.data$length.2 <- rnorm(length(fish.data$year),
                            mean = fish.data$length.1 + (l.inf - fish.data$length.1) *
                              (1 - exp(- fish.data$date.delta * 
                                         k.opt * 
                                         fish.data$temp.effect * 
                                         exp(- beta.dens * fish.data$dens))),
                            sd = sd.vbgm) %>% round(1)
