library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

rsamps <- function(x,n=100){
	mm <-coef(x)[1]
	vv <- diag(vcov(x))[1]
	exp(rnorm(n=n,mean=mm,sd=sqrt(vv)))
}


df <- rdsRead()


egf_df <- (df
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(rsamp = map(egf_fit,~rsamps(.,n=nsamp))) 
)

print(egf_df)




rdsSave(egf_df)



