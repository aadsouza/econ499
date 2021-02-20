** In this do file we take our first shot at dist reg 
** this is equiv to FLL2021 for union threat effects

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
log using $distreg/distreg1.log, replace

local hrs = 1

while `hrs' <= 6{
	local union = 0
	
	while `union' <= 1{
		use "$estimation/stacked_0017_`hrs'", clear
		
		keep if covered == `union'
		
		gen min3b = diff <= -3
		gen min2b = diff <= -2
		gen min1b = diff <= -1
		
		gen min = diff <= 0
		
		gen min1a = diff <= 1
		gen min2a = diff <= 2
		gen min3a = diff <= 3
		gen min4a = diff <= 4
		
		gen lyear  = (year - 2000)/10
		gen lyear2 = lyear^2
		
		gen lwagcat = (wagcat - 28)/10
		
		gen crate1 = coveragerate*lwagcat
		gen crate2 = coveragerate*lwagcat^2
		gen crate3 = coveragerate*lwagcat^3
		gen crate4 = coveragerate*lwagcat^4
		
		gen ee_cl =.
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
		
		probit 	cumwage coveragerate crate1 crate2 crate3 crate4 ///
				min min3b min2b min1b min1a min2a ///
				min3a min4a rdollar rdol5 rdol10 ///
				educ exper exper2 exper3 exper4 edex i.ee_cl ///
				marr i.nind i.nocc3 i.ee_cl#c.lwagcat i.quarter ///
				i.year i.state i.state#c.lyear i.nind#c.lyear ///
				i.state#c.lwagcat i.year#c.lwagcat i.wagcat ///
				if wagcat>=2 & wagcat<=58 [w=fweight], vce(cluster state) iterate(8)
				
		est save "$estimation//un_0017_`hrs'_`union'",replace
		
		local union = `union' + 1
	}
	
	local hrs = `hrs' + 1
}

log close
