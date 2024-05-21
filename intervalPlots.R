## estimating SI from data

library(bbmle)
library(ggplot2);theme_set(theme_bw())
library(dplyr)
library(purrr)
library(tidyr)
library(cowplot)
library(ggforce)

library(shellpipes)
startGraphics()
loadEnvironments()

minDays <- 0
maxDays <- 100

hampson_intervals <- data.frame(Hampson_mean = c(22.3,24.9)
	, Type = c("Incubation Period: Dogs","Generation Interval")
)

interval_merge <- (interval_merge
	|> left_join(hampson_intervals)
	|> left_join(timesummary)
)

print(interval_merge %>% group_by(Type) %>% summarise(count = n()))

gg <- (ggplot(interval_merge, aes(Days,fill=Type,color="black"))
	+ geom_histogram()
	+ geom_vline(aes(xintercept=Mean),size=1,color="black",lty=1)
	+ geom_vline(aes(xintercept=Hampson_mean),size=1,color="red",lty=1)
	+ geom_density(aes(y=..count..*5),alpha=0.002)
	+ facet_wrap(~Type, nrow=1)
	+ scale_fill_manual(values=c("grey","blue","red","grey","grey"))
	+ scale_color_manual(values=rep("black",5))
	+ theme(legend.position="none", panel.spacing = unit(0,"lines"))
	+ geom_text(mapping=aes(x=Mean, y=0, label=paste(round(Mean,1),"days")), size=4, angle=00, vjust=-45, hjust=-0.1) 
	+ xlim(c(minDays,maxDays))
	+ ylab("Counts")
)

eyeball_lab_df <- data.frame(
	Type = c("Generation Interval", "Incubation Period: Dogs", "Weighted Incubation Period")
	, xloc = c(60, 50, 60)
	, yloc = c(30, 125, 30)
)

eyeball_lab_df <- (left_join(eyeball_lab_df,interval_merge)
	%>% select(Type,xloc,yloc,Mean)
	%>% distinct() 
)
print(eyeball_lab_df)

gg_gen <- (gg %+% (interval_merge %>% filter(Type == "Generation Interval")) 
	+ geom_text(data=filter(eyeball_lab_df,Type == "Generation Interval"), mapping=aes(x=xloc, y=yloc, label=paste(round(Mean,digits=1),"days")), size=4, angle=00) 
)

gg_dogs <- (gg %+% (interval_merge %>% filter(Type == "Incubation Period: Dogs")) 
	+ geom_text(data=filter(eyeball_lab_df,Type == "Incubation Period: Dogs"), mapping=aes(x=xloc, y=yloc, label=paste(round(Mean,digits=1),"days")), size=4, angle=00)
)

gg_adjbiter <- (gg %+% (interval_merge %>% filter(Type == "Weighted Incubation Period")) 
	+ geom_text(data=filter(eyeball_lab_df, Type == "Weighted Incubation Period")
	, mapping=aes(x=xloc, y=yloc, label=paste(round(Mean,digits=1),"days")))
	)

ggbites <- (ggplot(bites, aes(x=count))
   + geom_histogram(fill="grey", color="black", guide=FALSE,bins=20)
   + xlab("Bites")
	+ xlim(c(0,20))
   + facet_wrap(~"Bites")
	+ ylab("Counts")
) 

print(plot_grid(gg_dogs, gg_adjbiter,ggbites, gg_gen,labels = c("A","B","C","D")))


