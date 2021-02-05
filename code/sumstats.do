** In this do file we gen table 1 - sample means of covered umem lwage3 educ exper public

clear *

********************************************************************************
*********************************** PREAMBLE ***********************************
********************************************************************************

cd /Users/amedeusdsouza/Desktop/econ499data/morg/clean_nber_morg_output

global code "/Users/amedeusdsouza/econ499/code"
global tabs "/Users/amedeusdsouza/econ499/tabs"
global figs "/Users/amedeusdsouza/econ499/figures"

use cleaned_nber_morg, clear

do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1
drop if lwage3 ==.

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

********************************************************************************

keep covered umem lwage3 educ exper elig public race sex year eweight

cd $tabs

** mean
qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 1 & sex == 1, by(year)
esttab using 1wm_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Mean - White Men) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 1 & sex == 2, by(year)
esttab using 1wf_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Mean - White Women) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 2 & sex == 1, by(year)
esttab using 1bm_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Mean - Black Men) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 2 & sex == 2, by(year)
esttab using 1bf_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Mean - Black Women) replace

** sd

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 1 & sex == 1, by(year) statistics(sd)
esttab using 2wm_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Standard Deviation - White Men) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 1 & sex == 2, by(year) statistics(sd)
esttab using 2wf_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Standard Deviation - White Women) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 2 & sex == 1, by(year) statistics(sd)
esttab using 2bm_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Standard Deviation - Black Men) replace

qui estpost tabstat covered umem lwage3 educ exper public [aweight = eweight] if race == 2 & sex == 2, by(year) statistics(sd)
esttab using 2bf_sumstats.tex, cells("covered umem lwage3 educ exper public") nomtitles long title(Summary Statistics - Standard Deviation - Black Women) replace
