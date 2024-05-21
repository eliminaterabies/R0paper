library(ggplot2);theme_set(theme_bw())
library(shellpipes)
library(dplyr)
startGraphics()

loadEnvironments()

mexico <- (bind_rows(egf_gi2,egf_si)
	%>% filter(loc == "Mexico")
	%>% mutate(interval = ifelse(interval == "Serial", "Naive GI", "Corrected GI"))
	%>% transmute(method2 = paste0(method," \n + ",interval)
		, lwr
		, est
		, upr
	)
)

print(mexico)

hampsondf <- (rdsRead()
	%>% filter(loc == "Mexico")
	%>% transmute(method2 = "Hampson et al 2009"
		, lwr = lower
		, est = med
		, upr = upper
	)
)

dat <- (bind_rows(mexico,hampsondf)
	%>% mutate(method2 = factor(method2
		, levels=c("Hampson et al 2009", "Exponential \n + Naive GI"
			, "Exponential \n + Corrected GI"
			, "Logistic \n + Naive GI"
			, "Logistic \n + Corrected GI"
			)
		)
	)
)

print(dat)

gg <- (ggplot(dat,aes(x=method2, y=est))
	+ geom_pointrange(aes(ymin=lwr,ymax=upr))
#	+ coord_flip()
	+ ylab("R0")
	+ xlab("Method")
)

print(gg)

