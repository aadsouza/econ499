** In this dofile we attempt staggered DiD analysis of RTW laws dropping always r2w states

clear *

********************************************************************************
*********************************** PREAMBLE ***********************************
********************************************************************************

** ssc install grstyle, replace 
** ssc install palettes, replace 
** ssc install xtable, replace 

set scheme s2color 
grstyle init 
grstyle set compact 
grstyle set horizontal 
grstyle set legend 6, nobox 
grstyle color background white 
grstyle color major_grid black%10

cd /Users/amedeusdsouza/Desktop/econ499data/morg/clean_nber_morg_output

global code "/Users/amedeusdsouza/econ499/code"
global tabs "/Users/amedeusdsouza/econ499/tabs"
global figs "/Users/amedeusdsouza/econ499/figures"
global estimation "/Users/amedeusdsouza/Desktop/econ499data/estimation"
global distreg "/Users/amedeusdsouza/econ499/distreg"
global mwagedata "/Users/amedeusdsouza/Desktop/econ499data/zipperer-min-wage"
global linreg "/Users/amedeusdsouza/econ499/linreg"
global dfl1 "/Users/amedeusdsouza/econ499/dfl1"

cap log close
log using $linreg/stagdid-wo-ar2w.log, replace

use cleaned_nber_morg, clear

do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1
drop if lwage3 ==.

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

** hours weighted
gen hweight = eweight * uhourse / 100.0

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)
********************************************************************************

** keep if inrange(year, 2000, 2019)

keep if inrange(year, 1989, 2019)

rename twage nwage1

keep state year cmonth quarter nwage1 lwage1 lwage3 hourly exper* educ ee_cl female nind2 nocc cmsa partt public marr hisprace hispracesex citizen eweight alloc1 covered umem

merge m:1 state year cmonth using "/Users/amedeusdsouza/Desktop/econ499data/morg/clean_nber_morg_output/unemp.dta"

drop if _merge == 2 // <2000

drop if hispracesex ==.

gen finalwt1 = round(eweight)

rename nind2 nind // nind now is 11 ind categories

recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
		(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)
		
recode nocc2 (1 2 3 4 5 = 1) (6 7 8 = 2) (9 = 3) (10 11 12 = 4), gen(nocc3)

egen state_ind = group(state nind)

gen edex = educ*exper

gen blackrelwhite = hisprace - 1
	replace blackrelwhite =. if hisprace > 2

gen hisprelwhite = hisprace - 1
	replace hisprelwhite =. if hisprace == 2
	replace hisprelwhite = 1 if hisprace == 3

gen date = ym(year, cmonth)
** tab date year

** construct variables lags and leads
local newr2wstates "73 32 34 35 55 61"

** local date "500 625 638 662 673 684" // Sep1,2001(Sep28,2001) Feb1,2012(Mar14,2012) Mar1,2013(28 effective; signed Dec2012) Mar1,2015(Mar11,2015) Feb1,2016(effectiveJuly1,2016) Jan1,2017(7)
local newr2wdate "500 625 638 662 678 684"

gen alwaysr2w = 0
	replace alwaysr2w = 1 if /// 
		inlist(state, 71, 59, 86, 46, 54, 62, 56, 58, 42, 45, 74, 44, 88, 63, 64, 57, 87, 47, 83, 72, 82) //incl Idaho which changed in 1985 and Texas which had since 47 but bolstered in 93

gen alwr2wcov = alwaysr2w*covered

gen neverr2w = 1
	replace neverr2w = 0 if inlist(state, 71, 59, 86, 46, 54, 62, 56, 58, 42, 45, 74, 44, 88, 63, 64, 57, 87, 47, 83, 72, 82)
	replace neverr2w = 0 if inlist(state, 73, 32, 34, 35, 55, 61)

gen stater2w = 0
	replace stater2w = 1 if inlist(state, 71, 59, 86, 46, 54, 62, 56, 58, 42, 45, 74, 44, 88, 63, 64, 57, 87, 47, 83, 72, 82)
	replace stater2w = 2 if inlist(state, 73, 32, 34, 35, 55, 61)
	lab def str2w 0 "no r2w" 1 "r2w before 2000" 2 "r2w after 2000"
	lab val stater2w str2w

gen treat_st = 0 if stater2w == 0 | stater2w == 2
	replace treat_st = 1 if stater2w == 1
	replace treat_st = 1 if state == 73 & date >= 500
	replace treat_st = 1 if state == 32 & date >= 625
	replace treat_st = 1 if state == 34 & date >= 638
	replace treat_st = 1 if state == 35 & date >= 662
	replace treat_st = 1 if state == 55 & date >= 678
	replace treat_st = 1 if state == 61 & date >= 684
**	replace treat_st = 1 if public == 1 & date >= 701 // Janus v AFSCME June 2018 would need to change to treat_jst
	
gen treat_stblackrelwhite = treat_st*blackrelwhite

gen treat_sthisprelwhite = treat_st*hisprelwhite

gen lyear = year - 1900

drop if alwaysr2w == 1

eststo clear

** pta WV drop, common support MT, ME, NH, VT
drop if inlist(state, 55, 81, 11, 12, 13)

** BLACK-WHITE
reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0, vce(cluster state)

estadd local unemp_level "No"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo covstagdid_mal_all

reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo covstagdid_mal_all_unemp 

reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "No"
estadd local sltt "Yes"
eststo covstagdid_mal_all_sltt 
	
reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

estadd local unemp_level "No"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo covstagdid_fem_all

reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo covstagdid_fem_all_unemp 

reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "No"
estadd local sltt "Yes"
eststo covstagdid_fem_all_sltt 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0, vce(cluster state) 

** estadd local unemp_level "No"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo wagstagdid_mal_all 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state) 

** estadd local unemp_level "Yes"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo wagstagdid_mal_all_unemp

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state) 

** estadd local unemp_level "Yes"
** estadd local yr_dum "No"
** estadd local sltt "Yes"
eststo wagstagdid_mal_all_sltt  

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

** estadd local unemp_level "No"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo wagstagdid_fem_all 
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo wagstagdid_fem_all_unemp 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "No"
** estadd local sltt "Yes"
eststo wagstagdid_fem_all_sltt

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

** estadd local unemp_level "No"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo nwagstagdid_mal_all

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo nwagstagdid_mal_all_unemp 
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "No"
** estadd local sltt "Yes"
eststo nwagstagdid_mal_all_sltt 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

** estadd local unemp_level "No"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo nwagstagdid_fem_all 
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "Yes"
** estadd local sltt "No"
eststo nwagstagdid_fem_all_unemp 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

** estadd local unemp_level "Yes"
** estadd local yr_dum "No"
** estadd local sltt "Yes"
eststo nwagstagdid_fem_all_sltt 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0 & covered == 1, vce(cluster state)

estadd local unemp_level "No"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo uwagstagdid_mal_all 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo uwagstagdid_mal_all_unemp 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "No"
estadd local sltt "Yes"
eststo uwagstagdid_mal_all_sltt 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1 & covered == 1, vce(cluster state)

estadd local unemp_level "No"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo uwagstagdid_fem_all
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "Yes"
estadd local sltt "No"
eststo uwagstagdid_fem_all_unemp 

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 1, vce(cluster state)

estadd local unemp_level "Yes"
estadd local yr_dum "No"
estadd local sltt "Yes"
eststo uwagstagdid_fem_all_sltt

** RUST BELT ONLY BLACK-WHITE + WV, KY - IA
** keep if inrange(state, 31, 35) | inlist(state, 23, 41, 43) | inlist(state, 55, 61)

** DROP ALWAYS RTW BLACK-WHITE
** drop if alwaysr2w == 1

** reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state) 

** eststo covstagdid_mal_cf 
	
** reg covered blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

** eststo covstagdid_fem_cf 

** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0, vce(cluster state) 

** eststo wagstagdid_mal_cf 
	
** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1, vce(cluster state)

** eststo wagstagdid_fem_cf 

** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

** eststo nwagstagdid_mal_cf 
	
** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

** eststo nwagstagdid_fem_cf

** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 0 & covered == 1, vce(cluster state)

** eststo uwagstagdid_mal_cf 
	
** reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 unemp i.quarter [aw = finalwt1] if female == 1 & covered == 1, vce(cluster state)

** eststo uwagstagdid_fem_cf 

label variable blackrelwhite "$ Black $"
label variable treat_st "$ Treat_{st} $"
label variable treat_stblackrelwhite "$ Treat_{st} \times Black $"

** FIXME ignore rust best stuff, dropping always rtw
esttab covstagdid_mal_all covstagdid_mal_all_unemp covstagdid_mal_all_sltt covstagdid_fem_all covstagdid_fem_all_unemp covstagdid_fem_all_sltt using $tabs/covstagdid-wo-ar2w.tex, se title(Difference in Differences of Union Coverage on Right to Work Laws Treatment in State and Time - W/O Always RTW States) mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(blackrelwhite treat_st treat_stblackrelwhite) nomtitles replace label starlevels(* 0.1 ** 0.05 *** 0.01) scalars("unemp_level State Monthly Unemployment Rate" "yr_dum Year Fixed Effect" "sltt State Linear Time Trends")

esttab wagstagdid_mal_all wagstagdid_mal_all_unemp wagstagdid_mal_all_sltt wagstagdid_fem_all wagstagdid_fem_all_unemp wagstagdid_fem_all_sltt using $tabs/wagstagdid1-wo-ar2w.tex, se title(Difference in Differences of Real Log Wages on Right to Work Laws Treatment in State and Time - W/O Always RTW States) mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(blackrelwhite treat_st treat_stblackrelwhite) nomtitles replace label starlevels(* 0.1 ** 0.05 *** 0.01) 

esttab nwagstagdid_mal_all nwagstagdid_mal_all_unemp nwagstagdid_mal_all_sltt nwagstagdid_fem_all nwagstagdid_fem_all_unemp nwagstagdid_fem_all_sltt using $tabs/wagstagdid2-wo-ar2w.tex, se title(Difference in Differences of Real Log Wages on Right to Work Laws Treatment in State and Time - W/O Always RTW States) mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(blackrelwhite treat_st treat_stblackrelwhite) nomtitles replace label starlevels(* 0.1 ** 0.05 *** 0.01)

esttab uwagstagdid_mal_all uwagstagdid_mal_all_unemp uwagstagdid_mal_all_sltt uwagstagdid_fem_all uwagstagdid_fem_all_unemp uwagstagdid_fem_all_sltt using $tabs/wagstagdid3-wo-ar2w.tex, se title(Difference in Differences of Real Log Wages on Right to Work Laws Treatment in State and Time - W/O Always RTW States) mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(blackrelwhite treat_st treat_stblackrelwhite) nomtitles replace label starlevels(* 0.1 ** 0.05 *** 0.01) scalars("unemp_level State Monthly Unemployment Rate" "yr_dum Year Fixed Effect" "sltt State Linear Time Trends")

panelcombine, use($tabs/wagstagdid1-wo-ar2w.tex $tabs/wagstagdid2-wo-ar2w.tex $tabs/wagstagdid3-wo-ar2w.tex) paneltitles("All (Black and White) People" "People Not Covered by Union - Spillover Effect" "People Covered by Union - Direct Effect") columncount(3) save($tabs/fin_wagstagdid-wo-ar2w.tex)

*** esttab wagstagdid_mal_all wagstagdid_fem_all nwagstagdid_mal_all nwagstagdid_fem_all uwagstagdid_mal_all uwagstagdid_fem_all using $tabs/wagstagdid.tex, se title(Difference in Differences of Real Log Wages on Right to Work Laws Treatment in State and Time) nonumbers mtitles("men" "women" "men not covered by union" "women not covered by union" "men covered by union" "women covered by union") keep(blackrelwhite treat_st treat_stblackrelwhite) replace

** esttab wagstagdid_mal_cf wagstagdid_fem_cf nwagstagdid_mal_cf nwagstagdid_fem_cf uwagstagdid_mal_cf uwagstagdid_fem_cf using $tabs/wagstagdid_cf.tex, se title(Difference in Differences of Real Log Wages on Right to Work Laws Treatment in State and Time) nonumbers mtitles("men" "women" "men not covered by union" "women not covered by union" "men covered by union" "women covered by union") keep(blackrelwhite treat_st treat_stblackrelwhite) replace

** panelcombine, use($tabs/wagstagdid_all.tex $tabs/wagstagdid_cf.tex) paneltitles("All States" "W/O Always RTW States") columncount(3) save($tabs/wagstagdid.tex)

log close 

