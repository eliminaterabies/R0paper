## R0 estimate functions
library(shellpipes)


#Functions to estimate R0 and CIs via data
R0est_data<-function(r, interval){
  return(
    1/mean(exp(-r*interval))
  )
}

genExp <- function(rho, kappa){
  if (kappa==0)
    return(exp(rho))
  return((1+rho*kappa)^(1/kappa))
}

genExpGamma <- function(r, Mean, Shape){
  return(genExp(r*Mean, 1/Shape))
}


R0est_gamma <-function(r, timedat){
  Mean <- timedat[2]
  Shape <- timedat[1]
  return(genExp(r*Mean, 1/Shape))
}

R0tiles <- function(x){
   cf <- quantile(x[[1]],probs=c(0.025,0.975),na.rm=TRUE)
	df <- data.frame(lwr=cf[["2.5%"]][[1]]
      , est = mean(x[[1]],na.rm=TRUE)
      , upr = cf[["97.5%"]][[1]]
   )
   return(df)
}


saveEnvironment()

