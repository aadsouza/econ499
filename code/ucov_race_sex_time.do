** In this dofile we gen coverage rate time trends by race and sex

clear *

cd /Users/amedeusdsouza/Desktop/econ499data/morg/clean_nber_morg_output

use cleaned_nber_morg

** FIXME currently only using MORG so >83 - merge to gen may_morg
drop if year < 1983

keep covered race sex year eweight

collapse (mean) covered [aweight = eweight], by(race sex year)

twoway	(connected covered year if race == 1 & sex == 1, msymbol(x))  ///
		(connected covered year if race == 1 & sex == 2, msymbol(x))  ///
		(connected covered year if race == 2 & sex == 1, msymbol(x))  ///
		(connected covered year if race == 2 & sex == 2, msymbol(x)), ///
		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women"))

		
** keep umem race sex year eweight

** collapse (mean) umem [aweight = eweight], by(race sex year)

** twoway	(connected umem year if race == 1 & sex == 1) ///
**		(connected umem year if race == 1 & sex == 2) ///
**		(connected umem year if race == 2 & sex == 1) ///
**		(connected umem year if race == 2 & sex == 2), ///
**		legend(order(1 "white men" 2 "white women" 3 "Black men" 4 "Black women"))
