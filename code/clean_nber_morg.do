** In this do file we clean nber extracts of cps morg adpating codes generously
** provided to us by Professor Nicole Fortin and Neil Lloyd

** rename variables to be consistent with SAS file conversions
** from Professor Thomas Lemieux

** nber data comes with value labels from 
** http://data.nber.org/morg/sources/labels/

rename hhid houseid
	lab var houseid "house identifier"
	
rename intmonth cmonth
	lab var cmonth "month in sample"

lab var state "1960 census code for state" //Lloyd uses gestfips - dne<1989

lab var sex "sex: male = 1, female = 2"

gen female = sex == 2

replace race = 3 if race > 2 //suppress oth races for comparability
	lab var race "race: white = 1, Black = 2, other = 3"
	
gen hispanic =.
	replace hispanic = 1 if inrange(ethnic, 1, 7) & year <  2003
	replace hispanic = 1 if inrange(ethnic, 1, 5) & year >= 2003
	replace hispanic = 0 if ethnic == 8           & year <  2003
	replace hispanic = 0 if ethnic ==.            & year >= 2003

rename pfamrel famrel //>=1994 ref/spouse, <1994 husband/wife

rename prcitshp citizen //>=1994

gen esrall =.
	replace esrall = 1 if esr == 1 | lfsr89 == 1 | lfsr94 == 1
	replace esrall = 2 if esr == 2 | lfsr89 == 2 | lfsr94 == 2
	replace esrall = 9 if esr >  2 | lfsr89 >  2 | lfsr94 >  2
	lab var esrall "employment stat recode: working in 1 or 2, else 9"
	
rename hourslw hourst
	lab var hourst "actual hours last week at all jobs"

rename class classx

lab var classx "private = 1, fed = 2, state = 3, loc = 4, self = 5, 6, w/o pay = 7" //<=1993
lab var class94 "fed = 1, state = 2, loc = 3, priv = 4, 5, self = 6, 7, w/o pay = 8" // >=1994


********************************************************************************
** FIXME ind codes and occ codes
********************************************************************************

rename eligible elig
	replace elig = 0 if elig == 2
	lab var elig "(non self emp) elig for pay = 1, else = 0"

rename paidhre hourly
	replace hourly = . if hourly <  1
	replace hourly = 0 if hourly == 2
	lab var hourly "hourly worker = 1"

rename unionmme umember //>=1983
	replace umember = 0 if umember==2
	lab var umember "union member = 1, else = 0 (edited)"

rename unioncov ut //>=1983
	gen ucov =.
	replace ucov = 1 if umember == 1
	replace ucov = 1 if umember == 0 & ut == 1
	replace ucov = 0 if ucov    ==.
	lab var ucov "union member or covered = 1, else = 0 (edited)"

rename schenr enroll //>=1984
	replace enroll = 0 if enroll == 2
	lab var enroll "enrolled in school last week (age=16-24)"

rename earnwt ogrwt
	lab var ogrwt "earnings weight"

rename weight finwt
	lab var finwt "final weight"

rename I25c al_wage	//in [1979, 1993], > Aug 1995
	lab var al_wage "allocated hourly wage"
	
rename I25d al_earn //in [1979, 1993], > Aug 1995
	lab var al_earn "allocated weekly earnings"	

** note that earnwke includes hourly workers as earnhre*uhourse
** review cpsx documentation for top-coding
** includes overime, tips, and commissions
gen wage =.
	replace wage = earnwke/uhourse if earnwke > 0 & uhourse > 0
	lab var wage "hourly wage = earnwke/uhourse (>0)"

gen nowage = elig == 1 & wage ==.
	lab var nowage "elig sin wage = 1, else = 0"

** we use gradeat for year < 1992 and Lloyd's method for >=1992
gen educ =.
	replace educ = gradeat if year < 1992
	replace educ = 0.3 if grade92 == 31 & year >= 1992
	replace educ = 3.2 if grade92 == 32 & year >= 1992
	replace educ = 7.2 if grade92 == 33 & year >= 1992
	replace educ = 7.2 if grade92 == 34 & year >= 1992
	replace educ = 9   if grade92 == 35 & year >= 1992
	replace educ = 10  if grade92 == 36 & year >= 1992
	replace educ = 11  if grade92 == 37 & year >= 1992
	replace educ = 12  if grade92 == 38 & year >= 1992
	replace educ = 12  if grade92 == 39 & year >= 1992
	replace educ = 13  if grade92 == 40 & year >= 1992
	replace educ = 14  if grade92 == 41 & year >= 1992
	replace educ = 14  if grade92 == 42 & year >= 1992
	replace educ = 16  if grade92 == 43 & year >= 1992
	replace educ = 18  if grade92 == 44 & year >= 1992
	replace educ = 18  if grade92 == 45 & year >= 1992
    replace educ = 18  if grade92 == 46 & year >= 1992
	lab var educ "completed education"

gen alloc1 = al_wage > 0 | al_earn > 0 | I25a > 0
	lab var alloc1 "allocated hourly wage, weekly earnings, or usual hrs"

gen allocw1 = al_wage > 0
	lab var allocw1 "allocated hourly wage"

** wage > 0 & al_earn > 0 means that we flag hourly wages w weekly earnings flag
gen allocw3 = (earnhre > 0 & al_wage > 0) | (wage > 0 & al_earn > 0)
	lab var allocw3 "allocated wage used in wage var"

** deflate to 1979 dollars using CPIAUCSL
gen cpi =.
    replace cpi = 100.0   if year == 1979
    replace cpi = 113.502 if year == 1980
    replace cpi = 125.281 if year == 1981
    replace cpi = 132.997 if year == 1982
    replace cpi = 137.199 if year == 1983
    replace cpi = 143.192 if year == 1984
    replace cpi = 148.243 if year == 1985
    replace cpi = 151.125 if year == 1986
    replace cpi = 156.533 if year == 1987
    replace cpi = 162.951 if year == 1988
    replace cpi = 170.758 if year == 1989
    replace cpi = 180.011 if year == 1990
    replace cpi = 187.6   if year == 1991
    replace cpi = 193.307 if year == 1992
    replace cpi = 199.047 if year == 1993
    replace cpi = 204.214 if year == 1994
    replace cpi = 209.943 if year == 1995
    replace cpi = 216.108 if year == 1996
    replace cpi = 221.16  if year == 1997
    replace cpi = 224.581 if year == 1998
    replace cpi = 229.506 if year == 1999
    replace cpi = 237.233 if year == 2000
    replace cpi = 243.915 if year == 2001
    replace cpi = 247.807 if year == 2002
    replace cpi = 253.502 if year == 2003
    replace cpi = 260.264 if year == 2004
    replace cpi = 269.024 if year == 2005
    replace cpi = 277.692 if year == 2006
    replace cpi = 285.664 if year == 2007
    replace cpi = 296.562 if year == 2008
    replace cpi = 295.611 if year == 2009
    replace cpi = 300.449 if year == 2010
    replace cpi = 309.882 if year == 2011
    replace cpi = 316.307 if year == 2012
    replace cpi = 320.944 if year == 2013
    replace cpi = 326.129 if year == 2014
    replace cpi = 326.524 if year == 2015
    replace cpi = 330.639 if year == 2016
    replace cpi = 337.71  if year == 2017
    replace cpi = 345.949 if year == 2018
    replace cpi = 352.217 if year == 2019

gen rwage = wage*100/cpi
	lab var rwage "real hourly wage in 1979 dollars"
	
gen twage = wage
	replace twage = . if rwage<1 | rwage>100
	lab var twage "trimmed nom wage 1-100 in 1979 dollars"

gen logw = ln(twage)
	lab var twage "log trimmed nom wage 2-100 in 1979 dollars"

keep if inrange(minsamp, 4, 8) & inrange(age, 16, 65)
	
gen exper = age - educ - 6

tab cmonth year

tab female elig 

tab elig nowage

rename minsamp month
	lab var month "calendar month"

rename umember umem
	lab var umem "union member = 1, else = 0 (edited)"

rename ucov covered
	lab var covered "computed union coverage"

rename ogrwt eweight
	lab var eweight "weight for earnings supp"
  
gen marr =.
	replace marr = 1 if marital <  4
	replace marr = 0 if marital >= 4
	lab var marr "married = 1; widow, div, sep, solo = 0"

********************************************************************************
** FIXME review dfl1996, lemieux2006, fll2021 to ensure consistency in cleaning
********************************************************************************

********************************************************************************
** Notable insconsistencies with Lloyd
** -----------------------------------	
** Lloyd uses peafever, we use peafwhen - vet status
** uhourse coded as . for "hours vary (-4)", Lloyd uses method by Anne Polivka
** since no dualjobs, cannot recover missing "hours vary" uhourse 
** we use gradeat for year < 1992 and Lloyd's method for >=1992
** we deflate cpi to 1979 dollars
** review in-line and by-line comments for more...
** Lloyd: gen allocw3 = (earnhre > 0 & al_wage > 0) | (wage > 0 & al_earn > 0)
**  for us, means that we flag hourly wages w weekly earnings flag too
** Inconsistency w DFL1996: twage 2-100, not 1-100
** do not rename hourly and prernhly as nber diff defined paidhr earnhr exist
********************************************************************************

** FIXME missing from FLL marr^ partt^^ lwage lwage1
** FIXME missing from Lloyd famtype dualjob uftpt hours1 pxernh10 allocw2
** ^marr candidate: marital
** ^^partt candiidate: ftpt79 ftpt89 ftpt94

