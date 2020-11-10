**********************************
* Corporate Citizen
* Table 4 Regression
* Last updated 10/13/2020
**********************************

set more off, permanently
clear all

*global directory "/Users/yaoliu/Dropbox/Columbia/Working Paper/Co_authored Project/With_Shirley/Corporate Citizen/2 Data"
global directory "/Users/yl4689/Dropbox/Columbia/Working Paper/Co_authored Project/With_Shirley/Corporate Citizen/2 Data"
*global directory "C:\Users\slu11\Dropbox\Master Research\Corporate Citizen\2 Data"
cd "$directory"



use 1_combined\RA_replication\zip_analysis_clean.dta, clear

use 1_combined/RA_replication/zip_analysis_clean.dta, clear

** keep pre
keep if date_policy_t<0

egen county_date=group(county_fips date)

** regression with city-day FE
reghdfe device_home_ratio i.prepolicy_20day c.exposure_pc1 i.prepolicy_20day#c.exposure_pc1 demo_asian population_log income_log establishment_log teleworkable_emp_establish , absorb(city_i#date) vce(cluster state_fips)

** regression with county-day FE
reghdfe device_home_ratio i.prepolicy_20day c.exposure_pc1 i.prepolicy_20day#c.exposure_pc1  demo_asian population_log income_log establishment_log teleworkable_emp_establish , absorb(county_fips#date) vce(cluster state_fips)

reghdfe device_home_ratio i.prepolicy_20day c.exposure_pc1 i.prepolicy_20day#c.exposure_pc1  demo_asian population_log income_log establishment_log teleworkable_emp_establish , absorb(county_date) vce(cluster state_fips)
