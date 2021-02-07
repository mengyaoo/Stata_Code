set more off, permanently
clear all

global directory "~"
cd "$directory"

use training_data.csv, clear

eststo clear
eststo: qui reghdfe DEM c.'% age 45-54' c.'% age 55-64' c.'% age 65 or older' c.'Median age ' c.'% Bachelor's' c.'% HS diploma' c.'% less than HS diploma' c.'% post grad' c.'% college' c.'Average HH size' c.'Median gross rent' c.'Median value of an owner-occupied home' c.'Median HH income' c.'Median owner cost burden' c.'Median renter cost burden' c.'% Asian' c.'% Black' c.'% Hispanic' c.'% White', absorb(county_name) vce(cluster State)
estadd local countyFE "Yes"
estadd local cluster "State"


************time series********************
set more off, permanently
clear all
global directory "~"
use GME_data.dta, clear

generate time = date(date,"YMD")
format time %td
tsset time

arima close if time<=(td(01jan2021)), arima(1,1,0) noconstant
predict predclose_a, dynamic(td(04jan2021))
list close predclose_a if t > td(01jan2021)


arima close if time<=(td(01jan2021)), arima(0,1,1) noconstant
predict predclose_b, dynamic(td(04jan2021)) 
list predclose_b if t > td(01jan2021)

arima close if time<=(td(01jan2021)), arima(0,1,0) noconstant
predict predclose_c, dynamic(td(04jan2021)) 
list predclose_c if t > td(01jan2021)

arch close if time<=(td(01jan2021)), arch(1)
predict predclose_d, dynamic(td(04jan2021)) 
list predclose_d if t > td(01jan2021)

list time close predclose_a predclose_b predclose_c predclose_d if t > td(01jan2021)


