** In this dofile we gen prelim linear regs

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

set maxvar 25000

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
log using $linreg/linreg.log, replace

use cleaned_nber_morg, clear

do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1

** use twage : nwage1 equiv
drop if lwage3 ==.

** FIXME currently only using MORG so >=83 - merge to gen may_morg
drop if year < 1983

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

** hours weighted
gen hweight = eweight * uhourse / 100.0

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)

********************************************************************************

rename twage nwage1

gen period = 3 if inrange(year, 2000, 2019)
	replace period = 2 if inrange(year, 1988, 2000)
	replace period = 1 if inrange(year, 1983, 1988)
	
eststo clear
	
forval i = 1(1)3{
	preserve
	
	keep if period == `i'
	
	** keep needed variables
	** FIXME add partt to list once defined in clean_nber_morg
	keep state year quarter nwage1 lwage1 lwage3 hourly exper* educ ee_cl female nind2 nocc cmsa partt public marr hisprace hispracesex eweight alloc1 covered

	drop if hispracesex ==.

	gen finalwt1 = round(eweight)

	gen lyear = year - 1900

	logit covered i.state i.year i.nind2 i.state#i.year i.nind2#i.year [w = finalwt1]
		predict pcoveragerate

	sort state year nind2

	save "$estimation/est_dat.dta", replace

	gen cell = 1

	collapse (rawsum) finalwt1 cell (mean) coveragerate = covered [w = finalwt1], by(state year nind2)

	keep if cell >= 25

	keep state year nind2 coveragerate

	merge 1:m state year nind2 using "$estimation/est_dat.dta"
	
	tab _merge [w = finalwt1]

	replace coveragerate = pcoveragerate if _merge == 2

	drop _merge

	rename nind2 nind

	save "$estimation/est_dat.dta", replace

	recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
			(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)
		
	recode nocc2 (1 2 3 4 5 = 1) (6 7 8 = 2) (9 = 3) (10 11 12 = 4), gen(nocc3)

	egen state_ind = group(state nind)

	gen edex = educ*exper
 
	forvalues j = 0(1)1{
		forvalues k = 1(1)6{
			reg lwage3 coveragerate i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if covered == `j' & hispracesex == `k' [w = finalwt1], vce(cluster state_ind)
		
			eststo re`i'_`j'_`k'
		}
	}
	
	esttab re`i'_0_1 re`i'_0_2 re`i'_0_3 re`i'_0_4 re`i'_0_5 re`i'_0_6 using $tabs/nlincovrate`i'.tex, se title(OLS of Real Log Wages on Unionization Rate for People Not Covered by Union) nonumbers mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("white" "Black" "Hispanic" "white" "Black" "Hispanic") keep(coveragerate) replace
	
	esttab re`i'_1_1 re`i'_1_2 re`i'_1_3 re`i'_1_4 re`i'_1_5 re`i'_1_6 using $tabs/ulincovrate`i'.tex, se title(OLS of Real Log Wages on Unionization Rate for People Covered by Union) nonumbers mgroups("Men" "Women", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("white" "Black" "Hispanic" "white" "Black" "Hispanic") keep(coveragerate) replace
	restore
}

panelcombine, use($tabs/nlincovrate1.tex $tabs/nlincovrate2.tex $tabs/nlincovrate3.tex) paneltitles("1983-1988" "1988-2000" "2000-2019") columncount(3) save($tabs/nlincovrate.tex)

panelcombine, use($tabs/ulincovrate1.tex $tabs/ulincovrate2.tex $tabs/ulincovrate3.tex) paneltitles("1983-1988" "1988-2000" "2000-2019") columncount(3) save($tabs/ulincovrate.tex)

log close
