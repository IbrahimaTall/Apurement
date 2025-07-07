help import
cd // this will show us what our current working directory is
global pathin "/Users/Aaron/Desktop/StataTraining/Day1/Data/" 
cd $pathin // this changes our working directory location
insheet using "StataTraining.csv", clear
save FAD.dta, /// file will save to the same directory we defined working in
replace	//replaces the file if its already existing
browse
use FAD.dta
describe
sort spent
gsort - spent //allows us to sort in decending order (negative sign)
list benefitingcountry agency spent in 1/10 // this gives us the first 10 lines
list benefitingcountry agency spent in 1/10
sum spent, d // gives more detail
bysort fiscalyear: sum spent
table fiscalyear, c(mean spent med spent count spent)
table fiscalyear if sector == "Agriculture", c(mean spent med spent)
table fiscalyear sector	if inlist(sector, "Agriculture", "Nutrition", "Malaria"), c(mean spent)
hist spent if fiscalyear==2012 & fiscalyeartype=="Obligations", frequency
graph bar (sum) spent if fiscalyear==2012 & fiscalyeartype=="Obligations", over(agency)
preserve {
    collapse (sum) spent, by(fiscalyear agency)
    sort fiscalyear
    twoway connected spent fiscalyear if agency=="USAID" || connected spent fiscalyear if agency=="MCC"
}
restore
sysuse census.dta
use FAD.dta, clear
gen spent_mil = spent/1000000
lab var spent_mil "Amount, millions USD"
format spent_mil %9.0fc //adding formatting - see help format
list operatingunit agencyname spent_mil in 1/10
lab def lqtr 1 "Q1" 2 "Q2" 3 "Q3" 4"Q4"
lab val qtr lqtr
codebook qtr
browse qtr
encode sector, gen(sect)
encode category, gen(cat)
order sect cat, after(benefitingcountry)
drop sector category spent2
drop if operatingunit=="Worldwide"
collapse (sum) spent if sector == "Agriculture", by(fiscalyear sector operatingunit)
egen rank = rank(-spent), by(fiscalyear) //negative added to sort in decending order
sort fiscalyear rank
browse rank operatingunit spent if fiscalyear==2013
egen meanexp = mean(spent), by(fiscalyear)
gen highexp = 0 // all OUs are given a zero
replace highexp = 1 if spent > meanexp 
lab var highexp "Ag expenditures greater than avg"
lab def yn 0 "No" 1 "Yes"
lab val highexp yn
tab fiscalyear highexp
