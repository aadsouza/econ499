** In this model we prepare the data for the distribution regressions following
** FLL2021

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

use cleaned_nber_morg, clear

** FIXME notice that FLL2021 do not use pareto data for dist reg?
** do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1

** use twage : nwage1 equiv
drop if twage ==.

** FIXME currently only using MORG so >=83 - merge to gen may_morg
drop if year < 1983

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

** hours weighted
gen hweight = eweight * uhourse / 100.0

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)

cap log close
log using $distreg/didst_dataprep.log, replace
********************************************************************************

rename twage nwage1

** 0019 uses years 00 - 19
keep if inrange(year, 2000, 2019)

** keep needed variables
** FIXME add partt to list once defined in clean_nber_morg
keep state year quarter nwage1 lwage1 paidhre exper educ female nind nocc cmsa public marr hisprace hispracesex eweight alloc1

rename year syear1

gen finalwt1 = round(eweight)

save "$estimation/est_dat.dta", replace

sum nwage1 lwage1

local hrs = 1 //hispracesex macro

while `hrs' <= 6 {
	use $estimation/est_dat, clear
	
	keep if hispracesex == `hrs'
	
	rename syear1 year
	
	sort state year quarter
	
	merge m:1 state year quarter using "$mwagedata/qmwage7919.dta"
		drop if _merge == 2 //drop if exists in mwage data but not in cps
		drop _merge
	
	gen rdvwag = log(nwage1) - log(qcpi/104.88925) //1979 dollars [(sum_i^4 79q_i)/4 = 104.88925]
	
	gen rminw = log(mwage) - log(qcpi/104.88925) //1979 dollars [(sum_i^4 79q_i)/4 = 104.88925]
	
	gen wagcat = 0
	replace wagcat = 1 if rdvwag <= foo
}







