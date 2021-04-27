** In this dofile we attempt DFL

** gen kde by hispracesex and covered for three periods

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
log using $dfl1/dfl-3per.log, replace

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

drop if year < 1983

********************************************************************************
* 1983 - 1988
********************************************************************************

keep if inrange(year, 1983, 1988)

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

graph twoway (connected wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected bmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected hmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(midgreen) lp(solid)), ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black" 3 "Hispanic") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men", size(vlarge))
graph export "$figs/kde1men/bhw_men_8388.png", replace

graph twoway (connected u_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected u_bmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men Covered by Union", size(vlarge))
graph export "$figs/kde1men/u_bhw_men_8388.png", replace

graph twoway (connected n_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected n_bmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men not Covered by Union", size(vlarge))
graph export "$figs/kde1men/n_bhw_men_8388.png", replace

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

probit nhblack educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year [w = finalwt1]
	predict pb1m

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year if nhblack == 1 [w = finalwt1]
	predict pu1b1m

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year if nhblack == 0 [w = finalwt1]
	predict pu1b0m

gen theta2m = (pb1m/(1-pb1m)) * (pu1b1m/pu1b0m) if nhblack == 0 & covered == 1

replace theta2m = theta2m * hweight if nhblack == 0 & covered == 1

kdensity lwage3 [aweight = theta2m] if hisprace == 1 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(cu_wmestpt cu_wmde) nograph

graph twoway (connected u_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected u_bmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected cu_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(longdash)),  /// 
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black" 3 "white - c.f.") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men Covered by Union - with Counterfactual", size(vlarge))
graph export "$figs/kde1men/fin_cu_bhw_men_8388.png", replace
	
gen theta3m = (pb1m/(1-pb1m)) * ((1-pu1b1m)/(1-pu1b1m)) if nhblack == 0 & covered == 0

replace theta3m = theta3m * hweight if nhblack == 0 & covered == 0

kdensity lwage3 [aweight = theta3m] if hisprace == 1 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(cn_wmestpt cn_wmde) nograph

graph twoway (connected n_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected n_bmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected cn_wmde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(longdash)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black" 3 "white - c.f.") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Men not Covered by Union - with Counterfactual", size(vlarge))
graph export "$figs/kde1men/fin_cn_bhw_men_8388.png", replace
	
restore
********************************************************************************

********************************************************************************
** women
preserve
keep if sex == 2

qui sum lwage3, detail

gen xstep = (r(max) - r(min)) / 200

gen kwage = r(min) + (_n-1)*xstep if _n <= 200

kdensity lwage3 [aweight = hweight] if hisprace == 1, at(kwage) gauss width(0.065) ///
	generate(wfestpt wfde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 2, at(kwage) gauss width(0.065) ///
	generate(bfestpt bfde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 3, at(kwage) gauss width(0.065) ///
	generate(hfestpt hfde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 1 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(u_wfestpt u_wfde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 1 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(n_wfestpt n_wfde) nograph
	
kdensity lwage3 [aweight = hweight] if hisprace == 2 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(u_bfestpt u_bfde) nograph

kdensity lwage3 [aweight = hweight] if hisprace == 2 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(nbfestpt n_bfde) nograph
	
** lab wmestpt "non hisp white men estimation points"
** lab wmde "non hisp white men density estimate"

graph twoway (connected wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected bfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected hfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(midgreen) lp(solid)), ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black" 3 "Hispanic") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women", size(vlarge))
graph export "$figs/kde1wom/bhw_wom_8388.png", replace

graph twoway (connected u_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected u_bfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women Covered by Union", size(vlarge))
graph export "$figs/kde1wom/u_bhw_wom_8388.png", replace

graph twoway (connected n_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected n_bfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "non-Hisp white" 2 "non-Hisp Black") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women not Covered by Union", size(vlarge))
graph export "$figs/kde1wom/n_bhw_wom_8388.png", replace

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

probit nhblack educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year [w = finalwt1]
	predict pb1f

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year if nhblack == 1 [w = finalwt1]
	predict pu1b1f

probit covered educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.state i.nind i.nocc2 i.quarter i.year if nhblack == 0 [w = finalwt1]
	predict pu1b0f

gen theta2f = (pb1f/(1-pb1f)) * (pu1b1f/pu1b0f) if nhblack == 0 & covered == 1

replace theta2f = theta2f * hweight if nhblack == 0 & covered == 1

kdensity lwage3 [aweight = theta2f] if hisprace == 1 & covered == 1, at(kwage) gauss width(0.065) ///
	generate(cu_wfestpt cu_wfde) nograph

graph twoway (connected u_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected u_bfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected cu_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(longdash)),  /// 
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black" 3 "white - c.f.") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women Covered by Union - with Counterfactual", size(vlarge))
graph export "$figs/kde1wom/fin_cu_bhw_wom_8388.png", replace
	
gen theta3f = (pb1f/(1-pb1f)) * ((1-pu1b1f)/(1-pu1b1f)) if nhblack == 0 & covered == 0

replace theta3f = theta3f * hweight if nhblack == 0 & covered == 0

kdensity lwage3 [aweight = theta3f] if hisprace == 1 & covered == 0, at(kwage) gauss width(0.065) ///
	generate(cn_wfestpt cn_wfde) nograph

graph twoway (connected n_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(solid))  /// 
			 (connected n_bfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(magenta) lp(solid))  ///
			 (connected cn_wfde kwage if kwage>=0 & kwage<=5.01, msymbol(i) clwidth(medthick) lc(eltblue) lp(longdash)),  ///
			 xlabel(.69 "ln(2)" 1.61 "ln(5)" 2.3 "ln(10)" 3.22 "ln(25)", labsize(large)) ///
			 ytitle("Density", size(large)) scheme(s1mono) plotregion(lwidth(none)) ///
			 xtitle("") ylabel("0(.25)1.25", labsize(large)) ///
			 legend(order(1 "white" 2 "Black" 3 "white - c.f.") c(1) pos(2) ring(0) symxsize(*.5) size(large) region(lcolor(none))) ///
			 subtitle("Women not Covered by Union - with Counterfactual", size(vlarge))
graph export "$figs/kde1wom/fin_cn_bhw_wom_8388.png", replace
	
restore

log close
