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

drop if year < 1983

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)
********************************************************************************

cd $figs

keep lwage3 hispracesex year eweight

gen wmcentile = 50

gen wfcentile = 50

// collapse (p50) lwage3 [aweight = eweight], by(hispracesex year)

// twoway	(connected lwage3 year if hispracesex == 1, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 2, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 3, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 4, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 5, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 6, msymbol(x)), ///
// 		legend(order(1 "white men" 2 "Black men" 3 "Hispanic men" 4 "white women" 5 "Black women" 6 "Hispanic women") cols(3)) ///
// 		ytitle("real log trimmed imputed wages") ///
// 		xtitle("year") title("Median Real Log Wages Time Trends")
		
// twoway	(connected lwage3 year if hispracesex == 1, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 2, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 3, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 4, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 5, msymbol(x))  ///
// 		(connected lwage3 year if hispracesex == 6, msymbol(x)),  ///
// 		legend(order(1 "white men" 2 "Black men" 3 "Hispanic men" 4 "white women" 5 "Black women" 6 "Hispanic women") cols(3)) ///
// 		ytitle("real log wages") ///
// 		xtitle("year") title("Median Real Log Wages Time Trends")

// graph export "$figs/fin_med_wage_time.png", replace

gen bwmcentile =.

foreach t of numlist 1983/1993 1996/2019{
	di `t'
	
	pctile wmcentile`t' = lwage3 if hispracesex == 1 & year == `t' [aw = eweight], nq(100)
	
	pctile bmcentile`t' = lwage3 if hispracesex == 2 & year == `t' [aw = eweight], nq(100)
	
	gen diff`t' =.
		replace diff`t' = abs(bmcentile`t'[50] - wmcentile`t')
		
	gen foo = _n
	
	qui sum diff`t'
	
	gen bwmcentile`t' = foo if diff`t' == r(min)
		qui sum bwmcentile`t'
		replace bwmcentile`t' = r(mean) if bwmcentile`t' ==.
	
	replace bwmcentile = bwmcentile`t' if year == `t'
	
	drop wmcentile`t' bmcentile`t' diff`t' foo bwmcentile`t'
}

gen bwfcentile =.

foreach t of numlist 1983/1993 1996/2019{
	di `t'
	
	pctile wfcentile`t' = lwage3 if hispracesex == 4 & year == `t' [aw = eweight], nq(100)
	
	pctile bfcentile`t' = lwage3 if hispracesex == 5 & year == `t' [aw = eweight], nq(100)
	
	gen diff`t' =.
		replace diff`t' = abs(bfcentile`t'[50] - wfcentile`t')
		
	gen foo = _n
	
	qui sum diff`t'
	
	gen bwfcentile`t' = foo if diff`t' == r(min)
		qui sum bwfcentile`t'
		replace bwfcentile`t' = r(mean) if bwfcentile`t' ==.
	
	replace bwfcentile = bwfcentile`t' if year == `t'
	
	drop wfcentile`t' bfcentile`t' diff`t' foo bwfcentile`t'
}

collapse w* b*, by(year)

twoway (connected wmcentile year, msymbol(x)) ///
	   (connected bwmcentile year, msymbol(x)), ///
	   legend(order(1 "white" 2 "Black") cols(2)) ///
	   ytitle("centile of wage distribution of white men") ///
	   xtitle("year") title("Position of Median Man on Wage Distribution of White Men")
	   
graph export "$figs/fin_med_centile_time_men.png", replace
	   
twoway (connected wfcentile year, msymbol(x)) ///
	   (connected bwfcentile year, msymbol(x)), ///
	   legend(order(1 "white" 2 "Black") cols(2)) ///
	   ytitle("centile of wage distribution of white women") ///
	   xtitle("year") title("Position of Median Woman on Wage Distribution of White Women")
	   
graph export "$figs/fin_med_centile_time_women.png", replace
 
