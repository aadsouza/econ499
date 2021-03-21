** In this dofile we gen RIF regs corresponding to the naive OLS regs

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
log using $linreg/rifreg2.log, replace

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

gen blackrelwhite = hisprace - 1
	replace blackrelwhite =. if hisprace > 2

gen coveredblackrelwhite = covered*blackrelwhite
** eststo clear

	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 1983, 1988) [w = finalwt1], vce(cluster state_ind)

	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 1983, 1988) [w = finalwt1], vce(cluster state_ind)
	
	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 1988, 2000) [w = finalwt1], vce(cluster state_ind)

	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 1988, 2000) [w = finalwt1], vce(cluster state_ind)

	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 0 & inrange(year, 2000, 2019) [w = finalwt1], vce(cluster state_ind)

	reg lwage3 covered blackrelwhite coveredblackrelwhite i.state i.year i.nind educ exper exper2 exper3 exper4 edex i.ee_cl marr partt public cmsa i.nocc2 i.quarter if female == 1 & inrange(year, 2000, 2019) [w = finalwt1], vce(cluster state_ind)

	
preserve

keep if inrange(year, 1983, 1988)

** RIF-DiD with nocc2
qui tab state,	 gen(dumstate)
qui tab year,	 gen(dumyear)
qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

	** note collinearity from dummy variable trap ?
	** with quarter fe 
    putexcel set $linreg/rifreg2_coefs_1, replace sheet("data")
	putexcel A1 = "name"
	putexcel B1 = "coef"
	putexcel C1 = "bse"
	putexcel D1 = "lb"
	putexcel E1 = "ub"
	
    local row = 2
	
	
	forval qt = 10(10)90{
		di "men at `qt' quantile in period 1"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "m_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "m_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "m_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
		
		di "women at `qt' quantile in period 1"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "f_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "f_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "f_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
	}

restore

preserve

keep if inrange(year, 1988, 2000)

** RIF-DiD with nocc2
qui tab state,	 gen(dumstate)
qui tab year,	 gen(dumyear)
qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

	** note collinearity from dummy variable trap ?
	** with quarter fe 
    putexcel set $linreg/rifreg2_coefs_2, replace sheet("data")
	putexcel A1 = "name"
	putexcel B1 = "coef"
	putexcel C1 = "bse"
	putexcel D1 = "lb"
	putexcel E1 = "ub"
	
    local row = 2
	
	
	forval qt = 10(10)90{
		di "men at `qt' quantile in period 2"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "m_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "m_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "m_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
		
		di "women at `qt' quantile in period 2"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "f_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "f_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "f_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
	}

restore

preserve

keep if inrange(year, 2000, 2019)

** RIF-DiD with nocc2
qui tab state,	 gen(dumstate)
qui tab year,	 gen(dumyear)
qui tab nind, 	 gen(dumnind)
qui tab ee_cl, 	 gen(dumee_cl)
qui tab nocc2, 	 gen(dumnocc2)
qui tab quarter, gen(dumquarter)

	** note collinearity from dummy variable trap ?
	** with quarter fe 
    putexcel set $linreg/rifreg2_coefs_3, replace sheet("data")
	putexcel A1 = "name"
	putexcel B1 = "coef"
	putexcel C1 = "bse"
	putexcel D1 = "lb"
	putexcel E1 = "ub"
	
    local row = 2
	
	
	forval qt = 10(10)90{
		di "men at `qt' quantile in period 3"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 0 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "m_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "m_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "m_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
		
		di "women at `qt' quantile in period 3"
		rifreg lwage3 covered blackrelwhite coveredblackrelwhite dumstate* dumyear* dumnind* educ exper exper2 exper3 exper4 edex dumee_cl* marr partt public cmsa dumnocc2* dumquarter* if female == 1 [w = finalwt1], q(`qt') //bootstrap reps(200)
		putexcel A`row' = "f_blackrelwhite`qt'"
		putexcel B`row' = _b[blackrelwhite]
		putexcel C`row' = _se[blackrelwhite]
		putexcel D`row' = (_b[blackrelwhite] - invttail(e(df_r), 0.025) * _se[blackrelwhite])
		putexcel E`row' = (_b[blackrelwhite] + invttail(e(df_r), 0.025) * _se[blackrelwhite])
		
		local row = `row' + 1
		
		putexcel A`row' = "f_covered`qt'"
		putexcel B`row' = _b[covered]
		putexcel C`row' = _se[covered]
		putexcel D`row' = (_b[covered] - invttail(e(df_r), 0.025) * _se[covered])
		putexcel E`row' = (_b[covered] + invttail(e(df_r), 0.025) * _se[covered])
		
		local row = `row' + 1

		putexcel A`row' = "f_times`qt'"
		putexcel B`row' = _b[coveredblackrelwhite]
		putexcel C`row' = _se[coveredblackrelwhite]
		putexcel D`row' = (_b[coveredblackrelwhite] - invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
		putexcel E`row' = (_b[coveredblackrelwhite] + invttail(e(df_r), 0.025) * _se[coveredblackrelwhite])
	
		local row = `row' + 1
	}

restore

log close
