library(ggplot2); theme_set(theme_bw(base_size=14))
library(tidyverse)
library(epigrowthfit)

library(shellpipes); startGraphics()
loadEnvironments()

egfdf <- rdsRead()

print(egfdf)

#egfdf <- head(egfdf)

for(i in 1:nrow(egfdf)){
	print(i)
#	if(is.na(egfdf[["upr"]][[i]])){return(plot())}
	plot(egfdf[["egf_fit"]][[i]]
		, main=paste0(egfdf[["loc"]][[i]]," phase ",egfdf[["phase"]][[i]])
#		, xlim=c(0,100)
	)	
}



