## support R0 simulation functions
library(shellpipes)

## simulate n number of normally distributed r from growthfit object
sim_growthrate <- function(x,n,is){
	r_mean <- x@profile@summary@coef["r","Estimate"]
	r_se <- x@profile@summary@coef["r","Std. Error"]
	sam_r <- exp(rnorm(n,mean=r_mean,r_se))
  if(is.na(r_se)){
    r_mean <- epigrowthfit:::growthRate(x)["value"]
    r_se <- (r_mean - growthRate(x)["lower"])/1.96
    sam_r <- rnorm(n,mean=r_mean,r_se)
    }
  return(sam_r)
}

## simulate n number of normally distributed r from growthfit object
sim_nbrfit <- function(x,n){
  r_mean <- coefficients(x)["time"]
  r_se <-  sqrt(diag(vcov(x)))["time"]
  sam_r <- rnorm(n,mean=r_mean,r_se)
  return(sam_r)
}

## simulate n pairs of normally distributed shape and scale gamma parameters
## from time intervals

sim_timedens <- function(x,n){
  start_pars <- gamma_moments(x)
  estfit <- PgammaMLE(x,start=list(shape=start_pars[1],scale=start_pars[2]))
  simdat <- MASS::mvrnorm(n,mu=coef(estfit),Sigma=vcov(estfit))
  return(simdat)
}

## Simulate n replicates of interval bootstrap samples 
sim_timeprob <- function(x, n, bootsample){
  sample_mat <- replicate(n, sample(x, size=bootsample, replace=TRUE)) 
#  densdf <- lapply(1:n,function(x){table(sample_mat[,x])/bootsample})
  return(sample_mat)
}

## simulate R0 via bootstrapping r and emperical intervals
simR0_data <- function(rsims,time){
  rsimsdays <- rsims/30
  timemat <- time
  n <- length(rsimsdays)
  R0sims <- sapply(1:n,function(x){R0est_data(rsimsdays[x],timemat[,x])})
  return(R0sims)
}

sample_clustergen <- function(x,s){
  biterdf <- (x
              %>% select(IDnum,count)
              %>% distinct()
              %>% ungroup()
              %>% sample_n3(size=s,replace=TRUE,weight=NULL) #weight=count)
              %>% arrange(IDnum)
              %>% group_by(IDnum)
              %>% mutate(ind = 1, repid = cumsum(ind))
              %>% select(IDnum, count, repid)
              %>% left_join(.,distinct(x),by=c("IDnum","count"))
              %>% ungroup()
				  %>% mutate(count = 1)
              %>% group_by(IDnum, count, repid)
              %>% nest()
              %>% mutate(samp = map2(data,count,sample_n3))
  )
  # return(biterdf)
  return(unlist(biterdf["samp"]))
}

sample_clustergenWeights <- function(x,s){
	biterdf <- (x
		%>% select(IDnum,count)
		%>% distinct()
		%>% ungroup()
		%>% sample_n3(size=s,replace=TRUE,weight=count)
		%>% arrange(IDnum)
		%>% group_by(IDnum)
		%>% mutate(ind = 1, repid = cumsum(ind))
		%>% select(IDnum, count, repid)
		%>% left_join(.,x)
		%>% ungroup()
		%>% group_by(IDnum, count, repid)
		%>% nest()
		%>% mutate(samp = map2(data,count,sample_n3))
		)
# return(biterdf)
	return(unlist(biterdf["samp"]))
}

sample_n3<-function (tbl, size, replace = TRUE, weight = NULL,.env=NULL, ...) 
{
  weight <- rlang:::eval_tidy(enquo(weight), tbl)
  dplyr:::sample_n(tbl, size, FALSE, replace = replace, weight = weight, .env=.env)
}

sim_clustertime <- function(time,num,bootsample){
  return(replicate(num, sample_clustergen(time, bootsample)))
}

sim_clustertimeWeights <- function(time,num,bootsample){
  return(replicate(num, sample_clustergenWeights(time, bootsample)))
}

## do time sampling outside of the function. This is simply to calculate R0

clustersimR0_data <- function(rsims,time){
#  rsims <- sim_growthrate(growth_obj,n)
  rsimsdays <- rsims/30
  n <- length(rsimsdays)
  timemat <- time
  R0sims <- sapply(1:n,function(x){R0est_data(rsimsdays[x],timemat[,x])})
  return(R0sims)
}

simR0_gamma <- function(growth_obj, time, n){
  rsims <- sim_growthrate(growth_obj,n)
  rsimsdays <- rsims/30
  denslist <- sim_timedens(time, n)
  R0sims <- sapply(1:n, function(x){R0est_gamma(rsimsdays[x],denslist[x,])})
  return(R0sims)
}

simR0nb_data <- function(growth_obj,time,n,bootsample){
  rsims <- sim_nbrfit(growth_obj,n)
  rsimsdays <- rsims/30
  timemat <- sim_timeprob(time,n,bootsample)
  R0sims <- sapply(1:n,function(x){R0est_data(rsimsdays[x],timemat[,x])})
  return(R0sims)
}
  
saveEnvironment()
