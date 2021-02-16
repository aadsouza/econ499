** In this dofile we restructure Zipperer's quarterly state minimum wages

clear *

********************************************************************************
*********************************** PREAMBLE ***********************************
********************************************************************************
global datain  "/Users/amedeusdsouza/Desktop/econ499data/zipperer-min-wage/mw_state_stata"
global dataout "/Users/amedeusdsouza/Desktop/econ499data/zipperer-min-wage"

cd $datain

use mw_state_quarterly, clear

********************************************************************************
gen foo = dofq(quarterly_date)

gen year = year(foo)

drop if year < 1979

gen quarter = quarter(foo)

keep year quarter statefips max_mw //use max state mw in quarter

rename max_mw mwage

gen state =.			
    replace state = 	11	 if statefips == 	23
    replace state = 	12	 if statefips == 	33
    replace state = 	13	 if statefips == 	50
    replace state = 	14	 if statefips == 	25
    replace state = 	15	 if statefips == 	44
    replace state = 	16	 if statefips == 	9
    replace state = 	21	 if statefips == 	36
    replace state = 	22	 if statefips == 	34
    replace state = 	23	 if statefips == 	42
    replace state = 	31	 if statefips == 	39
    replace state = 	32	 if statefips == 	18
    replace state = 	33	 if statefips == 	17
    replace state = 	34	 if statefips == 	26
    replace state = 	35	 if statefips == 	55
    replace state = 	41	 if statefips == 	27
    replace state = 	42	 if statefips == 	19
    replace state = 	43	 if statefips == 	29
    replace state = 	44	 if statefips == 	38
    replace state = 	45	 if statefips == 	46
    replace state = 	46	 if statefips == 	31
    replace state = 	47	 if statefips == 	20
    replace state = 	51	 if statefips == 	10
    replace state = 	52	 if statefips == 	24
    replace state = 	53	 if statefips == 	11
    replace state = 	54	 if statefips == 	51
    replace state = 	55	 if statefips == 	54
    replace state = 	56	 if statefips == 	37
    replace state = 	57	 if statefips == 	45
    replace state = 	58	 if statefips == 	13
    replace state = 	59	 if statefips == 	12
    replace state = 	61	 if statefips == 	21
    replace state = 	62	 if statefips == 	47
    replace state = 	63	 if statefips == 	1
    replace state = 	64	 if statefips == 	28
    replace state = 	71	 if statefips == 	5
    replace state = 	72	 if statefips == 	22
    replace state = 	73	 if statefips == 	40
    replace state = 	74	 if statefips == 	48
    replace state = 	81	 if statefips == 	30
    replace state = 	82	 if statefips == 	16
    replace state = 	83	 if statefips == 	56
    replace state = 	84	 if statefips == 	8
    replace state = 	85	 if statefips == 	35
    replace state = 	86	 if statefips == 	4
    replace state = 	87	 if statefips == 	49
    replace state = 	88	 if statefips == 	32
    replace state = 	91	 if statefips == 	53
    replace state = 	92	 if statefips == 	41
    replace state = 	93	 if statefips == 	6
    replace state = 	94	 if statefips == 	2
    replace state = 	95	 if statefips == 	15

drop statefips
	
gen qcpi =.
	replace qcpi = 100.0 if year == 1979 & quarter == 1
    replace qcpi = 103.179 if year == 1979 & quarter == 2
    replace qcpi = 106.503 if year == 1979 & quarter == 3
    replace qcpi = 109.875 if year == 1979 & quarter == 4
    replace qcpi = 114.21 if year == 1980 & quarter == 1
    replace qcpi = 118.064 if year == 1980 & quarter == 2
    replace qcpi = 120.279 if year == 1980 & quarter == 3
    replace qcpi = 123.651 if year == 1980 & quarter == 4
    replace qcpi = 127.071 if year == 1981 & quarter == 1
    replace qcpi = 129.721 if year == 1981 & quarter == 2
    replace qcpi = 133.333 if year == 1981 & quarter == 3
    replace qcpi = 135.501 if year == 1981 & quarter == 4
    replace qcpi = 136.705 if year == 1982 & quarter == 1
    replace qcpi = 138.68 if year == 1982 & quarter == 2
    replace qcpi = 141.089 if year == 1982 & quarter == 3
    replace qcpi = 141.522 if year == 1982 & quarter == 4
    replace qcpi = 141.618 if year == 1983 & quarter == 1
    replace qcpi = 143.256 if year == 1983 & quarter == 2
    replace qcpi = 144.653 if year == 1983 & quarter == 3
    replace qcpi = 146.098 if year == 1983 & quarter == 4
    replace qcpi = 148.17 if year == 1984 & quarter == 1
    replace qcpi = 149.566 if year == 1984 & quarter == 2
    replace qcpi = 150.867 if year == 1984 & quarter == 3
    replace qcpi = 152.168 if year == 1984 & quarter == 4
    replace qcpi = 153.565 if year == 1985 & quarter == 1
    replace qcpi = 154.961 if year == 1985 & quarter == 2
    replace qcpi = 155.925 if year == 1985 & quarter == 3
    replace qcpi = 157.514 if year == 1985 & quarter == 4
    replace qcpi = 158.333 if year == 1986 & quarter == 1
    replace qcpi = 157.563 if year == 1986 & quarter == 2
    replace qcpi = 158.526 if year == 1986 & quarter == 3
    replace qcpi = 159.634 if year == 1986 & quarter == 4
    replace qcpi = 161.561 if year == 1987 & quarter == 1
    replace qcpi = 163.391 if year == 1987 & quarter == 2
    replace qcpi = 165.125 if year == 1987 & quarter == 3
    replace qcpi = 166.667 if year == 1987 & quarter == 4
    replace qcpi = 167.967 if year == 1988 & quarter == 1
    replace qcpi = 169.894 if year == 1988 & quarter == 2
    replace qcpi = 171.965 if year == 1988 & quarter == 3
    replace qcpi = 173.844 if year == 1988 & quarter == 4
    replace qcpi = 175.819 if year == 1989 & quarter == 1
    replace qcpi = 178.661 if year == 1989 & quarter == 2
    replace qcpi = 180.058 if year == 1989 & quarter == 3
    replace qcpi = 181.888 if year == 1989 & quarter == 4
    replace qcpi = 185.019 if year == 1990 & quarter == 1
    replace qcpi = 186.85 if year == 1990 & quarter == 2
    replace qcpi = 190.077 if year == 1990 & quarter == 3
    replace qcpi = 193.304 if year == 1990 & quarter == 4
    replace qcpi = 194.75 if year == 1991 & quarter == 1
    replace qcpi = 195.906 if year == 1991 & quarter == 2
    replace qcpi = 197.399 if year == 1991 & quarter == 3
    replace qcpi = 199.037 if year == 1991 & quarter == 4
    replace qcpi = 200.385 if year == 1992 & quarter == 1
    replace qcpi = 201.927 if year == 1992 & quarter == 2
    replace qcpi = 203.468 if year == 1992 & quarter == 3
    replace qcpi = 205.25 if year == 1992 & quarter == 4
    replace qcpi = 206.744 if year == 1993 & quarter == 1
    replace qcpi = 208.237 if year == 1993 & quarter == 2
    replace qcpi = 209.2 if year == 1993 & quarter == 3
    replace qcpi = 210.934 if year == 1993 & quarter == 4
    replace qcpi = 211.994 if year == 1994 & quarter == 1
    replace qcpi = 213.198 if year == 1994 & quarter == 2
    replace qcpi = 215.173 if year == 1994 & quarter == 3
    replace qcpi = 216.426 if year == 1994 & quarter == 4
    replace qcpi = 218.015 if year == 1995 & quarter == 1
    replace qcpi = 219.798 if year == 1995 & quarter == 2
    replace qcpi = 220.906 if year == 1995 & quarter == 3
    replace qcpi = 222.11 if year == 1995 & quarter == 4
    replace qcpi = 224.085 if year == 1996 & quarter == 1
    replace qcpi = 226.012 if year == 1996 & quarter == 2
    replace qcpi = 227.312 if year == 1996 & quarter == 3
    replace qcpi = 229.287 if year == 1996 & quarter == 4
    replace qcpi = 230.684 if year == 1997 & quarter == 1
    replace qcpi = 231.214 if year == 1997 & quarter == 2
    replace qcpi = 232.37 if year == 1997 & quarter == 3
    replace qcpi = 233.622 if year == 1997 & quarter == 4
    replace qcpi = 234.104 if year == 1998 & quarter == 1
    replace qcpi = 234.875 if year == 1998 & quarter == 2
    replace qcpi = 236.079 if year == 1998 & quarter == 3
    replace qcpi = 237.187 if year == 1998 & quarter == 4
    replace qcpi = 238.054 if year == 1999 & quarter == 1
    replace qcpi = 239.836 if year == 1999 & quarter == 2
    replace qcpi = 241.618 if year == 1999 & quarter == 3
    replace qcpi = 243.401 if year == 1999 & quarter == 4
    replace qcpi = 245.809 if year == 2000 & quarter == 1
    replace qcpi = 247.736 if year == 2000 & quarter == 2
    replace qcpi = 250.0 if year == 2000 & quarter == 3
    replace qcpi = 251.782 if year == 2000 & quarter == 4
    replace qcpi = 254.191 if year == 2001 & quarter == 1
    replace qcpi = 255.973 if year == 2001 & quarter == 2
    replace qcpi = 256.696 if year == 2001 & quarter == 3
    replace qcpi = 256.503 if year == 2001 & quarter == 4
    replace qcpi = 257.322 if year == 2002 & quarter == 1
    replace qcpi = 259.345 if year == 2002 & quarter == 2
    replace qcpi = 260.742 if year == 2002 & quarter == 3
    replace qcpi = 262.283 if year == 2002 & quarter == 4
    replace qcpi = 264.981 if year == 2003 & quarter == 1
    replace qcpi = 264.547 if year == 2003 & quarter == 2
    replace qcpi = 266.522 if year == 2003 & quarter == 3
    replace qcpi = 267.534 if year == 2003 & quarter == 4
    replace qcpi = 269.798 if year == 2004 & quarter == 1
    replace qcpi = 271.917 if year == 2004 & quarter == 2
    replace qcpi = 273.651 if year == 2004 & quarter == 3
    replace qcpi = 276.59 if year == 2004 & quarter == 4
    replace qcpi = 277.987 if year == 2005 & quarter == 1
    replace qcpi = 279.865 if year == 2005 & quarter == 2
    replace qcpi = 284.104 if year == 2005 & quarter == 3
    replace qcpi = 286.753 if year == 2005 & quarter == 4
    replace qcpi = 288.247 if year == 2006 & quarter == 1
    replace qcpi = 290.848 if year == 2006 & quarter == 2
    replace qcpi = 293.593 if year == 2006 & quarter == 3
    replace qcpi = 292.389 if year == 2006 & quarter == 4
    replace qcpi = 295.256 if year == 2007 & quarter == 1
    replace qcpi = 298.6 if year == 2007 & quarter == 2
    replace qcpi = 300.49 if year == 2007 & quarter == 3
    replace qcpi = 304.176 if year == 2007 & quarter == 4
    replace qcpi = 307.471 if year == 2008 & quarter == 1
    replace qcpi = 311.471 if year == 2008 & quarter == 2
    replace qcpi = 316.273 if year == 2008 & quarter == 3
    replace qcpi = 309.03 if year == 2008 & quarter == 4
    replace qcpi = 306.904 if year == 2009 & quarter == 1
    replace qcpi = 308.536 if year == 2009 & quarter == 2
    replace qcpi = 311.191 if year == 2009 & quarter == 3
    replace qcpi = 313.627 if year == 2009 & quarter == 4
    replace qcpi = 314.124 if year == 2010 & quarter == 1
    replace qcpi = 314.013 if year == 2010 & quarter == 2
    replace qcpi = 314.934 if year == 2010 & quarter == 3
    replace qcpi = 317.484 if year == 2010 & quarter == 4
    replace qcpi = 320.872 if year == 2011 & quarter == 1
    replace qcpi = 324.521 if year == 2011 & quarter == 2
    replace qcpi = 326.637 if year == 2011 & quarter == 3
    replace qcpi = 328.103 if year == 2011 & quarter == 4
    replace qcpi = 329.951 if year == 2012 & quarter == 1
    replace qcpi = 330.647 if year == 2012 & quarter == 2
    replace qcpi = 332.14 if year == 2012 & quarter == 3
    replace qcpi = 334.349 if year == 2012 & quarter == 4
    replace qcpi = 335.693 if year == 2013 & quarter == 1
    replace qcpi = 335.325 if year == 2013 & quarter == 2
    replace qcpi = 337.139 if year == 2013 & quarter == 3
    replace qcpi = 338.385 if year == 2013 & quarter == 4
    replace qcpi = 340.493 if year == 2014 & quarter == 1
    replace qcpi = 342.301 if year == 2014 & quarter == 2
    replace qcpi = 343.177 if year == 2014 & quarter == 3
    replace qcpi = 342.324 if year == 2014 & quarter == 4
    replace qcpi = 340.108 if year == 2015 & quarter == 1
    replace qcpi = 342.428 if year == 2015 & quarter == 2
    replace qcpi = 343.721 if year == 2015 & quarter == 3
    replace qcpi = 343.695 if year == 2015 & quarter == 4
    replace qcpi = 343.482 if year == 2016 & quarter == 1
    replace qcpi = 346.229 if year == 2016 & quarter == 2
    replace qcpi = 347.698 if year == 2016 & quarter == 3
    replace qcpi = 349.906 if year == 2016 & quarter == 4
    replace qcpi = 352.244 if year == 2017 & quarter == 1
    replace qcpi = 352.871 if year == 2017 & quarter == 2
    replace qcpi = 354.545 if year == 2017 & quarter == 3
    replace qcpi = 357.308 if year == 2017 & quarter == 4
    replace qcpi = 360.086 if year == 2018 & quarter == 1
    replace qcpi = 362.338 if year == 2018 & quarter == 2
    replace qcpi = 363.807 if year == 2018 & quarter == 3
    replace qcpi = 365.228 if year == 2018 & quarter == 4
    replace qcpi = 365.875 if year == 2019 & quarter == 1
    replace qcpi = 369.037 if year == 2019 & quarter == 2
    replace qcpi = 370.219 if year == 2019 & quarter == 3
    replace qcpi = 372.63 if year == 2019 & quarter == 4
	
gen rmwage = mwage*100/qcpi

sort state year quarter		

save "$dataout/qmwage7919.dta", replace

clear
