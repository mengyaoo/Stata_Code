**********************************
* Corporate Citizen
* Regression Tables
* Last updated 11/10/2020
**********************************

set more off, permanently
clear all

*global directory "/Users/yaoliu/Dropbox/Columbia/Working Paper/Co_authored Project/With_Shirley/Corporate Citizen/2 Data"
global directory "C:\Users\slu11\Dropbox\Master Research\Corporate Citizen\2 Data"
cd "$directory"



use 1_combined\RA_replication\zip_analysis_clean, clear

******************* Clean data *********************
** keep pre
keep if date_policy_t<0

** create new treatment variable
egen exposure_total = rowtotal(factset_China_final  china_edu_final  china_segment_final factset_Italy_final  italy_edu_final  Italy_segment_final)
gen exposure_total_scaled = exposure_total/establishment
label variable exposure_total_scaled "Information Exposure Networks Scaled"
label variable any_exposure_binary "Information Exposure Binary"

******************* Regression *********************
** main table
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control' i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish , absorb(city_i#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "Yes"
estadd local countydayFE "No"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "Yes"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled i.prepolicy_20day#c.social_capital_county i.prepolicy_20day#c.deaths  i.prepolicy_20day#c.cases `control' c.deaths c.cases c.social_capital_county i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb( state_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "No"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 2_output/table_main.rtf, replace label title(Change in Stay-at-Home Ratio 20 Days before Policy Intervention) noobs s(N r2_a zipFE citydayFE countydayFE statedayFE cluster, label("N" "Adj. R-squared" "Zip-code FE" "City-Day FE"  "County-Day FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_20day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_20day exposure_total_scaled social_capital_county) order(1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_20day  1.prepolicy_20day#c.social_capital_county  1.prepolicy_20day#c.cases cases 1.prepolicy_20day#c.deaths deaths)
** only for this table I include below the same output but in latex format
esttab using 2_output/table_main.tex, replace label title(Change in Stay-at-Home Ratio 20 Days before Policy Intervention) noobs s(N r2_a zipFE citydayFE countydayFE statedayFE cluster, label("N" "Adj. R-squared" "Zip-code FE" "City-Day FE"  "County-Day FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_20day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_20day exposure_total_scaled social_capital_county) order(1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_20day  1.prepolicy_20day#c.social_capital_county  1.prepolicy_20day#c.cases cases 1.prepolicy_20day#c.deaths deaths)

******************* Robustness *********************
** Robust appendix: cutoff by population and establishments 
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish if Population>5000 & establishment>5, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>5000 Est>5"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish if Population>10000 & establishment>5, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>10000 Est>5"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish if Population>10000 & establishment>7, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>10000 Est>7"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day i.any_exposure_binary i.prepolicy_20day#i.any_exposure_binary  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish if Population>5000 & establishment>5, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>5000 Est>5"
esttab using 2_output/table_appendix_limitpop.rtf, replace label title(Change in Device at Home Days before Policy Intervention: Sample Sensitivity) noobs s(N r2_a zipFE countydayFE sample cluster, label("N" "Adj. R-squared" "Zip-code FE" "County-Day FE" "Sample" "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_20day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_20day exposure_total_scaled *0.any_exposure_binary 1.any_exposure_binary 0.prepolicy_20day*) order(1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_20day#1.any_exposure_binary)


** Robust: Full time work ratio
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_ftwork_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control' i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish , absorb(city_i#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "Yes"
estadd local countydayFE "No"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_ftwork_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "Yes"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_ftwork_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled i.prepolicy_20day#c.social_capital_county i.prepolicy_20day#c.deaths  i.prepolicy_20day#c.cases `control' c.deaths c.cases c.social_capital_county i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb( state_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "No"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 2_output/table_main_ftwork.rtf, replace label title(Change in Full-Time-Work Ratio 20 Days before Policy Intervention) noobs s(N r2_a zipFE citydayFE countydayFE statedayFE cluster, label("N" "Adj. R-squared" "Zip-code FE" "City-Day FE"  "County-Day FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_20day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_20day exposure_total_scaled social_capital_county) order(1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_20day  1.prepolicy_20day#c.social_capital_county  1.prepolicy_20day#c.cases cases 1.prepolicy_20day#c.deaths deaths)



** robustness by days
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_10day c.exposure_total_scaled i.prepolicy_10day#c.exposure_total_scaled  `control'  i.prepolicy_10day#c.demo_asian i.prepolicy_10day#c.population_log i.prepolicy_10day#c.establishment_log i.prepolicy_10day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "10 Days"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "20 Days"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "30 Days"
esttab using 2_output/table_main_day.rtf, replace label title(Change in Device at Home Days before Policy Intervention: Days Sensitivity) noobs s(N r2_a countydayFE sample cluster, label("N" "Adj. R-squared" "County-Day FE" "Period Before Policy" "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_10day* 0.prepolicy_20day* 0.prepolicy_30day* demo_asian population_log establishment_log teleworkable_emp_establish 1.prepolicy_10day 1.prepolicy_20day 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_10day#c.exposure_total_scaled  1.prepolicy_20day#c.exposure_total_scaled  1.prepolicy_30day#c.exposure_total_scaled )

