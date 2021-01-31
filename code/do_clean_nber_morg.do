clear *

global datain  "/Users/amedeusdsouza/Desktop/econ499data/morg/annual"

global dofile  "/Users/amedeusdsouza/econ499/code"

global dataout "/Users/amedeusdsouza/Desktop/econ499data/morg/clean_nber_morg_output"

forvalues i = 79(1)99{
	append using "$datain/morg`i'.dta"
	}
	
forvalues i = 0(1)9{
	append using "$datain/morg0`i'.dta"
	}

forvalues i = 10(1)19{
	append using "$datain/morg`i'.dta"
	}

do "$dofile/clean_nber_morg.do"

save "$dataout/cleaned_nber_morg.dta", replace
