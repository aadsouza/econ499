** In this dofile we gen naive prelim linear regs
** note use panelcombine program from https://github.com/steveofconnell/PanelCombine (\end{table} error in file)

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
log using $linreg/linreg2.log, replace

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

** keep needed variables
** FIXME add partt to list once defined in clean_nber_morg
keep state year quarter nwage1 lwage1 lwage3 hourly exper* educ ee_cl female nind2 nocc cmsa partt public marr hisprace hispracesex eweight alloc1 covered

drop if hispracesex ==.

gen finalwt1 = round(eweight)

rename nind2 nind

recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
		(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)
		
recode nocc2 (1 2 3 4 5 = 1) (6 7 8 = 2) (9 = 3) (10 11 12 = 4), gen(nocc3)

egen state_ind = group(state nind)

gen edex = educ*exper

drop if hisprace > 2

** gen period = 3 if inrange(year, 2000, 2019)
**	replace period = 2 if inrange(year, 1988, 2000)
**	replace period = 1 if inrange(year, 1983, 1988)

** hisprace: Black == 1, white == 0
replace hisprace = hisprace - 1

gen coveredhisprace = covered*hisprace

label variable hisprace "$ Black $"
label variable covered "$ covered $"
label variable coveredhisprace "$ covered \times Black $"

eststo clear

	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 1983, 1988) [w = finalwt1], vce(cluster state_ind)

	eststo naive_mal_1

	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 1983, 1988) [w = finalwt1], vce(cluster state_ind)

	eststo naive_fem_1
	
	esttab naive_mal_1 naive_fem_1 using $tabs/naive1.tex, se title(OLS Regression of Real Log Wages on Union Coverage and Race) nonumbers mtitles("Men" "Women") keep(covered hisprace coveredhisprace) replace label starlevels(* 0.1 ** 0.05 *** 0.01)
	
	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 1988, 2000) [w = finalwt1], vce(cluster state_ind)

	eststo naive_mal_2

	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 1988, 2000) [w = finalwt1], vce(cluster state_ind)

	eststo naive_fem_2
	
	esttab naive_mal_2 naive_fem_2 using $tabs/naive2.tex, se title(OLS Regression of Real Log Wages on Union Coverage and Race) nonumbers mtitles("Men" "Women") keep(covered hisprace coveredhisprace) replace label starlevels(* 0.1 ** 0.05 *** 0.01)
	
	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 2000, 2019) [w = finalwt1], vce(cluster state_ind)

	eststo naive_mal_3

	reg lwage3 hisprace covered coveredhisprace i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 2000, 2019) [w = finalwt1], vce(cluster state_ind)

	eststo naive_fem_3
	
	esttab naive_mal_3 naive_fem_3 using $tabs/naive3.tex, se title(OLS Regression of Real Log Wage on Union Coverage and Race) nonumbers mtitles("Men" "Women") keep(covered hisprace coveredhisprace) replace label starlevels(* 0.1 ** 0.05 *** 0.01) addnote("Standard errors are clustered at the state-industry level. Real log wage is the dependent variable throughout. Having the property of the coefficient in each panel is associated with a $ 100(e^\beta - 1) $ change in wages. Each column and panel corresponds to a regression. All regressions include covariates and fixed effects. ")


panelcombine, use($tabs/naive1.tex $tabs/naive2.tex $tabs/naive3.tex) paneltitles("1983-1988" "1988-2000" "2000-2019") columncount(3) save($tabs/naive.tex) 
log close
