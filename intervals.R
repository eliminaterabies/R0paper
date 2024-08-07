
library(shellpipes)
manageConflicts()
startGraphics()

library(tidyr)
library(dplyr)

loadEnvironments()

(interval_merge
	|> group_by(Type)
	|> summarise(n=min(Days), x=max(Days))
)

