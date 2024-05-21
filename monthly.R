library(tidyverse)

library(shellpipes)
## rpcall is how you make a particular .Rout file in rstudio 
## You can have a different rpcall living here for each relevant target file
#### Find them in <targetname.Rout.args>
## Put the active one last
rpcall("monthly.Rout .pipestar monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv varnames.tsv")

######################################################################
## Read two data sets into a long frame

longframe <- function(n){
	return(csvRead(n) 
		%>% mutate(time = 1:nrow(.))
		%>% pivot_longer(cols=-time, names_to="datname", values_to="cases")
	)
}

long <- bind_rows(longframe("R0"), longframe("TS"))

## Merge in new names
long <- (
	left_join(long, tsvRead())
	%>% select(loc, time, cases)
)

## Trim out padding
filterTS <- function(v){
	good <- which(!is.na(v) & v>0)
	return(v[min(good):max(good)])
}

long <- (long
	%>% group_by(loc)
	%>% summarize(cases=list(filterTS(cases)))
	%>% unnest(cols=cases)
	%>% group_by(loc)
	%>% mutate(offset = 1:length(cases))
	%>% ungroup
	%>% arrange(loc)
)

summary(long %>% mutate_if(is.character, as.factor))
print(long, n=Inf)

rdsSave(long)
