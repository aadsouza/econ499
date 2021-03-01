** In this dofile we prepare our dist_dataprep and distreg1 results to find the 
** marginal effects of unionization rates consistent with FLL2021

********************************************************************************
*********************************** PREAMBLE ***********************************
********************************************************************************

global code "/Users/amedeusdsouza/econ499/code"
global tabs "/Users/amedeusdsouza/econ499/tabs"
global figs "/Users/amedeusdsouza/econ499/figures"
global estimation "/Users/amedeusdsouza/Desktop/econ499data/estimation"
global distreg "/Users/amedeusdsouza/econ499/distreg"
global mwagedata "/Users/amedeusdsouza/Desktop/econ499data/zipperer-min-wage"

cap log close 
log using $distreg/marg_crate.log, replace

local periods "0019" //add in 8388 8800 when probit fin

forval hrs = 1(1)6{
	forval p = 1(1)1{
		local per: word `p' of `periods'
		
		di "hrs = `hrs', period = `per'"
		
		use "$estimation/stacked_`per'_`hrs'", clear
		
		keep if covered == 0
		
		gen byte min3b = diff <= -3
		gen byte min2b = diff <= -2
		gen byte min1b = diff <= -1
		
		gen byte min = diff <= 0
		
		gen byte min1a = diff <= 1
		gen byte min2a = diff <= 2
		gen byte min3a = diff <= 3
		gen byte min4a = diff <= 4
		
		gen lyear  = (year - 2000)/10
		gen lyear2 = lyear^2
		
		gen lwagcat = (wagcat - 28)/10
		
		gen byte ee_cl =.
			replace ee_cl = 1  if inrange(educ, 0, 11)  & inrange(exper, 0, 9)
			replace ee_cl = 2  if inrange(educ, 12, 12) & inrange(exper, 0, 9)
			replace ee_cl = 3  if inrange(educ, 13, 15) & inrange(exper, 0, 9)
			replace ee_cl = 4  if inrange(educ, 16, 18) & inrange(exper, 0, 9)
			replace ee_cl = 5  if inrange(educ, 0, 11)  & inrange(exper, 10, 19)
			replace ee_cl = 6  if inrange(educ, 12, 12) & inrange(exper, 10, 19)
			replace ee_cl = 7  if inrange(educ, 13, 15) & inrange(exper, 10, 19)
			replace ee_cl = 8  if inrange(educ, 16, 18) & inrange(exper, 10, 19)
			replace ee_cl = 9  if inrange(educ, 0, 11)  & inrange(exper, 20, 29)
			replace ee_cl = 10 if inrange(educ, 12, 12) & inrange(exper, 20, 29)
			replace ee_cl = 11 if inrange(educ, 13, 15) & inrange(exper, 20, 29)
			replace ee_cl = 12 if inrange(educ, 16, 18) & inrange(exper, 20, 29)
			replace ee_cl = 13 if inrange(educ, 0, 11)  & inrange(exper, 30, .)
			replace ee_cl = 14 if inrange(educ, 12, 12) & inrange(exper, 30, .)
			replace ee_cl = 15 if inrange(educ, 13, 15) & inrange(exper, 30, .)
			replace ee_cl = 16 if inrange(educ, 16, 18) & inrange(exper, 30, .)		
		
		replace exper = exper/10
		gen exper2 = exper^2
		gen exper3 = exper^3
		gen exper4 = exper^4
		
		gen edex = educ*exper
		
		recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
		(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)
		
		recode nocc2 (1 2 3 4 5 = 1) (6 7 8 = 2) (9 = 3) (10 11 12 = 4), gen(nocc3) // FIXME FLL2021 expect to use 4 occ but 13-16 exist?
		
		gen actual_cr = coveragerate
		
		scalar tau = 0.01
		
		est use $estimation/un_`per'_`hrs'_0
		
		replace coveragerate = actual_cr
		gen crate1 = coveragerate*lwagcat
		gen crate2 = coveragerate*lwagcat^2
		gen crate3 = coveragerate*lwagcat^3
		gen crate4 = coveragerate*lwagcat^4
		predict pnu
		
		replace coveragerate = actual_cr +tau
		replace crate1 = coveragerate*lwagcat
		replace crate2 = coveragerate*lwagcat^2
		replace crate3 = coveragerate*lwagcat^3
		replace crate4 = coveragerate*lwagcat^4
		predict pnu_cr1 		
		
		gen p_cumwage = pnu
			replace p_cumwage = cumwage if wagcat==1 | wagcat==58
			
		gen c_cumwage = pnu_cr1
			replace c_cumwage = cumwage if wagcat==1 | wagcat==58
		
		collapse cumwage p_cumwage c_cumwage [w=fweight], by(year quarter wagcat)
		
		sort year quarter wagcat
		
		by year quarter: gen prw = cumwage-cumwage[_n+1]
		by year quarter: gen p_prw = p_cumwage-p_cumwage[_n+1]
		by year quarter: gen c_prw = c_cumwage-c_cumwage[_n+1]
		
		replace prw = cumwage if wagcat == 58
		replace p_prw = p_cumwage if wagcat == 58
		replace c_prw = c_cumwage if wagcat == 58
		
		collapse (mean) prw p_prw c_prw, by(wagcat)
		
		sort wagcat
		gen prw_cum = sum(prw)
		gen p_prw_cum = sum(p_prw)
		gen c_prw_cum = sum(c_prw)
		
		gen slope = (p_prw_cum[_n+4] - p_prw_cum)/.2 in 1/54
		gen wage_effect = (p_prw_cum - c_prw_cum)/slope
		
		rename p_prw_cum percentile
		keep wagcat wage_effect percentile
		
		line wage_effect percentile if inrange(percentile, .05, 0.95)
		
		save "$estimation/marg_crate_data_`per'_`hrs'.dta", replace 
	}
}

log close

use $estimation/marg_crate_data_0019_1.dta, clear
rename percentile nhw_male_percentile
rename wage_effect nhw_male_wage_effect

merge 1:1 wagcat using $estimation/marg_crate_data_0019_2.dta, keepusing(percentile wage_effect) nogen
rename percentile nhB_male_percentile
rename wage_effect nhB_male_wage_effect

merge 1:1 wagcat using $estimation/marg_crate_data_0019_3.dta, keepusing(percentile wage_effect) nogen
rename percentile h_male_percentile
rename wage_effect h_male_wage_effect

merge 1:1 wagcat using $estimation/marg_crate_data_0019_4.dta, keepusing(percentile wage_effect) nogen
rename percentile nhw_female_percentile
rename wage_effect nhw_female_wage_effect

merge 1:1 wagcat using $estimation/marg_crate_data_0019_5.dta, keepusing(percentile wage_effect) nogen
rename percentile nhB_female_percentile
rename wage_effect nhB_female_wage_effect

merge 1:1 wagcat using $estimation/marg_crate_data_0019_6.dta, keepusing(percentile wage_effect) nogen
rename percentile h_female_percentile
rename wage_effect h_female_wage_effect

gen period = 2000

save $estimation/marg_crate_data_0019, replace


** In this dofile we gen fig showing marg effects of 1% increase in coveragerate on log wage in non union distribution

use $estimation/marg_crate_data_0019.dta, clear

replace nhw_male_wage_effect = nhw_male_wage_effect*100
replace nhB_male_wage_effect = nhB_male_wage_effect*100
replace h_male_wage_effect = h_male_wage_effect*100
replace nhw_female_wage_effect = nhw_female_wage_effect*100
replace nhB_female_wage_effect = nhB_female_wage_effect*100
replace h_female_wage_effect = h_female_wage_effect*100

set scheme s1color
set textsize 400

twoway (connected nhw_male_wage_effect nhw_male_percentile if (nhw_male_percentile > 0.02 & nhw_male_percentile < 0.955) & nhw_male_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(midblue)) ///
	, subtitle("A.Threat Effects - White Men", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_nhw_male, replace)
	
twoway (connected nhB_male_wage_effect nhB_male_percentile if (nhB_male_percentile > 0.02 & nhB_male_percentile < 0.955) & nhB_male_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(maroon)) ///
	, subtitle("B.Threat Effects - Black Men", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_nhB_male, replace)

twoway (connected h_male_wage_effect h_male_percentile if (h_male_percentile > 0.02 & h_male_percentile < 0.955) & h_male_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(midgreen)) ///
	, subtitle("C.Threat Effects - Hispanic Men", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_h_male, replace)
	
twoway (connected nhw_female_wage_effect nhw_female_percentile if (nhw_female_percentile > 0.02 & nhw_female_percentile < 0.955) & nhw_female_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(dkorange)) ///
	, subtitle("D.Threat Effects - White Women", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_nhw_female, replace)
	
twoway (connected nhB_female_wage_effect nhB_female_percentile if (nhB_female_percentile > 0.02 & nhB_female_percentile < 0.955) & nhB_female_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(olive)) ///
	, subtitle("E.Threat Effects - Black Women", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_nhB_female, replace)
	
twoway (connected h_female_wage_effect h_female_percentile if (h_female_percentile > 0.02 & h_female_percentile < 0.955) & h_female_wage_effect > -0.5 & period == 2000, msymbol(i) lp(solid) lwidth(medium) lcolor(olive)) ///
	, subtitle("F.Threat Effects - Hispanic Women", size(vlarge)) ///
	xtitle("Percentiles", margin(0 10 0 3) size(large)) ///
	xlabel(0(0.2)1, labsize(medlarge)) ///
	ytitle("Wage Effect (Log Points)", margin(0 3 0 0) size(large)) ///
	ylabel(-0.5(0.2)0.5, labsize(medlarge)) ///
	yline(-0.5(0.2)0.5, lstyle(grid)) yline(0.0, lstyle(foreground)) ///
	legend(order(1 "2000-2019") size(large) r(4) pos(2) ring(0) ///
	region(lcolor(none))) ///
	saving($figs/threat_h_female, replace)
