** In this do file we clean nber extracts of cps morg adapting codes generously
** provided to us by Professor Nicole Fortin and Neil Lloyd

** rename variables to be consistent with SAS file conversions
** from Professor Thomas Lemieux

** nber data comes with value labels from 
** http://data.nber.org/morg/sources/labels/

** NOTE: STATA TREATS MISSING VALUES AS GREATER THAN ANY NON MISSING VALUES!!!!!

rename hhid houseid
	lab var houseid "house identifier"
	
rename intmonth cmonth
	lab var cmonth "month in sample"

lab var state "1960 census code for state" //Lloyd uses gestfips - dne<1989

lab var sex "male = 1, female = 2"

gen female = (sex == 2) if sex <.

replace race = 3 if race > 2 & race <. //suppress oth races for comparability
	lab var race "white = 1, Black = 2, other = 3"
	
gen hispanic =.
	replace hispanic = 1 if inrange(ethnic, 1, 7) & year <  2003
	replace hispanic = 1 if inrange(ethnic, 1, 5) & year >= 2003
	replace hispanic = 0 if ethnic == 8           & year <  2003
	replace hispanic = 0 if ethnic ==.            & year >= 2003

gen hisprace =.
	replace hisprace = 1 if race == 1 & hispanic == 0 //non hispanic white
	replace hisprace = 2 if race == 2 & hispanic == 0 //non hispanic Black
	replace hisprace = 3 if race == 1 & hispanic == 1 //hispanic white
	replace hisprace = 4 if race == 2 & hispanic == 1 //hispanic Black
	replace hisprace = 5 if race == 3 & hispanic == 0 //non hispanic other
	replace hisprace = 6 if race == 3 & hispanic == 1 //hispanic other
	lab var hisprace "nhw=1, nhB=2, hw=3, hB=4, nho=5, ho=6"

rename pfamrel famrel //>=1994 ref/spouse, <1994 husband/wife

rename prcitshp citizen //>=1994

gen esrall =.
	replace esrall = 1 if esr == 1 | lfsr89 == 1 | lfsr94 == 1
	replace esrall = 2 if esr == 2 | lfsr89 == 2 | lfsr94 == 2
	replace esrall = 9 if (esr > 2 & esr <.) | (lfsr89 > 2 & lfsr89 <.) | (lfsr94 > 2 & lfsr94 <.)
	lab var esrall "employment stat recode: working in 1 or 2, else 9"
	
rename hourslw hourst
	lab var hourst "actual hours last week at all jobs"

rename class classx
lab var classx "private = 1, fed = 2, state = 3, loc = 4, self = 5, 6, w/o pay = 7" //<=1993
lab var class94 "fed = 1, state = 2, loc = 3, priv = 4, 5, self = 6, 7, w/o pay = 8" //>=1994


********************************************************************************
** ind codes and occ codes

gen ind3nber =.
	replace ind3nber = ind70 if inrange(year, 1979, 1982) //70 census class
	replace ind3nber = ind80 if inrange(year, 1983, 1991) //80 census class
	replace ind3nber = ind80 if inrange(year, 1992, 2002) //90 census class
	replace ind3nber = ind02 if year >= 2003              //02 census class
	lab var ind3nber "ind3 equiv using nber ind as base - prevailing curr yr"

** see dind_nind_crosswalk
gen nind =.
	replace nind = 	1	 if dind == 	1	 & year < 2003
	replace nind = 	1	 if dind == 	2	 & year < 2003
	replace nind = 	2	 if dind == 	3	 & year < 2003
	replace nind = 	3	 if dind == 	4	 & year < 2003
	replace nind = 	4	 if dind == 	5	 & year < 2003
	replace nind = 	4	 if dind == 	6	 & year < 2003
	replace nind = 	4	 if dind == 	7	 & year < 2003
	replace nind = 	4	 if dind == 	8	 & year < 2003
	replace nind = 	4	 if dind == 	9	 & year < 2003
	replace nind = 	4	 if dind == 	10	 & year < 2003
	replace nind = 	4	 if dind == 	11	 & year < 2003
	replace nind = 	4	 if dind == 	12	 & year < 2003
	replace nind = 	4	 if dind == 	13	 & year < 2003
	replace nind = 	4	 if dind == 	14	 & year < 2003
	replace nind = 	4	 if dind == 	15	 & year < 2003
	replace nind = 	4	 if dind == 	16	 & year < 2003
	replace nind = 	4	 if dind == 	17	 & year < 2003
	replace nind = 	4	 if dind == 	18	 & year < 2003
	replace nind = 	5	 if dind == 	19	 & year < 2003
	replace nind = 	5	 if dind == 	20	 & year < 2003
	replace nind = 	5	 if dind == 	21	 & year < 2003
	replace nind = 	5	 if dind == 	22	 & year < 2003
	replace nind = 	5	 if dind == 	23	 & year < 2003
	replace nind = 	5	 if dind == 	24	 & year < 2003
	replace nind = 	5	 if dind == 	25	 & year < 2003
	replace nind = 	5	 if dind == 	26	 & year < 2003
	replace nind = 	5	 if dind == 	27	 & year < 2003
	replace nind = 	5	 if dind == 	28	 & year < 2003
	replace nind = 	6	 if dind == 	29	 & year < 2003
	replace nind = 	7	 if dind == 	30	 & year < 2003
	replace nind = 	7	 if dind == 	31	 & year < 2003
	replace nind = 	8	 if dind == 	32	 & year < 2003
	replace nind = 	9	 if dind == 	33	 & year < 2003
	replace nind = 	10	 if dind == 	34	 & year < 2003
	replace nind = 	10	 if dind == 	35	 & year < 2003
	replace nind = 	11	 if dind == 	36	 & year < 2003
	replace nind = 	12	 if dind == 	37	 & year < 2003
	replace nind = 	12	 if dind == 	38	 & year < 2003
	replace nind = 	11	 if dind == 	39	 & year < 2003
	replace nind = 	13	 if dind == 	40	 & year < 2003
	replace nind = 	15	 if dind == 	41	 & year < 2003
	replace nind = 	14	 if dind == 	42	 & year < 2003
	replace nind = 	17	 if dind == 	43	 & year < 2003
	replace nind = 	16	 if dind == 	44	 & year < 2003
	replace nind = 	12	 if dind == 	45	 & year < 2003
	replace nind = 	1	 if dind == 	46	 & year < 2003
	replace nind = 	.	 if dind == 	51	 & year < 2003
	replace nind = 	19	 if dind == 	52	 & year < 2003
	replace nind = 	1	 if dind02 == 	1	 & year >= 2003
	replace nind = 	1	 if dind02 == 	2	 & year >= 2003
	replace nind = 	2	 if dind02 == 	3	 & year >= 2003
	replace nind = 	3	 if dind02 == 	4	 & year >= 2003
	replace nind = 	4	 if dind02 == 	5	 & year >= 2003
	replace nind = 	4	 if dind02 == 	6	 & year >= 2003
	replace nind = 	4	 if dind02 == 	7	 & year >= 2003
	replace nind = 	4	 if dind02 == 	8	 & year >= 2003
	replace nind = 	4	 if dind02 == 	9	 & year >= 2003
	replace nind = 	4	 if dind02 == 	10	 & year >= 2003
	replace nind = 	4	 if dind02 == 	11	 & year >= 2003
	replace nind = 	4	 if dind02 == 	12	 & year >= 2003
	replace nind = 	4	 if dind02 == 	13	 & year >= 2003
	replace nind = 	5	 if dind02 == 	14	 & year >= 2003
	replace nind = 	5	 if dind02 == 	15	 & year >= 2003
	replace nind = 	5	 if dind02 == 	16	 & year >= 2003
	replace nind = 	5	 if dind02 == 	17	 & year >= 2003
	replace nind = 	5	 if dind02 == 	18	 & year >= 2003
	replace nind = 	5	 if dind02 == 	19	 & year >= 2003
	replace nind = 	5	 if dind02 == 	20	 & year >= 2003
	replace nind = 	6	 if dind02 == 	23	 & year >= 2003
	replace nind = 	7	 if dind02 == 	24	 & year >= 2003
	replace nind = 	7	 if dind02 == 	25	 & year >= 2003
	replace nind = 	7	 if dind02 == 	26	 & year >= 2003
	replace nind = 	7	 if dind02 == 	27	 & year >= 2003
	replace nind = 	7	 if dind02 == 	28	 & year >= 2003
	replace nind = 	7	 if dind02 == 	29	 & year >= 2003
	replace nind = 	7	 if dind02 == 	30	 & year >= 2003
	replace nind = 	7	 if dind02 == 	31	 & year >= 2003
	replace nind = 	8	 if dind02 == 	21	 & year >= 2003
	replace nind = 	9	 if dind02 == 	22	 & year >= 2003
	replace nind = 	9	 if dind02 == 	45	 & year >= 2003
	replace nind = 	9	 if dind02 == 	46	 & year >= 2003
	replace nind = 	10	 if dind02 == 	32	 & year >= 2003
	replace nind = 	10	 if dind02 == 	33	 & year >= 2003
	replace nind = 	10	 if dind02 == 	34	 & year >= 2003
	replace nind = 	11	 if dind02 == 	48	 & year >= 2003
	replace nind = 	11	 if dind02 == 	50	 & year >= 2003
	replace nind = 	12	 if dind02 == 	35	 & year >= 2003
	replace nind = 	12	 if dind02 == 	36	 & year >= 2003
	replace nind = 	12	 if dind02 == 	37	 & year >= 2003
	replace nind = 	12	 if dind02 == 	38	 & year >= 2003
	replace nind = 	12	 if dind02 == 	39	 & year >= 2003
	replace nind = 	12	 if dind02 == 	47	 & year >= 2003
	replace nind = 	12	 if dind02 == 	49	 & year >= 2003
	replace nind = 	13	 if dind02 == 	44	 & year >= 2003
	replace nind = 	14	 if dind02 == 	42	 & year >= 2003
	replace nind = 	15	 if dind02 == 	41	 & year >= 2003
	replace nind = 	16	 if dind02 == 	43	 & year >= 2003
	replace nind = 	17	 if dind02 == 	40	 & year >= 2003
	replace nind = 	19	 if dind02 == 	51	 & year >= 2003
	replace nind = 	.	 if dind02 == 	52	 & year >= 2003
	replace nind = 	.	 if dind02 == 	6790	 & year >= 2003
	lab var nind "uniform one-digit industry"

gen armedforce = 0


gen occperiod = .
	replace occperiod = 1 if inrange(year, 1971, 1982)
	replace occperiod = 2 if inrange(year, 1983, 1991)
	replace occperiod = 3 if inrange(year, 1992, 2002)
	replace occperiod = 4 if inrange(year, 2003, 2010)
	replace occperiod = 5 if year == 2011 | (year == 2012 & cmonth <= 4)
	replace occperiod = 6 if (year == 2012 & cmonth > 4) | year >= 2013

gen occ_p1 = 0
** upper management  
	replace occ_p1 = 1 if  occ70 == 202 | occ70 == 222 | occ70 == 245 
** lower management  
	replace occ_p1 = 2 if  occ70 == 1 | occ70 == 56 | occ70 == 201 | occ70 == 220   
	replace occ_p1 = 2 if  inrange(occ70, 203, 215) | inrange(occ70, 223, 225)   
	replace occ_p1 = 2 if  inrange(occ70, 231, 240) 
** engineers & computer specialists  
	replace occ_p1 = 3 if inrange(occ70, 2, 23) | inrange(occ70, 34, 36)   
	replace occ_p1 = 3 if inrange(occ70, 152, 163) | occ70 == 55  
** scientists  
	replace occ_p1 = 4 if inrange(occ70, 24, 26) | inrange(occ70, 42, 54) | inrange(occ70, 91, 96)
	replace occ_p1 = 4 if inrange(occ70, 150, 151) | occ70 == 165 
	replace occ_p1 = 4 if inrange(occ70, 171, 173) | inrange(occ70, 195, 196)  
** education, social support  
	replace occ_p1 = 5 if inrange(occ70, 86, 90) | inrange(occ70, 100, 145)
	replace occ_p1 = 5 if inrange(occ70, 32, 33) | inrange(occ70, 174, 194) 
** lawyers & doctors 
	replace occ_p1 = 6 if inrange(occ70, 30, 31) 
	replace occ_p1 = 6 if occ70 == 62 | occ70 == 65 
** health treatment  
	replace occ_p1 = 7 if occ70 == 61 | occ70 == 63 | occ70 == 64 | inrange(occ70, 71, 85)
** clerical occupations 
	replace occ_p1 = 8 if inrange(occ70, 301, 396)
** sales occupations 
	replace occ_p1 = 9 if inrange(occ70, 260, 264) | occ70 == 266 | inrange(occ70, 280, 286)
** insurance & real estate sales 
	replace occ_p1 = 10 if occ70 == 265 | occ70 == 270   
** finance sales 
	replace occ_p1 = 11 if occ70 == 271  
** service occupations 
	replace occ_p1 = 12 if inrange(occ70, 901, 986) | occ70 == 230 | occ70 == 216  
** primary occ 
	replace occ_p1 = 13 if inrange(occ70, 801, 846) | occ70 == 450   
	replace occ_p1 = 13 if occ70 == 752 | occ70 == 740 | occ70 == 761 | occ70 == 755 
** construction & repair 
	replace occ_p1 = 14 if occ70 == 401 | inrange(occ70, 410, 412)
	replace occ_p1 = 14 if inrange(occ70, 415, 421) | inrange(occ70, 424, 425) | occ70 == 502 | occ70 == 516 
	replace occ_p1 = 14 if inrange(occ70, 430, 433) | inrange(occ70, 436, 440)
	replace occ_p1 = 14 if inrange(occ70, 470, 495)
	replace occ_p1 = 14 if inrange(occ70, 510, 512) | inrange(occ70, 520, 523) | occ70 == 534  
	replace occ_p1 = 14 if inrange(occ70, 552, 560) | occ70 == 546  
	replace occ_p1 = 14 if occ70 == 601 | occ70 == 603 | occ70 == 605 | inrange(occ70, 614, 615)   
	replace occ_p1 = 14 if occ70 == 623 | occ70 == 640   
	replace occ_p1 = 14 if inrange(occ70, 750, 751)  
** production 
	replace occ_p1 = 15 if inrange(occ70, 402, 405) | occ70 == 413 | inrange(occ70, 422, 423)
	replace occ_p1 = 15 if inrange(occ70, 434, 435) | inrange(occ70, 441, 446) | occ70 == 426   
	replace occ_p1 = 15 if inrange(occ70, 452, 454) | inrange(occ70, 461, 462) 
	replace occ_p1 = 15 if inrange(occ70, 503, 506) | inrange(occ70, 514, 515) 
	replace occ_p1 = 15 if inrange(occ70, 525, 533) | inrange(occ70, 535, 540)
	replace occ_p1 = 15 if inrange(occ70, 542, 545) | occ70 == 501 | occ70 == 514
	replace occ_p1 = 15 if inrange(occ70, 550, 551) | inrange(occ70, 561, 586)
	replace occ_p1 = 15 if occ70 == 602 | occ70 == 604 | inrange(occ70,610, 613)  
	replace occ_p1 = 15 if inrange(occ70, 620, 622) | inrange(occ70, 624, 636)
	replace occ_p1 = 15 if inrange(occ70, 641, 660) | inrange(occ70, 662, 696)
** other transportation (incl. truck drivers) 
	replace occ_p1 = 16 if inrange(occ70, 163, 164) | occ70 == 170 | occ70 == 221 | occ70 == 226 | occ70 == 661  
	replace occ_p1 = 16 if inrange(occ70, 455, 456) | inrange(occ70, 701, 704)
	replace occ_p1 = 16 if inrange(occ70, 706, 714) | occ70 == 726 | occ70 == 760   
	replace occ_p1 = 16 if inrange(occ70, 753, 754) | inrange(occ70, 762, 796)
	replace occ_p1 = 16 if occ70 == 715 | occ70 == 705 

	replace occ_p1 = 0 if occperiod != 1

	tab occ70 if occ_p1 == 0 & occperiod == 1, m //only missing values left
	replace occ_p1 =. if occ70 ==. & occperiod == 1

gen occ_p2 = 0
** upper management  
	replace occ_p2 = 1 if inrange(occ80, 1, 13) | occ80 == 19 
** lower management  
	replace occ_p2 = 2 if inrange(occ80, 14, 18) | inrange(occ80, 23, 37)
	replace occ_p2 = 2 if inrange(occ80, 473, 476)
** engineers & computer specialists  
	replace occ_p2 = 3 if inrange(occ80, 43, 68) | inrange(occ80, 213, 218) 
	replace occ_p2 = 3 if occ80 == 229  
** scientists  
	replace occ_p2 = 4 if inrange(occ80, 69, 83) | inrange(occ80, 166, 173)
	replace occ_p2 = 4 if inrange(occ80, 223, 225) | occ80 == 235  
** education, social support  
	replace occ_p2 = 5 if inrange(occ80, 113, 165) | inrange(occ80, 174, 177)
	replace occ_p2 = 5 if inrange(occ80, 183, 199) | occ80 == 234 | occ80 == 228
** lawyers & doctors 
	replace occ_p2 = 6 if inrange(occ80, 84, 85) 
	replace occ_p2 = 6 if inrange(occ80, 178, 179)
** health treatment  
	replace occ_p2 = 7 if inrange(occ80, 86, 106) | inrange(occ80, 203, 208)
** clerical occupations 
	replace occ_p2 = 8 if inrange(occ80, 303, 389)
** sales occupations 
	replace occ_p2 = 9 if inrange(occ80, 243, 252) | inrange(occ80, 256, 285)
** insurance & real estate sales 
	replace occ_p2 = 10 if occ80 == 253 | occ80 == 254 
** finance sales 
	replace occ_p2 = 11 if occ80 == 255 
** service occupations 
	replace occ_p2 = 12 if inrange(occ80, 403, 470) 
** primary occ 
	replace occ_p2 = 13 if inrange(occ80, 477, 499)
** construction & repair 
	replace occ_p2 = 14 if inrange(occ80, 503, 617)
	replace occ_p2 = 14 if inrange(occ80, 863, 869)
** production 
	replace occ_p2 = 15 if inrange(occ80, 633, 799)
	replace occ_p2 = 15 if occ80 == 873 | occ80 == 233  
** other transportation (incl. truck drivers) 
	replace occ_p2 = 16 if inrange(occ80, 803, 859)
	replace occ_p2 = 16 if inrange(occ80, 875, 889)
	replace occ_p2 = 16 if inrange(occ80, 226, 227)  

	replace occ_p2 = 0 if occperiod != 2

	replace armedforce = 1 if occ80 == 905 & occperiod == 2

	tab occ80 if occ_p2 == 0 & armedforce == 0 & occperiod == 2, m //only missing values left
	replace occ_p2 =. if occ80 ==. & occperiod == 2
	
gen occ_p3 = 0
** upper management  
	replace occ_p3 = 1 if inrange(occ80, 1, 13) | occ80 == 22 
** lower management  
	replace occ_p3 = 2 if inrange(occ80, 14, 21) | inrange(occ80, 23, 37)
	replace occ_p3 = 2 if inrange(occ80, 473, 476)
** engineers & computer specialists  
	replace occ_p3 = 3 if inrange(occ80, 43, 68) | inrange(occ80, 213, 218)  
	replace occ_p3 = 3 if occ80 == 229  
** scientists  
	replace occ_p3 = 4 if inrange(occ80, 69, 83) | inrange(occ80, 166, 173)
	replace occ_p3 = 4 if inrange(occ80, 223, 225) | occ80 == 235  
** education, social support  
	replace occ_p3 = 5 if inrange(occ80, 113, 165) | inrange(occ80, 174, 177)
	replace occ_p3 = 5 if inrange(occ80, 183, 199) | occ80 == 234 | occ80 == 228 
** lawyers & doctors 
	replace occ_p3 = 6 if inrange(occ80, 84, 85)
	replace occ_p3 = 6 if inrange(occ80, 178, 179)
** health treatment  
	replace occ_p3 = 7 if inrange(occ80, 86, 106) | inrange(occ80, 203, 208)  
** clerical occupations 
	replace occ_p3 = 8 if inrange(occ80, 303, 389)
** sales occupations 
	replace occ_p3 = 9 if inrange(occ80, 243, 252) | inrange(occ80, 256, 285)
** insurance & real estate sales 
	replace occ_p3 = 10 if occ80 == 253 | occ80 == 254 
** finance sales 
	replace occ_p3 = 11 if occ80 == 255 
** service occupations 
	replace occ_p3 = 12 if inrange(occ80, 403, 470)
** primary occ 
	replace occ_p3 = 13 if inrange(occ80, 477, 499)
** construction & repair 
	replace occ_p3 = 14 if inrange(occ80, 503, 617)
	replace occ_p3 = 14 if inrange(occ80, 864, 869)
** production 
	replace occ_p3 = 15 if inrange(occ80, 628, 799)
	replace occ_p3 = 15 if occ80 == 874 | occ80 == 233  
** other transportation (incl. truck drivers) 
	replace occ_p3 = 16 if inrange(occ80, 803, 859)
	replace occ_p3 = 16 if inrange(occ80, 875, 889)
	replace occ_p3 = 16 if inrange(occ80, 226, 227)
	
	replace occ_p3 = 0 if occperiod != 3
	
	replace armedforce = 1 if occ80 == 905 & occperiod == 3

	tab occ80 if occ_p3 == 0 & armedforce == 0 & occperiod == 3, m //only missing values left
	replace occ_p3 =. if occ80 ==. & occperiod == 3
	
gen occ_p4 = 0
** upper management  
	replace occ_p4 = 1 if inrange(occ00, 10, 200) | occ00 == 430
** lower management  
	replace occ_p4 = 2 if inrange(occ00, 200, 1000) & occ00 != 430   
** engineers & computer specialists  
	replace occ_p4 = 3 if inrange(occ00, 1000, 1560)
** scientists  
	replace occ_p4 = 4 if inrange(occ00, 1600, 2000)
** education, social support  
	replace occ_p4 = 5 if inrange(occ00, 2000, 2100) | inrange(occ00, 2140, 3000)
** lawyers & doctors 
	replace occ_p4 = 6 if inrange(occ00, 2100, 2110)
	replace occ_p4 = 6 if occ00 == 3010 | occ00 == 3060 
** health treatment  
	replace occ_p4 = 7 if occ00 == 3000 | inrange(occ00, 3030, 3050) | inrange(occ00, 3110, 3540)
** clerical occupations 
	replace occ_p4 = 8 if inrange(occ00, 5000, 5930)
** sales occupations 
	replace occ_p4 = 9 if inrange(occ00, 4700, 4960)
** insurance & real estate sales 
	replace occ_p4 = 10 if occ00 == 4810 | occ00 == 4920 //overwrites values above 
** finance sales 
	replace occ_p4 = 11 if occ00 == 4820 //overwrites values above 
** service occupations 
	replace occ_p4 = 12 if inrange(occ00, 3600, 4700)
** primary occ 
	replace occ_p4 = 13 if inrange(occ00, 6000, 6130)
** construction & repair 
	replace occ_p4 = 14 if inrange(occ00, 6200, 7620)
** production 
	replace occ_p4 = 15 if inrange(occ00, 7700, 8960)
** other transportation (incl. truck drivers) 
	replace occ_p4 = 16 if inrange(occ00, 9000, 9750)

	replace occ_p4 = 0 if occperiod != 4	

	replace armedforce = 1 if occ00 == 9840 & occperiod == 4

	tab occ00 if occ_p4 == 0 & armedforce == 0 & occperiod == 4, m //only missing values left
	replace occ_p4 =. if occ00 ==. & occperiod == 4

gen occ_p5 = 0	
** upper management  
	replace occ_p5 = 1 if inrange(occ2011, 10, 200) | occ2011 == 430
** lower management  
	replace occ_p5 = 2 if inrange(occ2011, 200, 1000) & occ2011 != 430   
** engineers & computer specialists  
	replace occ_p5 = 3 if inrange(occ2011, 1000, 1560)
** scientists  
	replace occ_p5 = 4 if inrange(occ2011, 1600, 2000)
** education, social support  
	replace occ_p5 = 5 if inrange(occ2011, 2000, 2100) | inrange(occ2011, 2140, 3000)
** lawyers & doctors 
	replace occ_p5 = 6 if inrange(occ2011, 2100, 2110)
	replace occ_p5 = 6 if occ2011 == 3010 | occ2011 == 3060
** health treatment  
	replace occ_p5 = 7 if occ2011 == 3000 | inrange(occ2011, 3030, 3050) | inrange(occ2011, 3110, 3540)	
** clerical occupations 
	replace occ_p5 = 8 if inrange(occ2011, 5000, 5940)	
** sales occupations 
	replace occ_p5 = 9 if inrange(occ2011, 4700, 4965)	
** insurance & real estate sales 
	replace occ_p5 = 10 if occ2011 == 4810 | occ2011 == 4920 //overwrites values above 
** finance sales 
	replace occ_p5 = 11 if occ2011 == 4820 //overwrites values above 	
** service occupations 
	replace occ_p5 = 12 if inrange(occ2011, 3600, 4700)
** primary occ 
	replace occ_p5 = 13 if inrange(occ2011, 6000, 6130)
** construction & repair 
	replace occ_p5 = 14 if inrange(occ2011, 6200, 7630)	
** production 
	replace occ_p5 = 15 if inrange(occ2011, 7700, 8965)
** other transportation (incl. truck drivers) 
	replace occ_p5 = 16 if inrange(occ2011, 9000, 9750)
	
	replace occ_p5 = 0 if occperiod != 5	

	replace armedforce = 1 if occ2011 == 9840 & occperiod == 5

	tab occ2011 if occ_p5 == 0 & armedforce == 0 & occperiod == 5, m //only missing values left
	replace occ_p5 =. if occ2011 ==. & occperiod == 5

gen occ_p6 = 0	
** upper management  
	replace occ_p6 = 1 if inrange(occ2012, 10, 200) | occ2012 == 430
** lower management  
	replace occ_p6 = 2 if inrange(occ2012, 200, 1000) & occ2012 != 430   
** engineers & computer specialists  
	replace occ_p6 = 3 if inrange(occ2012, 1000, 1560)
** scientists  
	replace occ_p6 = 4 if inrange(occ2012, 1600, 2000)
** education, social support  
	replace occ_p6 = 5 if inrange(occ2012, 2000, 2100) | inrange(occ2012, 2140, 3000)
** lawyers & doctors 
	replace occ_p6 = 6 if inrange(occ2012, 2100, 2110)
	replace occ_p6 = 6 if occ2012 == 3010 | occ2012 == 3060
** health treatment  
	replace occ_p6 = 7 if occ2012 == 3000 | inrange(occ2012, 3030, 3050) | inrange(occ2012, 3110, 3540)	
** clerical occupations 
	replace occ_p6 = 8 if inrange(occ2012, 5000, 5940)	
** sales occupations 
	replace occ_p6 = 9 if inrange(occ2012, 4700, 4965)	
** insurance & real estate sales 
	replace occ_p6 = 10 if occ2012 == 4810 | occ2012 == 4920 //overwrites values above 
** finance sales 
	replace occ_p6 = 11 if occ2012 == 4820 //overwrites values above 	
** service occupations 
	replace occ_p6 = 12 if inrange(occ2012, 3600, 4700)
** primary occ 
	replace occ_p6 = 13 if inrange(occ2012, 6000, 6130)
** construction & repair 
	replace occ_p6 = 14 if inrange(occ2012, 6200, 7630)	
** production 
	replace occ_p6 = 15 if inrange(occ2012, 7700, 8965)
** other transportation (incl. truck drivers) 
	replace occ_p6 = 16 if inrange(occ2012, 9000, 9750)
	
	replace occ_p6 = 0 if occperiod != 6	

	replace armedforce = 1 if occ2012 == 9840 & occperiod == 6

	tab occ2012 if occ_p6 == 0 & armedforce == 0 & occperiod == 6, m //only missing values left
	replace occ_p6 =. if occ2012 ==. & occperiod == 6

gen nocc = occ_p1 + occ_p2 + occ_p3 + occ_p4 + occ_p5 + occ_p6 //missing values will remain missing

tab nocc armedforce //all the 0's are armed forces?

drop if armedforce == 1

** nind2 - 11 industry categories
recode nind (1 2 = 1) (3 = 2) (4 5 = 3) (8 9 = 4) (6 7 = 5) (10 = 6) (12 = 7) ///
(14 15 16 = 8) (17 = 9) (11 13 = 10) (19 = 11), gen(nind2) 

tab nind2, gen(indus)

recode nocc (1 6 = 1) (2 = 2) (3 4 = 3) (5 = 4) (7 = 5) (8 = 6) (9 = 7) (10 11 = 8) ///
(12 = 9) (13 15 = 10) (14 = 11) (16 = 12), gen(nocc2)

tab nocc2, gen(occup)
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

** rename unioncov ut //>=1983
** 	gen ucov =.
** 	replace ucov = 1 if umember == 1
** 	replace ucov = 1 if umember == 0 & ut == 1
** 	replace ucov = 0 if ucov    ==.
** 	lab var ucov "union member or covered = 1, else = 0 (edited)"

rename unioncov ut //>=1983
	gen ucov =.
	replace ucov = 1 if umember == 1
	replace ucov = 1 if umember == 0 & ut == 1
	replace ucov = 0 if ut      == 2
	lab var ucov "union member or covered = 1, not cov = 0 (edited)"

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
	replace wage = earnwke/uhourse if (earnwke > 0 & earnwke <.) & (uhourse > 0 & uhourse <.)
	lab var wage "hourly wage = earnwke/uhourse (>0)"

gen nowage = (elig == 1 & wage ==.)
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

gen alloc1 = (al_wage > 0 & al_wage <.) | (al_earn > 0 & al_earn <.) | (I25a > 0 & I25a <.)
	lab var alloc1 "allocated hourly wage, weekly earnings, or usual hrs"

gen allocw1 = (al_wage > 0 & al_wage <.)
	lab var allocw1 "allocated hourly wage"

** wage > 0 & al_earn > 0 means that we flag hourly wages w weekly earnings flag
gen allocw3 = (earnhre > 0 & al_wage > 0 & earnhre <. & al_wage <.) | (wage > 0 & al_earn > 0 & wage <. & al_earn <.)
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
	lab var logw "log trimmed nom wage 1-100 in 1979 dollars"

keep if inrange(minsamp, 4, 8) & inrange(age, 16, 64)
	
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
	replace marr = 0 if marital >= 4 & marital <.
	lab var marr "married = 1; widow, div, sep, solo = 0"
	
rename logw lwage 

gen rtwage = twage*100/cpi

gen lwage1 = ln(rtwage)
	lab var lwage1 "log trimmed real wage 1-100 in 1979 dollars"
	
gen topcode =.
	replace topcode = 1 if earnwke == 999  & inrange(year, 1979, 1988)
	replace topcode = 1 if earnwke == 1923 & inrange(year, 1989, 1993)
	replace topcode = 1 if earnwke == 1923 & inrange(year, 1994, 1998)
	replace topcode = 1 if earnwke == 2884 & inrange(year, 1998, 2019)
	replace topcode = 0 if topcode ==. 	   & elig == 1

gen public =.
	replace public = 1 if inrange(classx, 2, 4) & year <  1994
	replace public = 1 if inrange(class94, 1, 3) & year >= 1994
	replace public = 0 if classx !=. & public ==. & year < 1994
	replace public = 0 if class94 !=. & public ==. & year >= 1994

gen exper2 = exper^2

gen exper3 = exper^3

gen exper4 = exper^4

gen edex = educ*exper

gen ee_cl=.
	replace ee_cl=1 if inrange(educ,0,11) & inrange(exper,0,9)
	replace ee_cl=2 if inrange(educ,12,12) & inrange(exper,0,9)
	replace ee_cl=3 if inrange(educ,13,15) & inrange(exper,0,9)
	replace ee_cl=4 if inrange(educ,16,18) & inrange(exper,0,9)
	replace ee_cl=5 if inrange(educ,0,11) & inrange(exper,10,19)
	replace ee_cl=6 if inrange(educ,12,12) & inrange(exper,10,19)
	replace ee_cl=7 if inrange(educ,13,15) & inrange(exper,10,19)
	replace ee_cl=8 if inrange(educ,16,18) & inrange(exper,10,19)
	replace ee_cl=9 if inrange(educ,0,11) & inrange(exper,20,29)
	replace ee_cl=10 if inrange(educ,12,12) & inrange(exper,20,29)
	replace ee_cl=11 if inrange(educ,13,15) & inrange(exper,20,29)
	replace ee_cl=12 if inrange(educ,16,18) & inrange(exper,20,29)
	replace ee_cl=13 if inrange(educ,0,11) & inrange(exper,30,.)
	replace ee_cl=14 if inrange(educ,12,12) & inrange(exper,30,.)
	replace ee_cl=15 if inrange(educ,13,15) & inrange(exper,30,.)
	replace ee_cl=16 if inrange(educ,16,18) & inrange(exper,30,.)
	tab ee_cl, gen(ee)

gen cmsa = inlist(centcity,1,2) if centcity !=.

recode state (11/23 = 1) (31/47 = 2) (51/74 = 3) (81/95 = 4), gen(region)
	tab region, gen(reg)
	
gen quarter =.
	replace quarter = 1 if inrange(cmonth, 1, 3)
	replace quarter = 2 if inrange(cmonth, 4, 6)
	replace quarter = 3 if inrange(cmonth, 7, 9)
	replace quarter = 4 if inrange(cmonth, 10, 12)

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
** do not rename hourly and prernhly as nber diff defined paidhr earnhr exist
********************************************************************************

** FIXME missing from FLL partt^
** FIXME missing from Lloyd famtype dualjob uftpt hours1 pxernh10 allocw2
** ^partt candidate: ftpt79 ftpt89 ftpt94

** note contrary to cpsx doc, classer1 dne
