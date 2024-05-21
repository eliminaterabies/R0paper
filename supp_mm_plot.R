library(shellpipes)
manageConflicts()

library(ggplot2); theme_set(theme_bw(base_size=14))
library(tidyverse)

library(shellpipes); startGraphics()
loadEnvironments()
palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

parset <- paste0("(", pipeStar(), ")")
parlist <- paste(NULL
	, "minPeak:", minPeak
	, "; declineRatio:", declineRatio
	, "; minLength:", minLength
	, "; minClimb:", minClimb
)

gg <- (ggplot(long,aes(x=offset,y=cases))
	+ geom_line()
	+ geom_line(aes(color=phase))
#	+ ggtitle(loc)
	+ geom_point(dat=selected,aes(color=phase),size=0.8)
   + scale_color_manual(values=c("black","red", "orange"))
	+ xlab("offset (months)")
	+ facet_wrap(~loc,scale="free")
	+ theme(legend.position="bottom")
)

print(gg)


