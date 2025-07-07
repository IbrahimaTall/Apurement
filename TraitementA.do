/*-------------------------------------------------------------------------------
Ibrahima Tall
#-------------------------------------------------------------------------------
*/
webuse set "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data"
global dataurl "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data"
capture log close
log using "$pathlog\Day2Homework.log", replace
import delimited "$dataurl/wb_indicators.csv", clear
browse
describe
count if inlist("..", yr2007, yr2008, yr2013, yr2014) == 1
foreach x of varlist yr2007 yr2008 yr2013 yr2014 {
    replace `x' = "" if inlist("..", `x')
    destring `x', gen(`x'_ds) 
}
drop yr2007 yr2008 yr2013 yr2014
rename *_ds* **
drop seriescode
replace seriesname = "gdp_growth" if seriesname == "GDP growth (annual %)"
replace seriesname = "ag_gdp" if seriesname == "Agriculture, value added (% of GDP)"
replace seriesname = "tax_gdp" if seriesname == "Tax revenue (% of GDP)"
reshape wide yr*, i(countryname) j(seriesname, string)
ds, not(type string)
local renlist = r(varlist)
set tr on 
foreach v of local renlist {
	display in yellow "We are on `v' variable now"
	local x : variable label `v'
	display in yellow "ensure that the variable label for `x' is a valid name and store it in y"
	local y = strtoname("`x'")
	display in white "Now we'll rename `v' to be `y'"
	rename `v' `y' 
	display in white "Our variable should now be named `y'"
}
set tr off
rename *_yr* **
reshape long ag_gdp@ gdp_growth@ tax_gdp@, i(countryname) j(year)
label var ag_gdp "agricultural sector (value added) as % of gdp"
label var gdp_growth "gdp growth rate"
label var tax_gdp "taxes collected as % of gdp"
twoway(connected ag_gdp gdp_growth tax_gdp year, sort), by(countryname) scheme(s1color)
table countryname year, c(mean gdp_growth) f(%9.2fc) row col
encode countryname, gen(country_id)
sort countryname year
gen loc_time_id = real( string(country_id) + string(year) )
isid loc_time_id
saveold "C:\Users\t\Documents\GitHub\StataTraining\Day2\Data\wb_indicators_long.dta", replace
ren(ag_gdp gdp_growth tax_gdp) (gdpag gdpgrowth gdptax)
reshape long gdp@, i(loc_time_id) j(gdpType, string)
la var gdp "gdp values"
la var gdpType "type of gdp, growth is overall growth"
* ### NOTE!: This complicates the merge somewhat, you'll likely have to execute a many-to-many
cls
use "$dataurl/FA_merge.dta", clear
clist
merge m:1 loc_time_id using "$dataurl/wb_indicators_long.dta"
ren(ag_gdp gdp_growth tax_gdp) (gdpag gdpgrowth gdptax)
reshape long gdp@, i(loc_time_id category) j(gdpType, string)
la var gdp "Gdp values"
