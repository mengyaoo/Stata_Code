capture log close
clear all
clear matrix
set maxvar 120000, permanently
set more off
log using impact_of_adblockers.log, append

use dataset.dta 
xtset panel_id week_id

destring zipcode, replace

by panel_id: egen adblocker_adopter = max(adblocker_installed)

gen lntotal_spending = ln(total_spending+1)
gen lntotal_spending_heavyadv = ln(total_spending_heavyadv+1)
gen lntotal_spending_lightadv = ln(total_spending_lightadv+1)
gen lntotal_spending_newbrands = ln(total_spending_newbrands+1)
gen lntotal_spending_notnewbrands = ln(total_spending_notnewbrands+1)


******************************************************************************************************************************************************************
************************							 									  														******************
************************									Effect of Ad-blockers on Online Purchase Spending									******************
************************												  																		******************
******************************************************************************************************************************************************************
 
local y "lntotal_spending"
local mod "areg"

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 																						i.week_id , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 																		i.week_id , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  															i.week_id , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll r2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
 

******************************************************************************************************************************************************************
************************							 									  														******************
************************				Effect of Ad-blockers on Online Purchase Spending for Heavy Online Advertisers							******************
************************												  																		******************
******************************************************************************************************************************************************************

local y "lntotal_spending_heavyadv"
local mod "areg"

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 																						i.week_id , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 																		i.week_id , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  															i.week_id , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll r2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
 
 
******************************************************************************************************************************************************************
************************							 									  														******************
************************					Effect of Ad-blockers on Online Purchase Spending for Light Online Advertisers						******************
************************												  																		******************
******************************************************************************************************************************************************************

local y "lntotal_spending_lightadv"
local mod "areg"

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 																						i.week_id , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 																		i.week_id , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  															i.week_id , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll r2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
 
 
******************************************************************************************************************************************************************
************************							 									  														******************
************************		Effect of Ad-blockers on Online Purchase Spending (Brands Consumers Have Not Experienced)						******************
************************												  																		******************
******************************************************************************************************************************************************************
 
local y "lntotal_spending_newbrands" // based on a consumer's past purchasing history 
local mod "areg"

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 																						i.week_id , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 																		i.week_id , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  															i.week_id , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll r2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )


******************************************************************************************************************************************************************
************************							 									  														******************
************************				Effect of Ad-blockers on Online Purchase Spending (Brands Consumers Have Experienced)					******************
************************												  																		******************
******************************************************************************************************************************************************************
 
local y "lntotal_spending_notnewbrands" // based on a consumer's past purchasing history 
local mod "areg"

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 																						i.week_id , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 																		i.week_id , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  															i.week_id , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll r2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )


******************************************************************************************************************************************************************
************************							 									  														******************
************************							Effect of Ad-blockers on Search Behavior (Search Engine Visits)								******************
************************												  																		******************
******************************************************************************************************************************************************************

local y "visits_search_engine"
local mod "xtpoisson"											

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 													i.week_id , fe vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 									i.week_id , fe vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  						i.week_id , fe vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll chi2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
 
 
******************************************************************************************************************************************************************
************************							 									  														******************
************************						Effect of Ad-blockers on Search Behavior (E-commerce Web Visits)								******************
************************												  																		******************
******************************************************************************************************************************************************************
  
local y "visits_shopping"
local mod "xtpoisson"											

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"


quietly `mod' `y' `basic_vars' 													i.week_id , fe vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 									i.week_id , fe vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars'  						i.week_id , fe vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll chi2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
 
 
 
******************************************************************************************************************************************************************
************************							 									  														******************
************************												Parallel Trends															******************
************************												  																		******************
******************************************************************************************************************************************************************

local y "lntotal_spending" 
local mod "areg"											

local basic_vars "l1.adblocker_installed" 
local context_vars "c.holidays" 
local dem_vars "i.income_bin i.education_bin i.age_bin i.household_size"

quietly `mod' `y' `basic_vars' 									 c.week_id c.week_id#1.adblocker_adopter i.week_id if (adblocker_adopter == 0 | after_adblocker == 0) , absorb(panel_id) vce(robust)
estimates store blo1, title(Model 1)

quietly `mod' `y' `basic_vars' 	`context_vars' 					 c.week_id c.week_id#1.adblocker_adopter i.week_id if (adblocker_adopter == 0 | after_adblocker == 0) , absorb(panel_id) vce(robust)
estimates store blo2, title(Model 2)

quietly `mod' `y' `basic_vars' 	`context_vars' `dem_vars' 		 c.week_id c.week_id#1.adblocker_adopter i.week_id if (adblocker_adopter == 0 | after_adblocker == 0) , absorb(panel_id) vce(robust)
estimates store blo3, title(Model 3)

estout blo1 blo2 blo3, cells(b(star fmt(%9.4f)) se(par)) ///
stats(ll chi2, fmt(%12.3f %9.3f) labels(Log-likelihood R-squared)) ///
varwidth(30) legend label collabels(none) varlabels(_cons Constant) nonumbers nobaselevels noomitted  interaction(" x ") wrap ///
drop (*week_id *income_bin *education_bin *age_bin *household_size) ///
rename( ) noabbrev starlevels( * 0.05 ** 0.010 *** 0.001 )
   
 
