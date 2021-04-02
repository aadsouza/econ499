** In this dofile we look at parallel trends assumpiton for staggered DiD analysis of RTW laws

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
log using $linreg/stagpta.log, replace

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

** no pretrends for before treatments before 2000
drop if alwaysr2w == 1

** gen event =.
** 	replace event = 1989 if alwaysr2w == 1
**	replace event = 2001 if state == 73
**	replace event = 2012 if state == 32
**	replace event = 2013 if state == 34
**	replace event = 2015 if state == 35
**	replace event = 2016 if state == 55
**	replace event = 2017 if state == 61
	
** gen postevent =.
**	replace postevent = 1 if (year >= event & inlist(state, 73, 32, 34, 35, 55, 61)) | alwaysr2w == 1
**	replace postevent = 0 if year < event & inlist(state, 73, 32, 34, 35, 55, 61)
**	replace postevent = 0 if neverr2w == 1

** gen timetoevent = year - event

gen lag5 = 0
	replace lag5 = 1 if state == 73 & date <= (500 - (4*12))
	replace lag5 = 1 if state == 32 & date <= (625 - (4*12))
	replace lag5 = 1 if state == 34 & date <= (638 - (4*12))
	replace lag5 = 1 if state == 35 & date <= (662 - (4*12))
	replace lag5 = 1 if state == 55 & date <= (678 - (4*12))
	replace lag5 = 1 if state == 61 & date <= (684 - (4*12))
	
gen lag4 = 0
	replace lag4 = 1 if state == 73 & (500 - (4*12)) < date & date <= (500 - (3*12))
	replace lag4 = 1 if state == 32 & (625 - (4*12)) < date & date <= (625 - (3*12))
	replace lag4 = 1 if state == 34 & (638 - (4*12)) < date & date <= (638 - (3*12))
	replace lag4 = 1 if state == 35 & (662 - (4*12)) < date & date <= (662 - (3*12))
	replace lag4 = 1 if state == 55 & (678 - (4*12)) < date & date <= (678 - (3*12))
	replace lag4 = 1 if state == 61 & (684 - (4*12)) < date & date <= (684 - (3*12))
	
gen lag3 = 0
	replace lag3 = 1 if state == 73 & (500 - (3*12)) < date & date <= (500 - (2*12))
	replace lag3 = 1 if state == 32 & (625 - (3*12)) < date & date <= (625 - (2*12))
	replace lag3 = 1 if state == 34 & (638 - (3*12)) < date & date <= (638 - (2*12))
	replace lag3 = 1 if state == 35 & (662 - (3*12)) < date & date <= (662 - (2*12))
	replace lag3 = 1 if state == 55 & (678 - (3*12)) < date & date <= (678 - (2*12))
	replace lag3 = 1 if state == 61 & (684 - (3*12)) < date & date <= (684 - (2*12))
	
gen lag2 = 0
	replace lag2 = 1 if state == 73 & (500 - (2*12)) < date & date <= (500 - (1*12))
	replace lag2 = 1 if state == 32 & (625 - (2*12)) < date & date <= (625 - (1*12))
	replace lag2 = 1 if state == 34 & (638 - (2*12)) < date & date <= (638 - (1*12))
	replace lag2 = 1 if state == 35 & (662 - (2*12)) < date & date <= (662 - (1*12))
	replace lag2 = 1 if state == 55 & (678 - (2*12)) < date & date <= (678 - (1*12))
	replace lag2 = 1 if state == 61 & (684 - (2*12)) < date & date <= (684 - (1*12))

gen lead0 = 0
	replace lead0 = 1 if state == 73 & (500 + (0*12)) < date & date <= (500 + (1*12))
	replace lead0 = 1 if state == 32 & (625 + (0*12)) < date & date <= (625 + (1*12))
	replace lead0 = 1 if state == 34 & (638 + (0*12)) < date & date <= (638 + (1*12))
	replace lead0 = 1 if state == 35 & (662 + (0*12)) < date & date <= (662 + (1*12))
	replace lead0 = 1 if state == 55 & (678 + (0*12)) < date & date <= (678 + (1*12))
	replace lead0 = 1 if state == 61 & (684 + (0*12)) < date & date <= (684 + (1*12))
	
gen lead1 = 0
	replace lead1 = 1 if state == 73 & (500 + (1*12)) < date & date <= (500 + (2*12))
	replace lead1 = 1 if state == 32 & (625 + (1*12)) < date & date <= (625 + (2*12))
	replace lead1 = 1 if state == 34 & (638 + (1*12)) < date & date <= (638 + (2*12))
	replace lead1 = 1 if state == 35 & (662 + (1*12)) < date & date <= (662 + (2*12))
	replace lead1 = 1 if state == 55 & (678 + (1*12)) < date & date <= (678 + (2*12))
	replace lead1 = 1 if state == 61 & (684 + (1*12)) < date & date <= (684 + (2*12))

gen lead2 = 0
	replace lead2 = 1 if state == 73 & (500 + (2*12)) < date 
	replace lead2 = 1 if state == 32 & (625 + (2*12)) < date 
	replace lead2 = 1 if state == 34 & (638 + (2*12)) < date 
	replace lead2 = 1 if state == 35 & (662 + (2*12)) < date 
	replace lead2 = 1 if state == 55 & (678 + (2*12)) < date
	replace lead2 = 1 if state == 61 & (684 + (2*12)) < date
	
gen lag5black = lag5*blackrelwhite
gen lag4black = lag4*blackrelwhite
gen lag3black = lag3*blackrelwhite
gen lag2black = lag2*blackrelwhite
gen lead0black = lead0*blackrelwhite
gen lead1black = lead1*blackrelwhite
gen lead2black = lead2*blackrelwhite

** label variable lag5 "-5"
** label variable lag4 "-4"
** label variable lag3 "-3"
** label variable lag2 "-2"
** label variable lead0 "0"
** label variable lead1 "1"
** label variable lead2 "2"

** pta WV drop, common support MT, ME, NH, VT
drop if inlist(state, 55, 81, 11, 12, 13)

reg covered lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("RTW on Coverage for Men - Coefs on Leads and Lags")
graph export "$figs/eventstd/evs_covstag_mal.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("RTW on Coverage for Men - Coefs on Leads and Lags with Interaction")
graph export "$figs/eventstd/evs_covstag_mal_blk.png", replace

reg covered lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("RTW on Coverage for Women - Coefs on Leads and Lags")
graph export "$figs/eventstd/evs_covstag_fem.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("RTW on Coverage for Women - Coefs on Leads and Lags with Interaction")
graph export "$figs/eventstd/evs_covstag_fem_blk.png", replace

reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Men" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_wagstag_mal.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Black Men" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_wagstag_mal_blk.png", replace	

reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_wagstag_fem.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Black Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_wagstag_fem_blk.png", replace	

reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Non-Union Men"  "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_nwagstag_mal.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Non-Union Black Men" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_nwagstag_mal_blk.png", replace
	
reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Non-Union Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_nwagstag_fem.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Non-Union Black Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_nwagstag_fem_blk.png", replace

reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 0 & covered == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Union Men" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_uwagstag_mal.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Black Union Men" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_uwagstag_mal_blk.png", replace	

reg lwage3 lag5 lag4 lag3 lag2 lead0 lead1 lead2 lag5black lag4black lag3black lag2black lead0black lead1black lead2black blackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter unemp [aw = finalwt1] if female == 1 & covered == 0, vce(cluster state)

coefplot, vertical yline(0) keep(lag5 lag4 lag3 lag2 lead0 lead1 lead2) title("Effect of RTW on Real Log Wages for Union Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_uwagstag_fem.png", replace
coefplot, vertical yline(0) keep(lag5black lag4black lag3black lag2black lead0black lead1black lead2black) title("Surplus Effect of RTW on Real Log Wages for Black Union Women" "Coefficients on Leads and Lags")
graph export "$figs/eventstd/fin_evs_uwagstag_fem_blk.png", replace



log close
