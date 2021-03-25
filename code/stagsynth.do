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
log using $linreg/stagsynth.log, replace

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

** gen panel data
drop if year < 1996 // need without breaks

drop if alwaysr2w == 1 // keep neverr2w and treatments from policy variation

** WHITE MEN
preserve

keep if female == 0 & blackrelwhite == 0

qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

ds state year nind ee_cl nocc2 quarter, not 

collapse (mean) `r(varlist)' [aw = finalwt1], by(state year)

tsset state year

** OK
** construct synthetic OK
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2000), trunit(73) trperiod(2001) nested allopt fig keep($linreg/synth_wm_ok) replace

graph export $figs/synth_wm_ok.png

**placebo



** IN
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2011), trunit(32) trperiod(2012) nested allopt fig keep($linreg/synth_wm_in) replace

graph export $figs/synth_wm_in.png

** MI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2012), trunit(34) trperiod(2013) nested allopt fig keep($linreg/synth_wm_mi) replace

graph export $figs/synth_wm_mi.png

** WI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2014), trunit(35) trperiod(2015) nested allopt fig keep($linreg/synth_wm_wi) replace

graph export $figs/synth_wm_wi.png

** WV
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2015), trunit(55) trperiod(2016) nested allopt fig keep($linreg/synth_wm_wv) replace

graph export $figs/synth_wm_wv.png

** KY
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 lwage3(1996(1)2016), trunit(61) trperiod(2017) nested allopt fig keep($linreg/synth_wm_ky) replace

graph export $figs/synth_wm_ky.png

restore

** WHITE WOMEN
preserve

keep if female == 1 & blackrelwhite == 0

qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

ds state year nind ee_cl nocc2 quarter, not 

collapse (mean) `r(varlist)' [aw = finalwt1], by(state year)

tsset state year

** OK
** construct synthetic OK - allopt time consuming on laptop
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2000), trunit(73) trperiod(2001) nested allopt fig keep($linreg/synth_wf_ok) replace

graph export $figs/synth_wf_ok.png

**placebo



** IN
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2011), trunit(32) trperiod(2012) nested allopt fig keep($linreg/synth_wf_in) replace

graph export $figs/synth_wf_in.png

** MI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2012), trunit(34) trperiod(2013) nested allopt fig keep($linreg/synth_wf_mi) replace

graph export $figs/synth_wf_mi.png

** WI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2014), trunit(35) trperiod(2015) nested allopt fig keep($linreg/synth_wf_wi) replace

graph export $figs/synth_wf_wi.png

** WV
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2015), trunit(55) trperiod(2016) nested allopt fig keep($linreg/synth_wf_wv) replace

graph export $figs/synth_wf_wv.png

** KY
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2016), trunit(61) trperiod(2017) nested allopt fig keep($linreg/synth_wf_ky) replace

graph export $figs/synth_wf_ky.png

restore

** BLACK MEN
preserve

keep if female == 0 & blackrelwhite == 1

qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

ds state year nind ee_cl nocc2 quarter, not 

collapse (mean) `r(varlist)' [aw = finalwt1], by(state year)

tsset state year

** OK
** construct synthetic OK
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2000), trunit(73) trperiod(2001) nested allopt fig keep($linreg/synth_bm_ok) replace

graph export $figs/synth_bm_ok.png

**placebo



** IN
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2011), trunit(32) trperiod(2012) nested allopt fig keep($linreg/synth_bm_in) replace

graph export $figs/synth_bm_in.png

** MI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2012), trunit(34) trperiod(2013) nested allopt fig keep($linreg/synth_bm_mi) replace

graph export $figs/synth_bm_mi.png

** WI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2014), trunit(35) trperiod(2015) nested allopt fig keep($linreg/synth_bm_wi) replace

graph export $figs/synth_bm_wi.png

** WV
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2015), trunit(55) trperiod(2016) nested allopt fig keep($linreg/synth_bm_wv) replace

graph export $figs/synth_bm_wv.png

** KY
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2016), trunit(61) trperiod(2017) nested allopt fig keep($linreg/synth_bm_ky) replace

graph export $figs/synth_bm_ky.png

restore

** BLACK WOMEN
preserve

keep if female == 1 & blackrelwhite == 1

qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

ds state year nind ee_cl nocc2 quarter, not 

collapse (mean) `r(varlist)' [aw = finalwt1], by(state year)

tsset state year

** OK
** construct synthetic OK
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2000), trunit(73) trperiod(2001) nested allopt fig keep($linreg/synth_bf_ok) replace

graph export $figs/synth_bf_ok.png

**placebo



** IN
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2011), trunit(32) trperiod(2012) nested allopt fig keep($linreg/synth_bf_in) replace

graph export $figs/synth_bf_in.png

** MI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2012), trunit(34) trperiod(2013) nested allopt fig keep($linreg/synth_bf_mi) replace

graph export $figs/synth_bf_mi.png

** WI
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2014), trunit(35) trperiod(2015) nested allopt fig keep($linreg/synth_bf_wi) replace

graph export $figs/synth_bf_wi.png

** WV
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2015), trunit(55) trperiod(2016) nested allopt fig keep($linreg/synth_bf_wv) replace

graph export $figs/synth_bf_wv.png

** KY
synth lwage3 dumnind1 dumnind2 dumnind3 dumnind4 dumnind5 dumnind6 dumnind7 dumnind8 dumnind9 dumnind10 dumnind11 educ exper exper2 exper3 exper4 edex dumee_cl1 dumee_cl2 dumee_cl3 dumee_cl4 dumee_cl5 dumee_cl6 dumee_cl7 dumee_cl8 dumee_cl9 dumee_cl10 dumee_cl11 dumee_cl12 dumee_cl13 dumee_cl14 dumee_cl15 dumee_cl16 marr partt public cmsa dumnocc21 dumnocc22 dumnocc23 dumnocc24 dumnocc25 dumnocc26 dumnocc27 dumnocc28 dumnocc29 dumnocc210 dumnocc211 dumnocc212 dumquarter1 dumquarter2 dumquarter3 dumquarter4 lwage3(1996(1)2016), trunit(61) trperiod(2017) nested allopt fig keep($linreg/synth_bf_ky) replace

graph export $figs/synth_bf_ky.png

restore


			
log close 

