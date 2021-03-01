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

keep lwage3 hispracesex year eweight

collapse (p50) lwage3 [aweight = eweight], by(hispracesex year)

twoway	(connected lwage3 year if hispracesex == 1, msymbol(x))  ///
		(connected lwage3 year if hispracesex == 2, msymbol(x))  ///
		(connected lwage3 year if hispracesex == 3, msymbol(x))  ///
		(connected lwage3 year if hispracesex == 4, msymbol(x))  ///
		(connected lwage3 year if hispracesex == 5, msymbol(x))  ///
		(connected lwage3 year if hispracesex == 6, msymbol(x)), ///
		legend(order(1 "non-Hisp white men" 2 "non-Hisp Black men" 3 "Hispanic men" 4 "non-Hisp white women" 5 "non-Hisp Black women" 6 "Hispanic women") cols(3)) ///
		ytitle("real log trimmed imputed wages") ///
		xtitle("year") title("Median Real Log Trimmed Imputed Wages Time Trends")

graph export "$figs/5med_wage_time.png", replace


