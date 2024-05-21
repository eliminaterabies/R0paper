library(tidyverse)

library(shellpipes)

loadEnvironments()

## Split time series into phases by finding peaks and then looking for a fall
## We split before we look at climb ratios or series lengths
## Don't start a new phase until we see a rise
calcPhase <- function(v, mp, dt){
	T <- length(v)
	phase <- numeric(T)
	peak <- 0
	currPhase <- 1
	
	for (i in 1:(T-1)){
		if(v[[i]] > pmax(peak, mp)) peak <- v[[i]]
		if((v[[i]] < dt*peak) & (!is.na(v[[i+1]])) & (v[[i]] <= v[[i+1]])){
			currPhase <- currPhase+1
			peak <- 0
		}
		phase[[i]] <- currPhase
	}
	phase[[T]] <- currPhase
	return(as.character(phase))
}

## Do a calcPhase for each loc(ation)
long <- (rdsRead()
	%>% group_by(loc)
	%>% mutate(phase = calcPhase(cases, minPeak, declineRatio))
	%>% ungroup
)

summary(long |> mutate_if(is.character, as.factor))

saveVars(long)

