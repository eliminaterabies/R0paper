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

long |> pull(loc) |> unique() |> walk(function(x){
	print(ggplot(long |> filter(loc==x))
		+ aes(x=offset, y=cases)
		+ geom_line()
		+ geom_line(aes(color=phase))
		+ ggtitle(paste(x, parset), subtitle=parlist)
		+ geom_point(dat=selected |> filter(loc==x), aes(color=phase), size=4)
 		+ scale_colour_manual(values=palette)
		+ xlab("offset (months)")
	)
})

long <- long |> mutate(parlist = parlist, parset = parset)
selected <- selected |> mutate(parlist = parlist, parset = parset)

print(long)

ll <- list(long = long, selected = selected)

rdsSave(ll)



