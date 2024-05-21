library(tidyverse)
library(epigrowthfit)
library(shellpipes)
library(stringr)

loadEnvironments()

fakewin <- data.frame(start = -Inf, end=Inf)

print(windows)

egffun <- function(x){
	## Drop the past-the-peak point for exponential
	if(method=="Exponential"){
		x <- (x
			|> filter(offset < max(offset) | cases == max(cases))
		)
	}
	x <- bind_rows(data.frame(offset = x$offset[[1]]-1
		, cases = NA)
	, x)
	mod <- egf(model = egf_model(curve = method, family = "nbinom")
		, data_ts = x
		, formula_ts = cbind(offset, cases) ~ 1
		, formula_parameters = ~ 1
		, data_windows = fakewin
		, formula_windows = cbind(start, end) ~ 1
		, se = TRUE
	) 
	return(mod)
}     

r_ests <- function(x){
	cf <- confint(x[[1]], level = 0.95, A = NULL, class = TRUE)
	df <- data.frame(lwr = exp(cf[["ci"]][, 1L][[1]])
		, est = exp(cf[["value"]][[1]])
		, upr = exp(cf[["ci"]][, 2L][[1]])
	)
	return(df)
}


## Do we need map here? Why??
ff <- (selected
	%>% group_by(loc,phase)
	%>% nest()
	%>% mutate(egf_fit = map(data,~ egffun(.)))
)

print(ff)

print(ff$egf_fit)

fulldat <-(ff
	%>% group_by(loc,phase,egf_fit)
	%>% reframe(r_ests(egf_fit))
	%>% mutate(method=str_to_title(method))
)

print(fulldat)

rdsSave(fulldat)

