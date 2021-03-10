** In this dofile we attempt RIF on DFL
** !!!!!!! FIXMEs and gotchas !!!!!!!

** gen kde by hispracesex and covered for all yrs together

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
log using $dfl1/rifreg1.log, replace

use cleaned_nber_morg, clear

do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1
drop if lwage3 ==.

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

** hours weighted
gen hweight = eweight * uhourse / 100.0

** NOTE in current draft we have not dropped <83, self empl + w/o pay
********************************************************************************

drop if year < 1983

** men
preserve
keep if sex == 1

qui sum lwage3, detail

gen xstep = (r(max) - r(min)) / 200

gen kwage = r(min) + (_n-1)*xstep if _n <= 200

kdensity lwage3 [aweight = hweight] if hisprace == 1, at(kwage) gauss width(0.065) ///
	generate(wmestpt wmde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 2, at(kwage) gauss width(0.065) ///
	generate(bmestpt bmde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 3, at(kwage) gauss width(0.065) ///
	generate(hmestpt hmde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 1 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(u_wmestpt u_wmde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 1 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(n_wmestpt n_wmde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 2 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(u_bmestpt u_bmde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 2 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(nbmestpt n_bmde) nograph
	
** lab wmestpt "non hisp white men estimation points"
** lab wmde "non hisp white men density estimate"

** probability of race that depends on other covariates

local nhr w b

clonevar nhrace = hisprace

replace nhrace =. if nhrace == 3

keep if inrange(nhrace, 1, 2)

gen nhblack = nhrace - 1

gen finalwt1 = round(eweight)

drop nind

rename nind2 nind

drop nocc2

recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
		(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)
		
recode nocc2 (1 2 3 4 5 = 1) (6 7 8 = 2) (9 = 3) (10 11 12 = 4), gen(nocc3)

drop edex

gen edex = educ*exper

probit nhblack educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc3 i.quarter i.year [w = finalwt1]
	predict pb1m

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc3 i.quarter i.year if nhblack == 1 [w = finalwt1]
	predict pu1b1m

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc3 i.quarter i.year if nhblack == 0 [w = finalwt1]
	predict pu1b0m

gen theta2m = (pb1m/(1-pb1m)) * (pu1b1m/pu1b0m) if nhblack == 0 & covered == 1

replace theta2m = theta2m * hweight if nhblack == 0 & covered == 1

kdensity lwage3 [aweight = theta2m] if hisprace == 1 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(cu_wmestpt cu_wmde) nograph
	
gen theta3m = (pb1m/(1-pb1m)) * ((1-pu1b1m)/(1-pu1b1m)) if nhblack == 0 & covered == 0

replace theta3m = theta3m * hweight if nhblack == 0 & covered == 0

kdensity lwage3 [aweight = theta3m] if hisprace == 1 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(cn_wmestpt cn_wmde) nograph

** median
qui tab state,	 gen(dumstate)
qui tab year,	 gen(dumyear)
qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc3, 	 gen(dumnocc3)
qui tab quarter, gen(dumquarter)

** note collinearity from dummy variable trap
** RIF for white men covered by a union et no
forvalues qt = 20(30)80{
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 1 & covered == 1 [w = hweight], q(`qt') retain(rifwmu_`qt')
	
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 2 & covered == 1 [w = hweight], q(`qt') retain(rifbmu_`qt')
	
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 1 & covered == 1 [w = theta2m], q(`qt') retain(rifwmcu_`qt')
	
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 1 & covered == 0 [w = hweight], q(`qt') retain(rifwmn_`qt')
	
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 2 & covered == 0 [w = hweight], q(`qt') retain(rifbmn_`qt')
	
	rifreg lwage3 dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* if hisprace == 1 & covered == 0 [w = theta3m], q(`qt') retain(rifwmcn_`qt')
	
}

** Oaxaca-Blinder decomposition for wage structure : covered == 1 - could try backing out decomposition for composition by running decomposition for overall and subtracting
gen rifat_betx =.

forvalues qt = 20(30)80{
	replace rifat_betx = rifwmcu_`qt' if hisprace == 1
	
	replace rifat_betx = rifbmu_`qt' if hisprace == 2
	
	oaxaca rifat_betx dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc3* dumquarter* [aweight = hweight?] if hisprace == 1 | hisprace == 2 ? //theta or hweight or both by bringing in for missing?
	
	** FIXME review Q3 of file:///Users/amedeusdsouza/Desktop/econ560_320/a3econ561_20.pdf
	
}
