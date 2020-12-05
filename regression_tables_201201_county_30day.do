**********************************
* Corporate Citizen
* Regression Tables
* Last updated 12/01/2020
**********************************

set more off, permanently
clear all

global directory "/shared/share_lisa-he/county"
cd "$directory"



use county_analysis_clean, clear

******************* Clean data *********************
** keep pre
keep if date_policy_t<0

******************* Regression *********************
** main table
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control' i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled i.prepolicy_30day#c.social_capital_county i.prepolicy_30day#c.deaths  i.prepolicy_30day#c.cases `control' c.deaths c.cases c.social_capital_county i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 201201_30day/table_main.rtf, replace label title(Change in Stay-at-Home Ratio 20 Days before Policy Intervention) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day social_capital_county exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day  1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)
** only for this table I include below the same output but in latex format
esttab using 201201_30day/table_main.tex, replace label title(Change in Stay-at-Home Ratio 20 Days before Policy Intervention) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day social_capital_county exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day  1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)

******************* Robustness *********************
** Robust A: Full time work ratio
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_ftwork_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control' i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish , absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_ftwork_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled i.prepolicy_30day#c.social_capital_county i.prepolicy_30day#c.deaths  i.prepolicy_30day#c.cases `control' c.deaths c.cases c.social_capital_county i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 201201_30day/table_robust_ftwork.rtf, replace label title(Robustness: Full-Time Work Ratio) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish social_capital_county 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day 1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)
esttab using 201201_30day/table_robust_ftwork.tex, replace label title(Robustness: Full-Time Work Ratio) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish social_capital_county 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day 1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)

** Robust B: Employment-weighted exposure
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if exposure_firm_employee_w_infoemp>0.1 | any_exposure_binary==0, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample ">10%"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if exposure_firm_employee_w_infoemp<=0.1 | any_exposure_binary==0, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample "<=10%"
estadd local cluster "State"
esttab using 201201_30day/table_robust_employeeweight.rtf, replace label title(Robustness: Weight by Employees) noobs s(N r2_a sample  countyFE  statedayFE  cluster, label("N" "Adj. R-squared"   "Exposure Employee-Weight" "County FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled)
esttab using 201201_30day/table_robust_employeeweight.tex, replace label title(Robustness: Weight by Employees) noobs s(N r2_a sample  countyFE  statedayFE  cluster, label("N" "Adj. R-squared"   "Exposure Employee-Weight" "County FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled)

** Robust C: Placebo
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui  reghdfe device_home_ratio i.prepolicy_30day c.placebo_exposure_total_scaled i.prepolicy_30day#c.placebo_exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if  placebo_ratio>0.8 | no_any_exposure==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample "Low"
estadd local cluster "State"
eststo: qui  reghdfe device_home_ratio i.prepolicy_30day i.placebo_exposure_binary i.prepolicy_30day#i.placebo_exposure_binary  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if  placebo_ratio>0.8 | no_any_exposure==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample "Low"
estadd local cluster "State"
eststo: qui  reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if  placebo_ratio<=0.8 | no_any_exposure==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample "High"
estadd local cluster "State"
eststo: qui  reghdfe device_home_ratio i.prepolicy_30day i.any_exposure_binary i.prepolicy_30day#i.any_exposure_binary  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if  placebo_ratio<=0.8 | no_any_exposure==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local sample "High"
estadd local cluster "State"
esttab using 201201_30day/table_robust_placebo.rtf, replace label title(Robustness: Placebo) noobs s(N r2_a sample countyFE  statedayFE  cluster, label("N" "Adj. R-squared" "China-Italy Ratio"  "County FE"  "State-Day FE"   "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled placebo_exposure_total_scaled *0.any_exposure_binary 1.any_exposure_binary  *0.placebo_exposure_binary 1.placebo_exposure_binary 0.prepolicy_30day*) order( 1.prepolicy_30day#c.placebo_exposure_total_scaled  1.prepolicy_30day#1.placebo_exposure_binary 1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day#1.any_exposure_binary )
esttab using 201201_30day/table_robust_placebo.tex, replace label title(Robustness: Placebo) noobs s(N r2_a sample countyFE  statedayFE  cluster, label("N" "Adj. R-squared" "China-Italy Ratio"  "County FE"  "State-Day FE"   "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled placebo_exposure_total_scaled *0.any_exposure_binary 1.any_exposure_binary  *0.placebo_exposure_binary 1.placebo_exposure_binary 0.prepolicy_30day*) order( 1.prepolicy_30day#c.placebo_exposure_total_scaled  1.prepolicy_30day#1.placebo_exposure_binary 1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day#1.any_exposure_binary )

******************* Cross Sectional *********************
** Cross sectional A: Trust
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if social_capital_split2==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Low Social Capital"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if social_capital_split2==2, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "High Social Capital"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if any_exposure_binary==0 | boardex_exposure_fraction_split3==1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Low BoardEx Fraction"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if any_exposure_binary==0 | boardex_exposure_fraction_split3>1, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "High BoardEx Fraction"
esttab using 201201_30day/table_cross_trust.rtf, replace label title(Cross Sectional: Trust) noobs s(N r2_a  sample countyFE  statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"   "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day exposure_total_scaled)
esttab using 201201_30day/table_cross_trust.tex, replace label title(Cross Sectional: Trust) noobs s(N r2_a  sample countyFE  statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"   "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day exposure_total_scaled)


** Cross sectional B: Political Affiliation
local control demo_asian population_log establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio  i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control' i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish  if party_rep==1  & Population>10000 & establishment>3, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Republican County"
eststo: qui reghdfe device_home_ratio  i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control' i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish  if party_dem==1  & Population>10000 & establishment>3, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Democratic County"
esttab using 201201_30day/table_cross_party.rtf, replace label title(Cross Sectional: Political Affiliation) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled)
esttab using 201201_30day/table_cross_party.tex, replace label title(Cross Sectional: Political Affiliation) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled)


** Cross sectional C: Teleworkability
*sum teleworkable_emp_establish, detail
/*
25%     .2922009
50%     .3314477  
75%     .3767018 
90%     .4381243
*/
** table cross section: telework
local control demo_asian population_log establishment_log 
eststo clear
eststo: qui reghdfe device_home_ratio  c.exposure_total_scaled   `control'  if prepolicy_30day==1 , absorb(state_fips#date) vce(cluster state_fips)
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "All"
eststo: qui reghdfe device_home_ratio  c.exposure_total_scaled   `control'  if prepolicy_30day==1 & teleworkable_emp_establish>0.29 & !missing(teleworkable_emp_establish), absorb(state_fips#date) vce(cluster state_fips)
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "25%"
eststo: qui reghdfe device_home_ratio  c.exposure_total_scaled   `control'  if prepolicy_30day==1 & teleworkable_emp_establish>0.33 & !missing(teleworkable_emp_establish), absorb(state_fips#date) vce(cluster state_fips)
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "50%"
eststo: qui reghdfe device_home_ratio  c.exposure_total_scaled   `control'  if prepolicy_30day==1 & teleworkable_emp_establish>0.38 & !missing(teleworkable_emp_establish), absorb(state_fips#date) vce(cluster state_fips)
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "75%"
esttab using 201201_30day/table_cross_telework.rtf, replace label title(Cross Sectional: Teleworkability) noobs s(N r2_a sample statedayFE  cluster, label("N" "Adj. R-squared" "Teleworkability" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons ) order(exposure_total_scaled)
esttab using 201201_30day/table_cross_telework.tex, replace label title(Cross Sectional: Teleworkability) noobs s(N r2_a sample statedayFE  cluster, label("N" "Adj. R-squared" "Teleworkability" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons ) order(exposure_total_scaled)


******************* Appendix *********************
** Robustness by days
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_10day c.exposure_total_scaled i.prepolicy_10day#c.exposure_total_scaled  `control'  i.prepolicy_10day#c.demo_asian i.prepolicy_10day#c.population_log i.prepolicy_10day#c.establishment_log i.prepolicy_10day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "10 Days"
estadd local control "Yes"
eststo: qui reghdfe device_home_ratio i.prepolicy_20day c.exposure_total_scaled i.prepolicy_20day#c.exposure_total_scaled  `control'  i.prepolicy_20day#c.demo_asian i.prepolicy_20day#c.population_log i.prepolicy_20day#c.establishment_log i.prepolicy_20day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "20 Days"
estadd local control "Yes"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "30 Days"
estadd local control "Yes"
eststo: qui reghdfe device_home_ratio i.prepolicy_40day c.exposure_total_scaled i.prepolicy_40day#c.exposure_total_scaled  `control'  i.prepolicy_40day#c.demo_asian i.prepolicy_40day#c.population_log i.prepolicy_40day#c.establishment_log i.prepolicy_40day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "40 Days"
estadd local control "Yes"
esttab using 201201_30day/table_appendix_day.rtf, replace label title(Robustness: Days Sensitivity) noobs s(N r2_a sample control countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Period Before Policy" "Interacted Control" "County FE"  "State-Day FE" "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) keep(1.prepolicy_10day#c.exposure_total_scaled 1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_40day#c.exposure_total_scaled )
esttab using 201201_30day/table_appendix_day.tex, replace label title(Robustness: Days Sensitivity) noobs s(N r2_a sample control countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Period Before Policy" "Interacted Control" "County FE"  "State-Day FE" "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) keep(1.prepolicy_10day#c.exposure_total_scaled 1.prepolicy_20day#c.exposure_total_scaled 1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_40day#c.exposure_total_scaled )



** Robustness by sample
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if Population>5000 & establishment>5, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>5000 Est>5"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if Population>10000 & establishment>5, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>10000 Est>5"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_scaled i.prepolicy_30day#c.exposure_total_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if Population>10000 & establishment>7, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>10000 Est>7"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day i.any_exposure_binary i.prepolicy_30day#i.any_exposure_binary  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish if Population>5000 & establishment>5, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Pop>5000 Est>5"
esttab using 201201_30day/table_appendix_limitpop.rtf, replace label title(Robustness: Sample Sensitivity) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled *0.any_exposure_binary 1.any_exposure_binary 0.prepolicy_30day*) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day#1.any_exposure_binary)
esttab using 201201_30day/table_appendix_limitpop.tex, replace label title(Robustness: Sample Sensitivity) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_scaled *0.any_exposure_binary 1.any_exposure_binary 0.prepolicy_30day*) order(1.prepolicy_30day#c.exposure_total_scaled 1.prepolicy_30day#1.any_exposure_binary)


** Robustness by country
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_china_scaled i.prepolicy_30day#c.exposure_total_china_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish , absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "China"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day i.china_exposure_binary i.prepolicy_30day#i.china_exposure_binary  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish , absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "China"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day c.exposure_total_italy_scaled i.prepolicy_30day#c.exposure_total_italy_scaled  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish , absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Italy"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day i.italy_exposure_binary i.prepolicy_30day#i.italy_exposure_binary  `control'  i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish , absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
estadd local sample "Italy"
esttab using 201201_30day/table_appendix_country.rtf, replace label title(Robustness: Country Sensitivity) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_china_scaled exposure_total_italy_scaled *0.china_exposure_binary 1.china_exposure_binary  *0.italy_exposure_binary 1.italy_exposure_binary 0.prepolicy_30day*) order(1.prepolicy_30day#c.exposure_total_china_scaled 1.prepolicy_30day#1.china_exposure_binary 1.prepolicy_30day#c.exposure_total_italy_scaled  1.prepolicy_30day#1.italy_exposure_binary)
esttab using 201201_30day/table_appendix_country.tex, replace label title(Robustness: Country Sensitivity) noobs s(N r2_a sample countyFE statedayFE  cluster, label("N" "Adj. R-squared" "Sample" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day exposure_total_china_scaled exposure_total_italy_scaled *0.china_exposure_binary 1.china_exposure_binary  *0.italy_exposure_binary 1.italy_exposure_binary 0.prepolicy_30day*) order(1.prepolicy_30day#c.exposure_total_china_scaled 1.prepolicy_30day#1.china_exposure_binary 1.prepolicy_30day#c.exposure_total_italy_scaled  1.prepolicy_30day#1.italy_exposure_binary)

** Robustness by binary variable
local control demo_asian population_log  establishment_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prepolicy_30day i.any_exposure_binary i.prepolicy_30day#i.any_exposure_binary  `control' i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prepolicy_30day i.any_exposure_binary i.prepolicy_30day#i.any_exposure_binary i.prepolicy_30day#c.social_capital_county i.prepolicy_30day#c.deaths  i.prepolicy_30day#c.cases `control' c.deaths c.cases c.social_capital_county i.prepolicy_30day#c.demo_asian i.prepolicy_30day#c.population_log i.prepolicy_30day#c.establishment_log i.prepolicy_30day#c.teleworkable_emp_establish, absorb(state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 201201_30day/table_appendix_binary.rtf, replace label title(Robustness: Binary Exposure Variable) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day social_capital_county *0.any_exposure_binary 1.any_exposure_binary) order(1.prepolicy_30day#1.any_exposure_binary 1.prepolicy_30day  1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)
esttab using 201201_30day/table_appendix_binary.tex, replace label title(Robustness: Binary Exposure Variable) noobs s(N r2_a countyFE statedayFE cluster, label("N" "Adj. R-squared" "County FE" "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prepolicy_30day* demo_asian population_log  establishment_log teleworkable_emp_establish 1.prepolicy_30day social_capital_county *0.any_exposure_binary 1.any_exposure_binary) order(1.prepolicy_30day#1.any_exposure_binary 1.prepolicy_30day  1.prepolicy_30day#c.social_capital_county  1.prepolicy_30day#c.cases cases 1.prepolicy_30day#c.deaths deaths)
