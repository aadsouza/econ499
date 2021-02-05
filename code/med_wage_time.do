** In this dofile we gen median lwage3 time trends by race and sex

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

cd $figs

keep lwage3 race sex year eweight

collapse (p50) lwage3 [aweight = eweight], by(race sex year)

twoway	(connected lwage3 year if race == 1 & sex == 1, msymbol(x))  ///
		(connected lwage3 year if race == 1 & sex == 2, msymbol(x))  ///
		(connected lwage3 year if race == 2 & sex == 1, msymbol(x))  ///
		(connected lwage3 year if race == 2 & sex == 2, msymbol(x)), ///
		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women") cols(4)) ///
		ytitle("real log trimmed imputed wages") ///
		xtitle("year") title("Median Real Log Trimmed Imputed Wages Time Trends")

graph export "$figs/5med_wage_time.png", replace


