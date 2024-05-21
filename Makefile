## This is R0paper 2024 May 21 (Tue)

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

## This is the main rule
## draft.pdf.final: rabies.bib draft.tex doc.Rnw
## draft.pdf: draft.tex doc.Rnw
Ignore += draft.pdf.final.pdf
draft.pdf.final.pdf: $(Sources)
	$(RM) $@
	$(MAKE) draft.pdf.final
	$(LN) draft.pdf $@

## This rule will try harder to make a pdf, and less hard to make sure all of the dependencies are in order. 
## draft.tex.pdf: draft.tex doc.Rnw

## Other dependencies should be in texknit/doc.tex.mk
draft.pdf: texknit/doc.makedeps doc.Rnw

texknit/doc.tex: delphi.pars.rda slow/msvals.rda | texknit
## TODO: fancify and export both of these recipe lines ☺
.PRECIOUS: texknit/%.tex
texknit/%.tex: %.Rnw | texknit
	Rscript -e "library(\"knitr\"); knit(\"$<\")"
	$(MVF) $*.tex texknit

Ignore += texknit
texknit:
	$(mkdir)

######################################################################

## Evaluate ts parameters

autopipeR=defined
Sources += $(wildcard *.R)

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

Sources += datadir/*.*sv
monthly.Rout: monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv datadir/varnames.tsv
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
-include makestuff/texi.mk

-include makestuff/git.mk

