** In this dofile we gen coverage rate time trends by race and sex >= 1983

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

** FIXME currently only using MORG so >=83 - merge to gen may_morg
drop if year < 1983

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)

** NOTE in current draft we have not dropped alloc, missing lwage3, 94-95
********************************************************************************

preserve 
** keep covered race sex year eweight
keep covered hispracesex year eweight

** collapse (mean) covered [aweight = eweight], by(race sex year)
collapse (mean) covered [aweight = eweight], by(hispracesex year)

** twoway	(connected covered year if race == 1 & sex == 1, msymbol(x))  ///
**		(connected covered year if race == 1 & sex == 2, msymbol(x))  ///
**		(connected covered year if race == 2 & sex == 1, msymbol(x))  ///
**		(connected covered year if race == 2 & sex == 2, msymbol(x)), ///
**		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women") cols(4)) ///
**		ytitle("proportion of elig covered by union or members") ///
**		xtitle("year") title("Union Coverage Time Trends by Race and Sex")

** graph export "$figs/1ucov_race_sex_time.png", replace
** restore

twoway	(connected covered year if hispracesex == 1, msymbol(x))  ///
		(connected covered year if hispracesex == 2, msymbol(x))  ///
		(connected covered year if hispracesex == 3, msymbol(x))  ///
		(connected covered year if hispracesex == 4, msymbol(x))  ///
		(connected covered year if hispracesex == 5, msymbol(x))  ///
		(connected covered year if hispracesex == 6, msymbol(x)), ///
		legend(order(1 "non-Hisp white men" 2 "non-Hisp Black men" 3 "Hispanic men" 4 "non-Hisp white women" 5 "non-Hisp Black women" 6 "Hispanic women") cols(3)) ///
		ytitle("proportion of elig covered by union or members") ///
		xtitle("year") title("Union Coverage Time Trends")

graph export "$figs/1ucov_hrs_time.png", replace
restore

** preserve
** keep umem race sex year eweight

** collapse (mean) umem [aweight = eweight], by(race sex year)

** twoway	(connected umem year if race == 1 & sex == 1) ///
**		(connected umem year if race == 1 & sex == 2) ///
**		(connected umem year if race == 2 & sex == 1) ///
**		(connected umem year if race == 2 & sex == 2), ///
**		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women"))
** restore

** preserve
** keep covered public race sex year eweight
** label define publabel 0 "Private Sector" 1 "Public Sector"
** label value public publabel

** collapse (mean) covered [aweight = eweight], by(public race sex year)

** twoway	(connected covered year if race == 1 & sex == 1, msymbol(x))  ///
**		(connected covered year if race == 1 & sex == 2, msymbol(x))  ///
**		(connected covered year if race == 2 & sex == 1, msymbol(x))  ///
**		(connected covered year if race == 2 & sex == 2, msymbol(x)), ///
**		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women") cols(4)) ///
**		by(public, title("Private and Public Sector Union Coverage Time Trends by Race and Sex") note("")) ///
**		ytitle("proportion of elig covered by union or members")
		
** graph export "$figs/2pub_ucov_race_sex_time.png", replace
** restore

preserve
keep covered public hispracesex year eweight
label define publabel 0 "Private Sector" 1 "Public Sector"
label value public publabel

collapse (mean) covered [aweight = eweight], by(public hispracesex year)

twoway	(connected covered year if hispracesex == 1, msymbol(x))  ///
		(connected covered year if hispracesex == 2, msymbol(x))  ///
		(connected covered year if hispracesex == 3, msymbol(x))  ///
		(connected covered year if hispracesex == 4, msymbol(x))  ///
		(connected covered year if hispracesex == 5, msymbol(x))  ///
		(connected covered year if hispracesex == 6, msymbol(x)), ///
		legend(order(1 "non-Hisp white men" 2 "non-Hisp Black men" 3 "Hispanic men" 4 "non-Hisp white women" 5 "non-Hisp Black women" 6 "Hispanic women") cols(3)) ///
		by(public, title("Private and Public Sector Union Coverage Time Trends") note("")) ///
		ytitle("proportion of elig covered by union or members")
		
graph export "$figs/2pub_ucov_hrs_time.png", replace
restore

