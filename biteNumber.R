library(shellpipes)
manageConflicts()

library(dplyr)
library(readr)

## Consider checking column types if there is a big upstream change
## There is a known problem in column 65, we're not using it.
## Should this logic be moved upstream?
## At some point use select in the pipeline repo to create a smaller csv
animal <- csvRead(comment="#", show_col_types=FALSE, col_select = -65)

## number of cases (Serengeti dog cases)
print(dim(animal))

## Number of transmission events

dogsTransmissionNum <- nrow(animal)

## Number of suspected cases 
SuspectDogs <- (animal 
	%>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
)

dogsSuspectedNum <- nrow(SuspectDogs %>% select(ID) %>% distinct())

## Dogs with unknown biters

dogsUnknownBiter <- (SuspectDogs
	%>% filter(Biter.ID == 0)
)

unknownBiters <- nrow(dogsUnknownBiter)

saveVars(dogsTransmissionNum, dogsSuspectedNum, unknownBiters)

