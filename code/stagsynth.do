** In this dofile we test parallel trends assumption with plots

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
log using $linreg/stagdid-ptaplot.log, replace

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

gen r2wstates = 0 if neverr2w == 1
	replace r2wstates = 1 if alwaysr2w == 1
	replace r2wstates = 73 if state == 73
	replace r2wstates = 32 if state == 32
	replace r2wstates = 34 if state == 34
	replace r2wstates = 35 if state == 35
	replace r2wstates = 55 if state == 55
	replace r2wstates = 61 if state == 61

preserve

reg lwage3 i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0 & blackrelwhite == 0, vce(cluster state)
predict plwage3

keep plwage3 year r2wstates finalwt1

collapse (mean) plwage3 [aw = finalwt1], by(year r2wstates)
	
twoway 	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 73), ///
		legend(label(1 "Never RTW States") label(2 "Oklahoma")) ///
		title("Oklahoma (2001) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2001, lcolor(red)) xlabel(1989(2)2019)
		
graph export "$figs/pta/wm_ok.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 32), ///
		legend(label(1 "Never RTW States") label(2 "Indiana")) ///
		title("Indiana (2012) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2012, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/wm_in.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 34), ///
		legend(label(1 "Never RTW States") label(2 "Michigan")) ///
		title("Michigan (2013) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2013, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/wm_mi.png", replace

twoway	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 35), ///
		legend(label(1 "Never RTW States") label(2 "Wisconsin")) ///
		title("Wisconsin (2015) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2015, lcolor(red)) xlabel(1989(2)2019)				

graph export "$figs/pta/wm_wi.png", replace
		
twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 55), ///
		legend(label(1 "Never RTW States") label(2 "West Virginia")) ///
		title("West Virginia (2016) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2016, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/wm_wv.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 61), ///
		legend(label(1 "Never RTW States") label(2 "Kentucky")) ///
		title("Kentucky (2017) - All White Men") ytitle("Mean Predicted Real Log Wages of White Men") ///
		xline(2017, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/wm_ky.png", replace

restore

preserve

reg lwage3 i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 0 & blackrelwhite == 1, vce(cluster state)
predict plwage3

keep plwage3 year r2wstates finalwt1

collapse (mean) plwage3 [aw = finalwt1], by(year r2wstates)
	
twoway 	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 73), ///
		legend(label(1 "Never RTW States") label(2 "Oklahoma")) ///
		title("Oklahoma (2001) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2001, lcolor(red)) xlabel(1989(2)2019)
		
graph export "$figs/pta/bm_ok.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 32), ///
		legend(label(1 "Never RTW States") label(2 "Indiana")) ///
		title("Indiana (2012) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2012, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/bm_in.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 34), ///
		legend(label(1 "Never RTW States") label(2 "Michigan")) ///
		title("Michigan (2013) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2013, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/bm_mi.png", replace

twoway	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 35), ///
		legend(label(1 "Never RTW States") label(2 "Wisconsin")) ///
		title("Wisconsin (2015) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2015, lcolor(red)) xlabel(1989(2)2019)				

graph export "$figs/pta/bm_wi.png", replace
		
twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 55), ///
		legend(label(1 "Never RTW States") label(2 "West Virginia")) ///
		title("West Virginia (2016) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2016, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/bm_wv.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 61), ///
		legend(label(1 "Never RTW States") label(2 "Kentucky")) ///
		title("Kentucky (2017) - All Black Men") ytitle("Mean Predicted Real Log Wages of Black Men") ///
		xline(2017, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/bm_ky.png", replace

restore

preserve

reg lwage3 i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1 & blackrelwhite == 0, vce(cluster state)
predict plwage3

keep plwage3 year r2wstates finalwt1

collapse (mean) plwage3 [aw = finalwt1], by(year r2wstates)
	
twoway 	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 73), ///
		legend(label(1 "Never RTW States") label(2 "Oklahoma")) ///
		title("Oklahoma (2001) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2001, lcolor(red)) xlabel(1989(2)2019)
		
graph export "$figs/pta/wf_ok.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 32), ///
		legend(label(1 "Never RTW States") label(2 "Indiana")) ///
		title("Indiana (2012) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2012, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/wf_in.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 34), ///
		legend(label(1 "Never RTW States") label(2 "Michigan")) ///
		title("Michigan (2013) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2013, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/wf_mi.png", replace

twoway	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 35), ///
		legend(label(1 "Never RTW States") label(2 "Wisconsin")) ///
		title("Wisconsin (2015) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2015, lcolor(red)) xlabel(1989(2)2019)				

graph export "$figs/pta/wf_wi.png", replace
		
twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 55), ///
		legend(label(1 "Never RTW States") label(2 "West Virginia")) ///
		title("West Virginia (2016) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2016, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/wf_wv.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 61), ///
		legend(label(1 "Never RTW States") label(2 "Kentucky")) ///
		title("Kentucky (2017) - All White Women") ytitle("Mean Predicted Real Log Wages of White Women") ///
		xline(2017, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/wf_ky.png", replace

restore

preserve

reg lwage3 i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter [aw = finalwt1] if female == 1 & blackrelwhite == 1, vce(cluster state)
predict plwage3

keep plwage3 year r2wstates finalwt1

collapse (mean) plwage3 [aw = finalwt1], by(year r2wstates)
	
twoway 	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 73), ///
		legend(label(1 "Never RTW States") label(2 "Oklahoma")) ///
		title("Oklahoma (2001) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2001, lcolor(red)) xlabel(1989(2)2019)
		
graph export "$figs/pta/bf_ok.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 32), ///
		legend(label(1 "Never RTW States") label(2 "Indiana")) ///
		title("Indiana (2012) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2012, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/bf_in.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 34), ///
		legend(label(1 "Never RTW States") label(2 "Michigan")) ///
		title("Michigan (2013) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2013, lcolor(red)) xlabel(1989(2)2019)

graph export "$figs/pta/bf_mi.png", replace

twoway	(connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 35), ///
		legend(label(1 "Never RTW States") label(2 "Wisconsin")) ///
		title("Wisconsin (2015) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2015, lcolor(red)) xlabel(1989(2)2019)				

graph export "$figs/pta/bf_wi.png", replace
		
twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 55), ///
		legend(label(1 "Never RTW States") label(2 "West Virginia")) ///
		title("West Virginia (2016) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2016, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/bf_wv.png", replace

twoway  (connected plwage3 year if r2wstates == 0) ///
		(connected plwage3 year if r2wstates == 61), ///
		legend(label(1 "Never RTW States") label(2 "Kentucky")) ///
		title("Kentucky (2017) - All Black Women") ytitle("Mean Predicted Real Log Wages of Black Women") ///
		xline(2017, lcolor(red)) xlabel(1989(2)2019)	

graph export "$figs/pta/bf_ky.png", replace

restore
			
log close 

