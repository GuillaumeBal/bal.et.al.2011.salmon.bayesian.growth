Description
=============

This repo contains some code to fit the Von Bertalanffy linked to the publication

*  Bal G., Rivot E., Prévost E., Piou C. & Baglinière J.-L. (2011). Effect of water temperature and density of salmonid juveniles on growth of young-of-the-year Atlantic salmon Salmo salar L.. Journal of Fish Biology 78, pp 1002-1022. https://onlinelibrary.wiley.com/doi/10.1111/j.1095-8649.2011.02902.x


Only the full model including both density and temperature as covariates is provided. The files organization is as follows:

* '0.run.all.r' runs data simulations and fit. You need to install jags, the packages required and adapt the working directory
* '1.data.sim.r' is the R file doing the simulation with parameters close to that of the model fittedin the publication
* '2.vbgm.fit.r' fits the model with JAGS, some summary of the fit are provided / computed
* 'model.vb.dens.temp.txt' is the model coded in jags whom parameters are :
	- *k.opt*, the maximum growth rate  reached for optimal temperature and density conditions
	- *l.inf*, length at infinity
	- *beta.dens*, density effect
	- *t.min*, *t.opt*, *t.max* which are respectively the minimum, optimum and maximum temperature for growth. They are not estimated during the fit
	- sd.vbgm, the standard error around the Von Bertalanffy growth curve
	
A folder containing MCMC chains, their plots and their summaries will be created when running the fit file.
