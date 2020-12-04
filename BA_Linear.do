set more off, permanently
clear all

global directory "~"
cd "$directory"

use training_data.csv, clear

eststo clear
eststo: qui reghdfe DEM c.Registerd c.'% age 45-54' c.'% age 55-64' c.'% age 65 or older' c.'Median age ' c.'% Bachelor's' c.'% HS diploma' c.'% less than HS diploma' c.'% post grad' c.'% college' c.'Average HH size' c.'Median gross rent' c.'Median value of an owner-occupied home' c.'Median HH income' c.'Median owner cost burden' c.'Median renter cost burden' c.'% Asian' c.'% Black' c.'% Hispanic' c.'% White', absorb(county_name) vce(cluster State)
estadd local countyFE "Yes"
estadd local cluster "State"
