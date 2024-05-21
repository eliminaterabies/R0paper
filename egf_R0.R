library(shellpipes)
manageConflicts()

library(tidyverse)
library(epigrowthfit)
library(future.apply)

loadEnvironments()

no_cores <- availableCores() - 4
plan(multicore, workers = no_cores)

print(no_cores)

minDays <- 0
maxDays <- 100

print(interval_merge)

biteDist <- (rdsRead("biteDist")
	|> rename(IDnum=anon)
)

psimgencluster <- function(time,num,bootsample){
	return(future_replicate(num,sample_clustergen(time,bootsample)))
}

simgencluster <- psimgencluster(biteDist,num=nsamp,bootsample=nboot)

simtimesamp <- function(time,num,bootsample){
  return(future_replicate(num, sample(time, size=bootsample, replace=TRUE))) 
}

si <- (interval_merge
	%>% filter(Type == "Serial Interval")
	%>% pull(Days)
)

sisamp <- simtimesamp(si,num=nsamp,bootsample=nboot)

gi <- (interval_merge
	%>% filter(Type == "Generation Interval")
	%>% pull(Days)
)

egf_fit_dfs <- bind_rows(rdsRead("exp"),rdsRead("logistic"))

#egf_gi <- (egf_fit_dfs
#	%>% group_by(loc,phase,egf_fit)
#	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=gi,n=nsamp,bootsample=nboot)))
#	%>% group_by(loc,phase,method)
#	%>% reframe(R0tiles(R0sims))
#	%>% mutate(interval = "Generation")
#)

print(egf_fit_dfs$rsamp)

egf_gi2 <- (egf_fit_dfs
	%>% mutate(R0sims = map(rsamp,~clustersimR0_data(.,time=simgencluster)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Cluster-Generation")
)

print(egf_gi2)

egf_si <- (bind_rows(rdsReadList())
#	%>% group_by(loc,phase,egf_fit)
#	%>% mutate(R0sims = pmap(rsamp,~simR0_data(.,time=si,n=nsamp,bootsample=nboot)))
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=sisamp)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Serial")
)


saveVars(egf_gi2,egf_si,nboot,nsamp)

