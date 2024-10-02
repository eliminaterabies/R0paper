2024 Oct 02 (Wed)
=================

What is in public_data and how do we replicate it?
public_data/biteDist.rds
public_data/bitten.rda
public_data/intervals.rda
public_data/linked.rda
public_data/monthlyTSdogs.csv
public_data/R0rabiesdataMonthly.csv
public_data/series.tsv
public_data/varnames.tsv

2024 Feb 25 (Sun)
=================

Went over ms, need to fill the new windows stuff. Removed all the Bayesian little r using Stan. Need to use program to print sample/estimates directly instead of writting it out. Need to switch out serial interval from mexico plot with constructed GI from Hampson2009 (proxy serial). 

2024 Jan 29 (Mon)
=================

Consider a window length of 4

Consider what to do with overlapping fits: e.g., Mexico has a point that could the past-the-peak of phase I or the first of phase II or both (see also Perak). Any approach has possible pitfalls.

Perak remains the hardest.

----------------------------------------------------------------------

Since our last meeting, WZ and I have:

* tried to make the pictures easier to read
* changed the cut algorithm to not cut until a local minimum is reached; this seems to “just fix” Kanagawa
* made a pipeline that should make it relatively easy to compare different parameter choices (see links below)

Questions:

* The first window in Kanagawa has a double peak; JD feels like we should not fiddle
* The second phase in Kanagawa is sensitive to minPeak choice
* Memphis looks like a good peak, but is not selected because the time series is too short
* We kind of want to exclude Perak; we could do that by raising the minimum to 16, or just by making a judgment that we hate it
* Tokyo1 has two double peaks!
* What do we think about the first peak in Tokyo2?

You can view some pictures [here](outputs/compare.Rout.pdf); the pipeline makes it easy now to change parameters and make comparisons.

It would be great it you could share any quick thoughts, and really great if we could make decisions when we meet on Monday.


2024 Jan 17 (Wed)
=================

Making a document specifically about the plots, but also contains our current thoughts
* mm_plot.md

Based on data quality, we are thinking of changing the default value of minPeak to 15 (or possibly 16 specifically to exclude Perak‽)

2024 Jan 03 (Wed)
=================

What do we want to do about random effects, etc?

Doing REs at the country level feels like a nightmare: possibly to fit, but also to interpret. During REs only at the phase level seems impossible (not enough info, and the additivity assumption is confusing).

So we are thinking for now of estimating r0 separately for each time series.

Another question is whether we want to estimate r0 at t=-∞, or at a time when the cumulative cases are estimated at 1. How much difference does it make? JD thinks it probably matters for some formulations but not others. Logistic seems stable-ish, so maybe stick with that. Meaning also: stick with egf, which does t=-∞.

2023 Dec 25 (Mon)
=================

Our new pipeline has three parameters that are used in window selection. The
first set we looked at was minPeak=12; ratThresh=0.25 and minLength=6.

We decided quickly that minLength=6 was too big a departure from past work, and
switched to minLength=5.

First set of observations:
* We don't like the second phase of Kanagawa (it goes down almost as much as up); we could consider tweaking ratThresh (or adding something else) to trim the beginning. We could also consider increasing minPeak a little bit to drop it
* We think we're OK with losing Memphis, but should talk to Katie
* Perak is another argument for increasing minPeak
* Perak also points to a potential flaw in the algorithm; what should we do when the point-after-peak (which we want for egf) is classified as a separate phase. For now, we are dropping it, which doesn't seem stupid, but we should definitely not that we are doing that if we are.
* Serengeti phase 2 is keeping a double wave as one outbreak (because ratThresh is low; is that what we want?)
* Tokyo1 looks like a big mess to JD (both outbreaks are long and complicated)

2023 Dec 25 (Mon)
=================

Maybe we should put this on hold. What will it take to finish it?

1) Finish windowing (see Oct notes)

2) Apply epigrowthfit

3) re-assess

JD rebuilt a data-processing pipeline, there are some sharp questions in
monthly.md. We need to talk to Katie about this.

ML tried some egf experiments, but JD is pretty unhappy about the window
interface and the window logic; we should talk to Mikael.

… We have hacked around the window stuff, but there is too much we don't
understand about egf; should try to meet with Mikael instead of making ourselves
crazy.

2023 Oct 27 (Fri)
=================

We want the comparison with old window choices to be a side branch

JD wants to pre-screen series and break things with two “obvious” peaks

Mike wants to drop NYstate because it's not in the paper
* Can we cite it? Is the data set public?
* Mike: We can cite it, it is here. Note, KH did not have NYstate in the 2009 paper. The citation include both Central NY (in KH's paper) and NYstate (not in KH's paper). 
* https://ajph.aphapublications.org/doi/epdf/10.2105/AJPH.38.1_Pt_1.50


Set minmax (variable minPeak) to 12 which excludes HK, but maybe it should be a bit higher see below

Some thoughts:
• Break things that look like they have two peaks into two series
• Consider a slightly higher break either in general or for split series (worried about two fits for Serengeti)
• Should we start the second TS one step before the trough to avoid a bias that comes from starting from the very lowest point – we think yes
* Should there be a criterion for window length? Yes TODO when we do the splitting
* Note that we are taking old windows and splitting them. This means that we've thrown away anything after the global peak before we split.

2023 Oct 18 (Wed)
=================
We are revisiting data series and window choices.

There are at least 3 data series that never have >10 cases per month. Can we just throw them out?? Yes.

Multi-peak
* Kanagawa looks OK (we pick the first peak automatically)
* Tokyo (Tokyo1 is the new name) wants to pick a two-peak window, so we need to do something
* NYstatecounties seems similar to Tokyo

Let's take a look first at the old window selections
* Still happy with throwing out 3 series that have <10 cases in each month
* Serengeti does not peak; will change the code to use it up until the end
* Tokyo2 also fluctuates wildly within window, maybe drop it manually?
* NYstate used to use the small first peak.

Conclusion for the day:
* auto-drop 3 small series (<10 cases as the max)
* Fix serengeti limit
* worry about Tokyo1, Tokyo2, NYstate
