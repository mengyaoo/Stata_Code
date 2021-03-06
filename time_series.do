************time series********************
set more off, permanently
clear all
global directory "~"
use GME_data.dta, clear

generate time = date(date,"YMD")
format time %td
tsset time

arima close if time<=(td(01jan2021)), arima(1,1,0) 
predict predclose_a, dynamic(td(04jan2021))
list close predclose_a if t >= td(04jan2021) & t < td(09jan2021)

arima close if time<=(td(01jan2021)), arima(0,1,1)
predict predclose_b, dynamic(td(04jan2021)) 
list predclose_b if t >= td(04jan2021) & t < td(09jan2021)

arima close if time<=(td(01jan2021)), arima(1,1,1) 
predict predclose_c, dynamic(td(04jan2021)) 
list predclose_c if t >= td(04jan2021) & t < td(09jan2021)

arch close if time<=(td(01jan2021)), arch(1) 
predict predclose_d, dynamic(td(04jan2021)) 
list predclose_d if t >= td(04jan2021) & t < td(09jan2021)

list time D.close predclose_a predclose_b predclose_c if t >= td(04jan2021) & t < td(09jan2021)
list close predclose_d if t >= td(04jan2021) & t < td(09jan2021)

* calculate MSE
gen sqerr_a = (predclose_a-D.close)^2 if t > td(04jan2021) & t < td(09jan2021)
mean sqerr_a

gen sqerr_b = (predclose_b-D.close)^2 if t > td(04jan2021) & t < td(09jan2021)
mean sqerr_b

gen sqerr_c = (predclose_c-D.close)^2 if t > td(04jan2021) & t < td(09jan2021)
mean sqerr_c

gen sqerr_d = (predclose_d-close)^2 if t >= td(04jan2021) & t < td(09jan2021)
mean sqerr_d

