## R0 estimates from Hampson et al 2009
library(tidyverse)
library(shellpipes)

loadEnvironments()

egf <- egf_gi2

egf_locs <- egf %>% pull(loc) %>% unique()

loc <- tsvRead() %>% pull(varname)

Cities = c("NYstate"
, "CentralNY, US \n (1944)"
, "Israel \n (1948)"
, "Tokyo, JP \n (1948)"
, "Kanagawa, JP \n (1917)"
, "Tokyo, JP \n (1918)"
, "Peru \n (1984)"
, "Mexico \n (1987)"
, "Selangor, MY \n (1951)"
, "Sultan Hamad, KE \n (1992)"
, "Java, IDN \n (1985)"
, "Memphis, US \n (1947)"
, "HongKong \n (1949)"
, "Serengeti, TZ \n (2003)"
, "Ngorongoro, TZ \n (2003)"
)


kh_lower <- c(NA,1.25,1.07,1.04,1.02,1.14,1.03,1.52,1.48,0.99,1.34,1.23,1.33,1.02,1.12,0.94)
kh_upper <- c(NA,1.40,1.19,1.06,1.17,1.37,1.38,1.91,1.82,1.27,2.18,1.80,2.17,1.60,1.41,1.32)
kh_est <- c(NA,1.32,1.12,1.05,1.09,1.25,1.19,1.68,1.62,1.12,1.72,1.49,1.69,1.27,1.19,1.14)

hampsondf <- data.frame(loc=loc
	, lower = kh_lower
	, med = kh_est
	, upper = kh_upper
	, type = "Hampson et al (2009)"
	, samptype = "Construction"
)

hampsondf <- (hampsondf 
	%>% filter(loc %in% egf_locs)
	|> left_join(tsvRead(),by=c("loc"="varname"))
	%>% mutate(loc_final = ifelse(loc == "Tokyo1", "Tokyo",loc)
   , loc_final = ifelse(loc_final == "Tokyo2", "Tokyo",loc_final)
   , loc_final = paste0(loc_final, "\n", year)
	)
)

print(hampsondf)

rdsSave(hampsondf)
