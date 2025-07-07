/*-------------------------------------------------------------------------------
Traitement B
#------------------------------------------------------------------------------- */
clear
capture log close
webuse set "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data"
global dataurl "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data/"
capture log close
log using "$pathlog\MessyDataExamples.log", replace
cd "$pathdata"
clear all
input str19 agency _1st _2nd _3rd _4th
"DOS"	4	4	4	4
"MCC" 36	29	41	35
"Peace Corps"	73	8	0	0
"USAID" 428	559 429	667
"USDA" 1	0	1	0
end
saveold "column_numbers.dta", replace version(12)
rename (_1st _2nd _3rd _4th) (qtr1 qtr2 qtr3 qtr4)
reshape long qtr, i(agency) j(quarter)
rename qtr freq
graph bar (mean) freq, over(quarter) by(agency, style(compact) rows(1)) scheme(s1color)
graph bar (mean) freq, over(quarter) by(agency, yrescale style(compact) rows(1))
* ------------------------------------------------- *
clear all
input str3 country str5 agency q1FY2009 q2FY2009 q3FY2009 q4FY2009 q1FY2010 q2FY2010 q3FY2010 q4FY2010
"AFG"	"USAID"	399	361	254	71	378	398	85	39
"ALB"	"USAID"	45	282	40	285	306	230	398	216
"ANG"	"USAID"	354	24	19	252	146	123	369	376
"ARM"	"USAID"	86	89	127	212	394	255	141	74
"AZE"	"USAID"	116	239	330	34	92	315	312	220
end
saveold "mVars_column.dta", replace version(12)
reshape long q@, i(country) j(time, string)
generate qtr = real(substr(time, 1, 1))
generate year = real(substr(time, 4, 7))
sort country  year qtr
order country agency qtr year q
* --- Alternative method: using reshape twice --- *
clear all
input str3 country str5 agency q1FY2009 q2FY2009 q3FY2009 q4FY2009 q1FY2010 q2FY2010 q3FY2010 q4FY2010
"AFG"	"USAID"	399	361	254	71	378	398	85	39
"ALB"	"USAID"	45	282	40	285	306	230	398	216
"ANG"	"USAID"	354	24	19	252	146	123	369	376
"ARM"	"USAID"	86	89	127	212	394	255	141	74
"AZE"	"USAID"	116	239	330	34	92	315	312	220
end
reshape long q1FY@ q2FY@ q3FY@ q4FY@, i(country) j(year)
sort country year
rename *FY *
reshape long q@, i(country year) j(qtr)
rename q freq 
* ------------------------------------------------- *
clear all
input str6 stringid	str6 good year2011 year2012
"Malawi" "coffee"	5.93	2.40
"Malawi" "maize"	1.23	0.56
"Uganda" "coffee"	3.09	4.26
"Uganda" "maize"	9.17	7.51
"Rwanda" "coffee"	7.35	3.23
"Rwanda" "maize"	4.78	6.46
end
saveold "vars_row_columns.dta", replace version(12)
reshape wide year*, i(stringid) j(good, string)
cap reshape long year2011coffee year2012coffee year2011maize year2012maize, i(stringid) j(year)
rename (year2011coffee year2012coffee year2011maize year2012maize) 
foreach x of varlist year* {
	local n1: variable label `x'
	local n2 = strtoname("`n1'")
	rename `x' `n2'
}
rename *_year* **
reshape long coffee@ maize@, i(stringid) j(year)
list, clean noo
* ### Reshape examples ###
clear
input id gdp2014 gdp2015 cpc2014 cpc2015
1 8.28 9.99 1 1
2 9.10 4.05 0 0
end
saveold "gdp_cpc.dta", replace version(12)
clist, noo
reshape long gdp@ cpc@, i(id) j(year)
reshape wide
* ### Reshape Exercise  & Solution ###
webuse "wb_gdp_wide.dta", clear
reshape long yr@, i(countryname) j(year)
rename (countryname countrycode yr) (country ISO3 gdp)
drop seriesname seriescode
twoway(connected gdp year), by(country) scheme(s1color)
table country year, c(mean gdp) f(%9.2f) col
egen gdp_ave = mean(gdp), by(country)
tab country, sum(gdp_ave)
* -------------------------------------------------- *
clear
input id age hid
1 45 101
2 20 101
1 23 102
2 20 102
end
saveold "ind.dta", replace version(12)
clear
input id cows value
1 2 2000
2 1 500
end
saveold "ind_ag.dta", replace version(12)
clear
input id age hid
1 45 101
2 20 101
end
saveold "ind_age.dta", replace version(12)
clear
input hid str4 income
101 "$100"
102 "$250"
end
saveold "hh.dta", replace version(12)
clear
input hid str4 income
101 "$100"
102 "$250"
104 "$500"
end
saveold "hh2.dta", replace version(12)
clear
input id age hid
1 45 101
2 20 101
1 23 102
2 20 102
1 43 103
2 5  103
end
saveold "ind2.dta", replace version(12)
* Messy data for merge exercise
clear
input hid str4 income
101 "$100"
101 "$100"
102 "$250"
104 "$500"
104 ""
end
saveold "hh3.dta", replace version(12)
* -------------------------------------------------- *
/* ### Appending ###
Stacking two datasets with common variables. Could be used to update a dataset. 
Use scalars to keep track of total expected observations, after append */
webuse "disbursements.dta", clear
count
scalar disb_N = r(N)
webuse "obligations.dta", clear
count
scalar ob_N = r(N)
scalar dir
display ob_N + disb_N
* Append two datasets together
append using "$dataurl/disbursements.dta", gen(data_source)
tab data_source, mi
*label data source values
label define fisc_type 0 "obligations" 1 "disbursements"
label values data_source fisc_type 
count
clear
* -------------------------------------------------- *
webuse "StataTrainingClean.dta", clear
sum
sum spent, detail 
bysort fiscalyear: sum spent
bysort fiscalyear: sum spent if inlist("USAID", agency), d
tab fiscalyear agency, mi
tab fiscalyear, sum(spent) means
tab fiscalyear, sum(spent)
tab agency, gen(agency_flag)
tabsort agency, sum(spent) so(mean)
tab agency, sum(spent)
tabsort agency fiscalyear
tabsort category, sum(spent) sort (spent)
tabstat spent, by(fiscalyear) stat(mean median sd n)
tabstat spent, by(agency_flag8) stat(mean median sd n) nototal col(stat)
tabstat spent, by(agency_flag8) stat(mean median sd n)
table fiscalyear qtr if inlist("USAID", agency), 
bysort agency: table fiscalyear qtr, c(sum spent) f(%9.2fc)
egen tot_spent = total(spent), by(qtr fiscalyear agency fiscalyeartype)
twoway(connected tot_spent qtr, sort) if agency == "USAID", by(fiscalyear) scheme(s1color)
twoway(connected tot_spent qtr if agency == "USAID" & fiscalyeartype == "Obligations", sort)/*
*/ (connected tot_spent qtr if agency == "USAID" & fiscalyeartype == "Disbursements", sort) /*
*/, by(fiscalyear) scheme(s1color) legend(order(1 "Obligations" 2 "Disbursements"))
table agency fiscalyear, c(mean spent count spent) f(%9.2fc) row col
* -------------------------------------------------- *
* ### Collapsing ###
webuse "StataTrainingClean.dta", clear 
keep if fiscalyeartype == "Disbursements"
order agency fiscalyear category spent
* Task: Create table showing aggregate category spending for each agency by year
bys fiscalyear: table agency category, c(sum spent count spent mean spent) f(%12.2fc)
* Hard to do, let's try to collapse the data
collapse (sum) spent (count) count = spent (mean) ave_spent = spent, by(agency category fiscalyear)
label variable spent "Total disbursements (M USD)"
format spent %9.0f
* Can you plot or summarize aggregate spending now?
local labopts "ylabel(, labsize(small) angle(horizontal)) xlabel(, labsize(vsmall)) ytitle(, size(vsmall)) xtitle(, size(vsmall))"
local layout "by(category, rows(2)) subtitle(, size(tiny) fcolor("245 245 245") bexpand)"
local lineopt "lcolor("102 194 165") mcolor("102 194 165") mlcolor("white") msize(medium) ylabel(, nogrid)"
local gopts "graphregion(fcolor(none) ifcolor(none))"
twoway(connected spent fiscalyear, `lineopt' ) if agency == "USAID", by(category,  note("")) ///
 yscale(noline) `labopts' `layout' scheme(s1mono) `gopts'
* --------------------------------------------
webuse "StataTrainingClean.dta", clear
* Keep only observations from agency == USAID
keep if inlist(agency, "USAID") & fiscalyeartype == "Disbursements"
* Collapse data down, summing total price by fiscalyear and category
collapse (sum) spent, by(fiscalyear category)
la var spent "aggregate disbursements"
* Tabulate results
table category fiscalyear, c(mean spent) format(%9.2fc)
* Plot results
twoway(connected spent fiscalyear, sort), by(category) ///
scheme(s1color) subtitle(, size(vsmall))
* === Extra Credit === *
use "StataTrainingClean.dta", clear
collapse (sum) spent, by(fiscalyear fiscalyeartype qtr agency)
* Look at patterns
bysort fiscalyeartype: table fiscalyear qtr if inlist(agency, "USAID") & ///
inrange(fiscalyear, 2010, 2013), c(mean spent) format(%9.2fc)
la var spent "Total spending (M USD)"
* formatting graph
* Can you plot or summarize aggregate spending now?
local labopts "ylabel(, labsize(small) angle(horizontal)) xlabel(, labsize(vsmall)) ytitle(, size(vsmall)) xtitle(, size(vsmall))"
local layout "subtitle(, size(tiny) fcolor("245 245 245") bexpand)"
local lineopt1 "lcolor("171 221 165") mcolor("102 194 165") mlcolor("white") msize(medium) lpattern(solid) msymbol(circle)" 
local lineopt2 "lcolor("253 174 97") mcolor("244 109 67") mlcolor("white") msize(medium) lpattern(solid)"
local gopts "graphregion(fcolor(none) ifcolor(none)) ylabel(, nogrid)"
* Let's plot the patterns for USAID
twoway(connected spent qtr if fiscalyeartype == "Disbursements", sort `lineopt2') ///
(connected spent qtr if fiscalyeartype == "Obligations", sort `lineopt1') ///
if inlist(agency, "USAID") & inrange(fiscalyear, 2010, 2013), by(fiscalyear, note("")) ///
legend(order(1 "Obligations" 2 "Disbursements") nobox region(fcolor(none) lcolor(none)) ///
 size(tiny) span) subtitle(, size(vsmall)) `labopts' `layout' scheme(s1mono) `gopts'
* === Estout ===*
cls
webuse "StataTrainingClean.dta", clear
* Post results from the summary command to e(class) format
estpost sum spent2 if inlist(fiscalyeartype, "Disbursements"), detail
*ereturn list
* Write selected statistics to a text file
esttab . using "disbursement_means1.txt", cells("mean p50 sd min max count") noobs replace
* Fix formatting and rewrite, saving over existing text file
local fmt1 "mean (fmt(%12.2fc)) p50(fmt(%12.2fc)) sd(fmt(%12.2fc))"
local fmt2 "min(fmt(%12.0fc)) max(fmt(%12.0fc)) count(fmt(%12.0fc))"
esttab . using "disbursement_means2.txt", cells("`fmt1' `fmt2'") noobs replace nomtitles nonum
* -------------------------------------------------- *
* === Estout Exercise === *
cls
webuse "StataTrainingClean.dta", clear
estpost tabulate category fiscalyear if inrange(fiscalyear, 2009, 2013), nototal
esttab using test.rtf, cell(b(fmt(0))) unstack noobs collabels(none) modelwidth(5) nonumber ///
 varlabels(`e(labels)') eqlabels(`e(eqlabels)')	title(Tableau 1: Format rtf) replace 
