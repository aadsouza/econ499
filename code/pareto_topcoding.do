** In this do file we gen the top-code adjusted wage distribution using pareto 
** parameters adapting codes generously provided to us by
** Professor Nicole Fortin and Neil Lloyd

** Generate topcode-adjusted wage distribution using Pareto parameter
** Output: lwage2

** OG Source: https://eml.berkeley.edu/~saez/TabFig2015prel.xls
	* Table A4 & Table B3

** RE Source: https://eml.berkeley.edu/~saez/TabFig2018.xls
	* Table A4 & Table B3

** Use Pareto parameter from Piketty and Saez (top 1%): average of 5 year windows (e.g. 2000-2004);
** OG: Due to a lack of availability for post 2011 data, the average of 2010 & 2011 is extended to 2017.

set seed 486372893

gen ranuni = runiform() if topcode == 1

gen     pareto = 1/(ranuni^(1/2.68)) if inrange(year, 1975, 1979)
replace pareto = 1/(ranuni^(1/2.45)) if inrange(year, 1980, 1984) 
replace pareto = 1/(ranuni^(1/2.15)) if inrange(year, 1985, 1989) 
replace pareto = 1/(ranuni^(1/2.02)) if inrange(year, 1990, 1994) 
replace pareto = 1/(ranuni^(1/1.89)) if inrange(year, 1995, 1999) 
replace pareto = 1/(ranuni^(1/1.81)) if inrange(year, 2000, 2004) 
replace pareto = 1/(ranuni^(1/1.78)) if inrange(year, 2005, 2009)

** FIXME revise parameters using Tables A4 and B3
replace pareto = 1/(ranuni^(1/1.86)) if inrange(year, 2010, 2017) 

* lwage2 uses this imputation;
gen lwage2 = lwage if topcode == 0
replace lwage2 = lwage + log(pareto) if topcode == 1
