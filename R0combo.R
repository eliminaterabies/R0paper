library(ggplot2);theme_set(theme_bw())
library(shellpipes)
library(dplyr)
library(grid)
startGraphics()
rpcall("R0combo.Rout .pipestar R0combo.R KH_R0.rds R0plot.rds")
sessionInfo()
gg <- rdsRead("plot")
hampson <- rdsRead("KH")

print(hampson)

## https://ggplot2.tidyverse.org/reference/guide_custom.html
## tweak x0/x1 to line up with title
blue_line <- grid::segmentsGrob(x0 = unit(0.4, "cm"),
                                x1 = unit(1.4, "cm"),
                                y0 = unit(0, "cm"),
                                y1 = unit(0, "cm"),
                                ## could be tweaked more ?
                                ## centered? width?
                                gp = gpar(col = "blue", lwd = 8,
                                          lineend = "square",
                                          alpha = 0.2))

print(gg 
	+ geom_linerange(data=hampson
		, aes(xmin=lower, xmax=upper)
		, color="blue"
		, linewidth = 3
		, alpha=0.2
	)
	+ geom_point(data=hampson
		, aes(x=med)
		, shape = "|"
		, size = 2.3
		, color = "blue"
	)
      + xlab(expression(R[0]))
      + guides(custom = guide_custom(blue_line,
               title = "Hampson"))
)

rdsSave(gg)


