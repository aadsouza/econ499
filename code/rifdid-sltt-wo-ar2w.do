** In this dofile we run rifdid with state linear time trends to check if anything else is going on

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
log using $linreg/rifdid-sltt-wo-ar2w.log, replace

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

** FIXME - decide why (current from diagnostics)
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

** mean with nocc3 with quarter fe
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0, vce(cluster state)
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1, vce(cluster state)

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0 & covered == 1, vce(cluster state)
	
reg lwage3 blackrelwhite treat_st treat_stblackrelwhite i.state i.state#c.lyear i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt  public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1 & covered == 1, vce(cluster state)

** RIF-DiD with nocc2
qui tab state,	 gen(dumstate)
qui tab year,	 gen(dumyear)
qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

levelsof state
foreach i in `r(levels)'{
	gen statetrend`i' = lyear
		replace statetrend`i' = 0 if state != `i'
}

** note collinearity from dummy variable trap ?
** with quarter fe 
putexcel set $linreg/rifdid_coefs-sltt-wo-ar2w, replace sheet("data")
	putexcel A1 = "name"
	putexcel B1 = "coef"
	putexcel C1 = "bse"
	putexcel D1 = "lb"
	putexcel E1 = "ub"
	
local row = 2

forvalues qt = 10(10)90{
	di "men at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "m_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "m_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "m_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1
	
	di "women at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "f_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "f_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "f_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1
	
	di "men not covered by union at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 0 & covered == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "nm_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "nm_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "nm_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1	
	
	di "women not covered by union at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 1 & covered == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "nf_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "nf_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "nf_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1	
	
	di "men covered by union at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 0 & covered == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "um_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "um_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "um_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1		

	di "women covered by union at `qt' quantile"
	rifreg lwage3 blackrelwhite treat_st treat_stblackrelwhite dumstate* statetrend* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* unemp if female == 1 & covered == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "uf_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "uf_treat_st`qt'"
		putexcel B`row' = _b[treat_st]
		putexcel C`row' = _se[treat_st]
		putexcel D`row' = (_b[treat_st] - invttail(e(df_r), 0.025) * _se[treat_st])
		putexcel E`row' = (_b[treat_st] + invttail(e(df_r), 0.025) * _se[treat_st])
		
		local row = `row' + 1
		
		putexcel A`row' = "uf_times`qt'"
		putexcel B`row' = _b[treat_stblackrelwhite]
		putexcel C`row' = _se[treat_stblackrelwhite]
		putexcel D`row' = (_b[treat_stblackrelwhite] - invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
		putexcel E`row' = (_b[treat_stblackrelwhite] + invttail(e(df_r), 0.025) * _se[treat_stblackrelwhite])
	
		local row = `row' + 1	
	
}

log close
