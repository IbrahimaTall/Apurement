 /*
******Part D - Analysis
 Answer questions for analysis
*/

**************************************************************************
/// PART A - Import and Explore Data ///
set directory
cd "WDI_Data"
* list the files in the directory
ls
** A.1 Import one data set **
* Import "Data" tab starting at A4, first row as variable names
import excel "ag_empl.xls", sheet("Data") cellrange(A4:BH252) firstrow clear
* Time to dig into the data
browse
describe
codebook, c

** A.2 Loop import over each of the indicator files **
foreach x in ag_empl chldmort electricity health_exp_pc hivprev pop pop_rural sanitation {
    * import excel data
    import excel "`x'.xls", sheet("Data") cellrange(A4:BH252) firstrow clear
    * replace IndicatorCode with the variable name for reshaping later
    replace IndicatorCode = "`x'"
    * save as a Stata file
    save "`x'.dta", replace 
}
** A.3 Import country meta data *****
* import meta Data on Countries
import excel "ag_empl.xls", sheet("Metadata - Countries") firstrow clear
* encode region and income group for ease of use later
encode Region, generate(reg)
encode IncomeGroup, generate(inc)
* drop variables we will not use
drop Region IncomeGroup SpecialNotes
* save
save "ctrymeta.dta", replace

********************************************************************************

// PART B - Append, Reshape, and Clean Data //	
* B.1 Append files together **
* open one of the datasets
use "ag_empl.dta", clear
* append with the other datasets
append using chldmort electricity  health_exp_pc hivprev pop pop_rural sanitation

** B.2 - Rename years (loop and drop unncessary years **
* add year labels to variables
foreach year of var E-BH{
    local l`year' : variable label `year'
    rename `year' y`l`year''
}
* only want to look at a 10 year period, so we can remove extra years
drop y1960-y2001 y2013-y2015

** B.3 - Reshape 1 (long format) **
* reshape long to have one column for year, country, and flow
reshape long y@, i(CountryName IndicatorName) j(year)
* cleaning
drop IndicatorName // not needed; will be in variable label
encode IndicatorCode, generate(ind) // need to encode for reshape
drop IndicatorCode // no longer needed
order CountryName CountryCode year ind y // reorder for viewing when browsing
label list ind // list for labeling variables after reshape

** B.4 - Reshape 2 (wide) **
* rehape wide to have one column for each variable
reshape wide y@, i(CountryName CountryCode year) j(ind)

** B.5 - Label and rename variables **
* rename and label wdi variables
rename (y1 y2 y3 y4 y5 y6 y7 y8)(ag_empl chldmort electricity health_exp_pc hivprev pop pop_rural sanitation)
label variable ag_empl "Employment in agriculture (% of total employment)"
label variable chldmort "Mortality rate, under-5 (per 1,000)"
label variable electricity "Access to electricity (% of population)"
label variable health_exp_pc "Health expenditure per capita (current US$)"
label variable hivprev "Prevalence of HIV, total (% of population ages 15-49)"
label variable pop "Population, total"
label variable pop_rural "Rural population (% of total population)"
label variable sanitation "Improved sanitation facilities (% of population with access)"

*************************************************************************
// PART C - Merge and Save Data //

** C.1 - Merge metadata onto datafile **
* merge with ctry meta 
merge m:1 CountryCode using "ctrymeta.dta"
drop _merge // since everything merged other than unclassificed, we don't need this variable
* rename variables (all lower case for consistency)
rename CountryName ctry
rename CountryCode iso
label variable iso "ISO Country Code"
label variable year "Year"
order reg inc, before(ag_empl)

** C.2 - Save **
save "wdi_meta_full.dta", replace
	
********************************************************************************

// PART D - Analysis //
** D.1 - What was the average percent of the workforce employed in agriculture by region in 2012?
tabstat ag_empl if year==2012, by(reg) stat(mean count) format(%9.1f)

** D.2 - How many people had access to improved sanitation in 2012 by region?
generate san_tot = int(pop*(sanitation/100))
label variable san_tot "Total People with improved Sanitation"
tabstat san_tot if year==2012, by(reg) statistic(sum) format(%13.0fc)

** D.3 - Visualize the relationship between access to improved sanitation and size of a country's rural population in 2010 via a a scatter plot.
scatter sanitation pop_rural if year == 2010 || lfit sanitation pop_rural
	
** D.4 - How has population growth changed over the period of 2003-2012 across different country income level groups?
collapse (sum) pop, by(inc year)
drop if inc == .
sort inc year
by inc: gen pop_gr = (pop - pop[_n-1])/pop[_n-1]*100
lab var pop_gr "Pop Growth Rate, %"
twoway connected pop_gr year, by(inc, title("Population Growth") sub("2003-2012"))
