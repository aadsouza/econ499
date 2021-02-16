** In this dofile we gen real wage kde by race and sex inrange(year, 1979, 2019)
** we adapt code generously provided to us by Professor Nicole Fortin

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
** men
preserve
keep if sex == 1

qui sum lwage3, detail

gen xstep = (r(max) - r(min)) / 200

gen kwage = r(min) + (_n-1)*xstep if _n <= 200

forval i = 1979(1)2019{
	kdensity lwage3 [aweight = hweight] if year == `i' & race == 1, at(kwage) gauss width(0.065) ///
		generate(wmestpt`i' wmde`i') nograph
}

forval i = 1979(1)2019{
	kdensity lwage3 [aweight = hweight] if year == `i' & race == 2, at(kwage) gauss width(0.065) ///
		generate(bmestpt`i' bmde`i') nograph
}

** lab wmestpt "white men estimation points"
** lab wmde "white men density estimate"

forval i = 1979(1)2019{
graph twoway (connected wmde`i' kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected bmde`i' kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)), ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men", size(vlarge))
graph export "$figs/kde1men/bw_men_`i'.png", replace
}

restore
********************************************************************************

********************************************************************************
** women
preserve
keep if sex == 2

qui sum lwage3, detail

gen xstep = (r(max) - r(min)) / 200

gen kwage = r(min) + (_n-1)*xstep if _n <= 200

forval i = 1979(1)2019{
	kdensity lwage3 [aweight = hweight] if year == `i' & race == 1, at(kwage) gauss width(0.065) ///
		generate(wfestpt`i' wfde`i') nograph
}

forval i = 1979(1)2019{
	kdensity lwage3 [aweight = hweight] if year == `i' & race == 2, at(kwage) gauss width(0.065) ///
		generate(bfestpt`i' bfde`i') nograph
}

** lab wmestpt "white men estimation points"
** lab wmde "white men density estimate"

forval i = 1979(1)2019{
graph twoway (connected wfde`i' kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected bfde`i' kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)), ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women", size(vlarge))
graph export "$figs/kde1wom/bw_wom_`i'.png", replace
}

restore
********************************************************************************

