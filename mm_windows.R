library(tidyverse)

library(shellpipes)

## Get both minPeak and long 
loadEnvironments()

findWin <- function(l, p, t, c, mp, ml, mc, w){
	if(max(c) < mp){
		if (w) print(paste("Max too small in", l[[1]], p[[1]]))
		return(data.frame(offset=NULL, cases=NULL))
	}
	ind <- 1:(2+length(c))
	c <- c(0, c, NaN)
	t <- c(0, t, NaN)
	
	## from one past lastPreZero to one past the global peak
	## FIXME: It would be nice to allow a flexible number of zero/NAs before breaking, but not super-straightforward
	maxInd <- which.max(c)
	lastPreZero <- max(which(c==0 & ind<maxInd))
	if(maxInd+1<length(c)){maxInd <- maxInd+1}
	range <- (1+lastPreZero):maxInd
	if(length(range)<ml){
		if (w) print(paste("Range too short in", l[[1]], p[[1]]))
		return(data.frame(offset=NULL, cases=NULL))
	}

	rf <- data.frame(offset=t[range], cases=c[range])

	## Check minimum climb criterion
	smin <- pmax(1, min(rf$cases))
	smax <- max(rf$cases)
	if (smax<smin*mc){
		if (w) print(paste("Climb too shallow in", l[[1]], p[[1]]))
		return(data.frame(month=NULL, cases=NULL))
	}

	return(rf)
}

warn = TRUE
## Pull out windows for egf

print(head(long))

selected <- (long
	%>% group_by(loc, phase)
	%>% reframe(findWin(loc, phase, offset, cases, minPeak, minLength, minClimb, warn))
)

print(head(selected))

## Make zero-information windows file (we've already selected everything)
windows <- (selected
	|> select(loc, phase)
	|> distinct()
	|> mutate(start=-Inf, end=Inf)
)

summary(selected)

## Try to not need this
ll <- list(long = long, selected = selected)
rdsSave(ll)

## Maybe save everything for future combinations?
saveVars(long, selected, windows)
