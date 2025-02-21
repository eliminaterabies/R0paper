## This is R0paper 2024 May 21 (Tue)
## https://github.com/eliminaterabies/R0paper

## Current goal! get public_data stuff out of Makefile
## Note, once this is done, we need to replace it or something!
## Yes, just make old public_data into outputs for now, and then git mv that directory

cmain = main

current: target
-include target.mk
Ignore = target.mk

# -include makestuff/perl.def

vim_session:
	bash -cl "vmt"

######################################################################

## Build a Manuscript

Sources += doc.Rnw draft.tex 
Sources += $(wildcard *.bib)

## draft.pdf: draft.tex doc.Rnw
Ignore += draft.pdf.final.pdf
draft.final.pdf: $(Sources)
	$(RM) $@
	$(MAKE) draft.complete.pdf.final
	$(LN) draft.complete.pdf $@

draft.pdf: doc.Rnw

## draft.tex.deps: texknit/doc.tex.makedeps 
## texknit/doc.tex.deps: | texknit
texknit/doc.tex: delphi.pars.rda msvals.rda | texknit

## Debugging stuff
## draft.tex.mk: makestuff/texj.pl
## texknit/doc.tex.mk: makestuff/texj.pl

## Manually declare tex-file dependencies
draft.texdeps.mk: texknit/doc.texdeps.mk

######################################################################
## TODO: fancify and export both of these recipe lines ☺

Sources += knitr.tex
.PRECIOUS: texknit/%.tex
texknit/%.tex: %.Rnw | texknit
	Rscript -e "library(\"knitr\"); knit(\"$<\")"
	$(MVF) $*.tex texknit

Ignore += texknit
texknit:
	$(mkdir)

######################################################################

Sources += interval.png

######################################################################

## Evaluate ts parameters

autopipeR=defined
Sources += $(wildcard *.R)

## Parameter sets
## delphi.pars.Rout: delphi.R
## softClimb.pars.Rout: softClimb.R
## softDecline.pars.Rout: softDecline.R
## lowPeaks.pars.Rout: lowPeaks.R

pipeRimplicit += pars
%.pars.Rout: pars.R base.R %.R
	$(pipeR)

## Break series into phases
## Uses parameters minPeak and declineRatio
pipeRimplicit += monthly_phase

## Split time series into phases
## softClimb.monthly_phase.Rout: monthly_phase.R
%.monthly_phase.Rout: monthly_phase.R monthly.rds %.pars.rda 
	$(pipeR)

## Identify windows inside the phases
## Uses parameters minPeak (again),  minLength, and minClimb
pipeRimplicit += mm_windows

## Read pars again why?
## softClimb.mm_windows.Rout: mm_windows.R
%.mm_windows.Rout: mm_windows.R %.monthly_phase.rda %.pars.rda
	$(pipeR)

pipeRimplicit += mm_plot

## base.mm_plot.Rout: mm_plot.R
## delphi.mm_plot.Rout: mm_plot.R
## lowPeaks.mm_plot.Rout: mm_plot.R
%.mm_plot.Rout: mm_plot.R %.mm_windows.rda %.pars.rda
	$(pipeR)

## delphi.supp_mm_plot.Rout: supp_mm_plot.R
%.supp_mm_plot.Rout: supp_mm_plot.R %.mm_windows.rda %.pars.rda
	$(pipeR)

######################################################################

autopipeR=defined

## Parameter sets
## delphi.pars.Rout: delphi.R
## softClimb.pars.Rout: softClimb.R
## softDecline.pars.Rout: softDecline.R
## lowPeaks.pars.Rout: lowPeaks.R

## Not sure if this is needed 2024 Jan 17 (Wed)
pipeRimplicit += pars
%.pars.Rout: pars.R base.R %.R
	$(pipeR)

## Break series into phases
## Uses parameters minPeak and declineRatio
pipeRimplicit += monthly_phase

## Split time series into phases
## softClimb.monthly_phase.Rout: monthly_phase.R
%.monthly_phase.Rout: monthly_phase.R monthly.rds %.pars.rda 
	$(pipeR)

## Identify windows inside the phases
## Uses parameters minPeak (again),  minLength, and minClimb
pipeRimplicit += mm_windows

## Read pars again why?
## softClimb.mm_windows.Rout: mm_windows.R
%.mm_windows.Rout: mm_windows.R %.monthly_phase.rda %.pars.rda
	$(pipeR)

pipeRimplicit += mm_plot

## base.mm_plot.Rout: mm_plot.R
## delphi.mm_plot.Rout: mm_plot.R
## lowPeaks.mm_plot.Rout: mm_plot.R
%.mm_plot.Rout: mm_plot.R %.mm_windows.rda %.pars.rda
	$(pipeR)

## delphi.supp_mm_plot.Rout: supp_mm_plot.R
%.supp_mm_plot.Rout: supp_mm_plot.R %.mm_windows.rda %.pars.rda
	$(pipeR)

## The last pre-Delphi comparison plot.
compare.Rout: compare.R softClimb.mm_plot.rds lowPeaks.mm_plot.rds base.mm_plot.rds softDecline.mm_plot.rds
	$(pipeR)

######################################################################

## Read two data sets into a long frame
## Trim out Excel padding; add time offsets

Sources += public_data/*.*sv
monthly.Rout: monthly.R public_data/R0rabiesdataMonthly.csv public_data/monthlyTSdogs.csv public_data/varnames.tsv
	$(pipeR)

######################################################################

## This is terrible, we want to deprecate this old repo and get stuff from links
## public_data is cribbed from the egfR0 repo
## These are tailored output files that we can share


Sources += msvals.md
Sources += public_data/*.rd*
msvals.Rout: msvals.R biteNumber.rda slow/egf_R0.rda public_data/intervals.rda link/linked.rda simparams.rda
	$(pipeR)

## bitten biteDist.rds


######################################################################

##### 2024 Oct 16 (Wed)
## Built this all with Dropbox right before Dropbox stabbed JD in the heart
## Link to Tanzanian data 
## -include ../datalinks.mk

######################################################################

pardirs += new_pipeline link
hotdirs += $(pardirs)
Ignore += $(pardirs)

## Count number of bite events and number of suspected biters
biteNumber.Rout: biteNumber.R new_pipeline/SD_dogs.incubation.Rout.csv
	$(pipeR)

######################################################################

## We've now selected Delphi and are sticking with it
## pipeRimplicit += egf_single

## Do an egf fit 

exp.Rout: exp.R
	$(pipeR)

logistic.Rout: logistic.R
	$(pipeR)

pipeRimplicit += egf_single

## exp.egf_single.Rout: egf_single.R
## logistic.egf_single.Rout: egf_single.R

%.egf_single.Rout: egf_single.R delphi.mm_windows.rda %.rda
	$(pipeR)

pipeRimplicit += egf_plot
## exp.egf_plot.Rout: egf_plot.R
## logistic.egf_plot.Rout: egf_plot.R
%.egf_plot.Rout: egf_plot.R %.egf_single.rds
	$(pipeR)

pipeRimplicit += egf_rplot

## exp.rplot.Rout:
## logistic.rplot.Rout:
%.rplot.Rout: rplot.R %.egf_single.rds
	$(pipeR)

rplot_combo.Rout: rplot_combo.R exp.egf_single.rds logistic.egf_single.rds public_data/series.tsv
	$(pipeR)

pipeRimplicit += egf_sample

simparams.Rout: simparams.R
	$(pipeR)

## exp.egf_sample.Rout: egf_sample.R
## logistic.egf_sample.Rout:
%.egf_sample.Rout: egf_sample.R %.egf_single.rds simparams.rda
	$(pipeR)

simR0_funs.Rout: simR0_funs.R
R0est_funs.Rout: R0est_funs.R

Sources += $(wildcard slow/*.rda)

## This slow target is slow, according to WZ
## slow/egf_R0.Rout: egf_R0.R R0est_funs.R simparams.R
## slowtarget/egf_R0.Rout: egf_R0.R simparams.R
slowtarget/egf_R0.Rout: egf_R0.R exp.egf_sample.rds logistic.egf_sample.rds simR0_funs.rda R0est_funs.rda public_data/intervals.rda public_data/biteDist.rds simparams.rda
	$(pipeR)

R0plot.Rout: R0plot.R slow/egf_R0.rda public_data/series.tsv
	$(pipeR)

KH_R0.Rout: KH_R0.R public_data/series.tsv slow/egf_R0.rda
	$(pipeR)

R0combo.Rout: R0combo.R KH_R0.rds R0plot.rds
	$(pipeR)

mexico.Rout: mexico.R slow/egf_R0.rda KH_R0.rds
	$(pipeR)

## Epigrowthfit version
version.Rout: version.R
	$(pipeR)

######################################################################


intervalPlots.Rout: intervalPlots.R public_data/intervals.rda 
	$(pipeR)

## Summary stats
intervalStats.Rout: intervalStats.R public_data/intervals.rda 
	$(pipeR)

######################################################################

### Makestuff

Sources += Makefile .gitignore
Sources += notes.md README.md

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/00.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone --depth 1 $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk

-include makestuff/pipeR.mk
-include makestuff/texj.mk
-include makestuff/slowtarget.mk
-include makestuff/hotcold.mk
-include makestuff/git.mk
-include makestuff/gitbranch.mk
-include makestuff/visual.mk
