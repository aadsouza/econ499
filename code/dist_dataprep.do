** In this model we prepare the data for the distribution regressions following
** FLL2021

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

use cleaned_nber_morg, clear

** FIXME notice that FLL2021 do not use pareto data for dist reg?
** do "$code/pareto_topcoding.do"

** drop if allocated hourly wage, weekly earnings, or usual hrs and missing wage
drop if alloc1 == 1

** use twage : nwage1 equiv
drop if twage ==.

** FIXME currently only using MORG so >=83 - merge to gen may_morg
drop if year < 1983

** drop obs in 1994 1995 - allocation flag missing
drop if inrange(year, 1994, 1995)

** hours weighted
gen hweight = eweight * uhourse / 100.0

** drop self employed and w/o pay
keep if (classx < 5 & year < 1994) | (class94 < 6 & year >= 1994)

cap log close
log using $distreg/dist_dataprep.log, replace
********************************************************************************

rename twage nwage1

** 0019 uses years 00 - 19
keep if inrange(year, 2000, 2019)

** keep needed variables
** FIXME add partt to list once defined in clean_nber_morg
keep state year quarter nwage1 lwage1 hourly exper educ female nind2 nocc cmsa public marr hisprace hispracesex eweight alloc1 covered

gen finalwt1 = round(eweight)

gen lyear = year - 2000

logit covered i.state i.year i.nind2 i.state#i.year i.nind2#i.year i.nind2#i.year#c.lyear [fw = finalwt1]
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

** FIXME USE NIND FROM CLEANED_NBER_MORG FOR MW ONLY
rename nind2 nind

save "$estimation/est_dat.dta", replace

sum nwage1 lwage1

local hrs = 1 //hispracesex macro

while `hrs' <= 6 {
	use $estimation/est_dat, clear
	
	keep if hispracesex == `hrs'
	
	sort state year quarter
	
	merge m:1 state year quarter using "$mwagedata/qmwage7919.dta"
		drop if _merge == 2 //drop if exists in mwage data but not in cps
		drop _merge
	
	gen rdvwag = log(nwage1) - log(qcpi/104.88925) //1979 dollars [(sum_i^4 79q_i)/4 = 104.88925]
	
	gen rminw = log(mwage) - log(qcpi/104.88925) //1979 dollars [(sum_i^4 79q_i)/4 = 104.88925]
	
	gen wagcat = 0
		replace wagcat = 1 if rdvwag <= 0.383 //log(exp(1.6)*104.8925/354.242)
	
		local i = 1
		while `i' <= 56{
			replace wagcat = 1 + `i' if rdvwag > 0.383 + (`i' - 1)*0.05 & rdvwag <= 0.383 + `i'*0.05
			local i = `i' + 1
		}
		
		replace wagcat = 58 if rdvwag > 3.183

		table wagcat, c(min rdvwag max rdvwag)
		
	gen mincat = 0
		replace mincat = 1 if rminw <= 0.383
		
		local i = 1
		while `i' <= 30{
			replace mincat = 1 + `i' if rminw > 0.383 + (`i' - 1)*0.05 & rminw <= 0.383 + `i'*0.05
			local i = `i' + 1
		}
	
	sum hispracesex mincat
	
	rename finalwt1 fweight
	
	keep wagcat state year quarter mincat qcpi fweight exper educ nind nocc cmsa public marr covered coveragerate
	
	gen pid = _n
	
	compress
	
	fillin pid wagcat
	
	gen wagein = 1 - _fillin
	
	egen state1 = mean(state), by(pid)
		replace state = state1 if missing(state)
		
	egen year1 = mean(year), by(pid)
		replace year = year1 if missing(year)
		
	egen quarter1 = mean(quarter), by(pid)
		replace quarter = quarter1 if missing(quarter)
		
	egen mincat1 = mean(mincat), by(pid)
		replace mincat = mincat1 if missing(mincat)
		
	egen exper1 = mean(exper), by(pid)
		replace exper = exper1 if missing(exper)
		
	egen educ1 = mean(educ), by(pid)
		replace educ = educ1 if missing(educ)
		
	egen nind1 = mean(nind), by(pid)
		replace nind = nind1 if missing(nind)
		
	egen nocc1 = mean(nocc), by(pid)
		replace nocc = nocc1 if missing(nocc)
		
	egen cmsa1 = mean(cmsa), by(pid)
		replace cmsa = cmsa1 if missing(cmsa)
		
	egen public1 = mean(public), by(pid)
		replace public = public1 if missing(public)
	
	egen marr1 = mean(marr), by(pid)
		replace marr = marr1 if missing(marr)
		
	egen qcpi1 = mean(qcpi), by(pid)
		replace qcpi = qcpi1 if missing(qcpi)
	
	egen fweight1 = mean(fweight), by(pid)
		replace fweight = fweight1 if missing(fweight)
		
	egen covered1 = mean(covered), by(pid)
		replace covered = covered1 if missing(covered)
		
	egen coveragerate1 = mean(coveragerate), by(pid)
		replace coveragerate = coveragerate1 if missing(coveragerate)
		
	sort pid wagcat
		by pid: gen cumwage = sum(wagein) // = 1 if at or below wage bin
		replace cumwage = 1 - cumwage // = 1 if above wage bin
		replace cumwage = cumwage + 1 if wagein == 1 // = 1 if at or above wage bin
		
	drop state1 year1 quarter1 mincat1 exper1 educ1 nind1 nocc1 cmsa1 public1 marr1 qcpi1 fweight1 covered1 coveragerate1
		
	gen cut_l = exp(0.383 + (wagcat - 2)*0.05)*qcpi/104.88925	if wagcat >= 2
		replace cut_l = 1 if wagcat == 1
		
	gen rdol5 = cut_l < 5
	
	gen rdol10 = cut_l < 10
	
	gen rdollar = floor(11 - cut_l) if cut_l <= 10
		replace rdollar = 9 if cut_l > 10
		
	gen diff = wagcat - mincat
	
	drop qcpi pid _fillin wagein cut_l
	
	compress
	
	save "$estimation/stacked_0017_`hrs'", replace
	
	local hrs = `hrs' + 1
}

erase "$estimation/est_dat.dta"

log close




