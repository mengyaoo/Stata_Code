set more off
clear
use "/Users/seyhanerden/Documents/COLUMBIA ECONOMETRICS OF TIME SERIES/Problem Sets Spring 2021 ONLINE/Problem Set #3 - Spring 2021/GME data.dta"

generate time=date(date,"YMD")
tsset time,d

*Running forecasting models to forecast Jan closing price for Game Stop stocks

arima close if time<=(td(01jan2021)), arima(1,1,0) nolog
estimates store arima_110

arima close if time<=(td(01jan2021)), arima(0,1,1) nolog noconstant
estimates store arima_011

arima close if time<=(td(01jan2021)), arima(1,1,1) nolog
estimates store arima_111

arch close if time<=(td(01jan2021)), arch(1) nolog 
estimates store arch_1


*Forecasting Jan 4th to Jan 8th closing price for Game Stop 

forecast create GME, replace
forecast estimates arima_110, names(close_arima_110, replace) 
forecast estimates arima_011, names(close_arima_011, replace)
forecast estimates arima_111, names(close_arima_111, replace)
forecast estimates arch_1, names(close_arch_1, replace)
forecast solve, begin(td(04jan2021)) end(td(08jan2021)) prefix(f_)

list time D.close f_close_arima* if t >= td(05jan2021) & t <= td(08jan2021)
list time close f_close_arch_1 if t >= td(05jan2021) & t < td(06jan2021)


forecast clear 


