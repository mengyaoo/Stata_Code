version 13
clear all

capture log close

set more off

//Limin Fang, Nov 12, 2021. This file includes all reduced-form analysis tables in the Online Appendix. Tables 1, 2 and 7. 

/***********************************************************************************
************ Online Appendix Section II: Forecast Restaurant Total Revenue *********
************************************************************************************/
//Tables 1 and 2 in online appendix.


//---------------Quarterly data 

use 2018_37full_serv_mixbev_Yelp_review_counts.dta, clear

keep if on_Yelp == 1

di _N
//547,619

order uid_rest_gl stata_ym year month

xtset uid_rest_gl stata_ym

//---generate quarterly indicator

gen quarter = 1 if month == 1 | month == 2 | month == 3

order uid_rest_gl stata_ym year month quarter

replace quarter = 2 if missing(quarter) & month == 4 | missing(quarter) & month == 5 | missing(quarter) & month == 6

replace quarter = 3 if missing(quarter) & month == 7 | missing(quarter) & month == 8 | missing(quarter) & month == 9

replace quarter = 4 if missing(quarter) & month == 10 | missing(quarter) & month == 11 | missing(quarter) & month == 12

sort uid_rest_gl year quarter

by uid_rest_gl year quarter: egen nobs_quarter = count(month)

order uid_rest_gl stata_ym year month quarter nobs_quarter

keep uid_rest_gl stata_ym year month quarter nobs_quarter grs_rcpts_adj  num_review logYelpIn zip_income log_vis_spend zip_density zip_pt* new_cat_code cat_dum2 cat_dum3 cat_dum4 cat_dum5 google_rating new_price_num

by uid_rest_gl year quarter: egen quarterly_rev_al = total(grs_rcpts_adj)

by uid_rest_gl year quarter: egen quarterly_num_review = total(num_review)

//capture drop qutrly_logYelpIn

by uid_rest_gl year quarter: egen qutrly_logYelpIn = mean(logYelpIn)

by uid_rest_gl year quarter: egen qutrly_zip_income = mean(zip_income)

by uid_rest_gl year quarter: egen qutrly_log_vis_spend = mean(log_vis_spend)

by uid_rest_gl year quarter: egen qutrly_zip_density = mean(zip_density)

by uid_rest_gl year quarter: egen qutrly_zip_pt15_34 = mean(zip_pt15_34)

by uid_rest_gl year quarter: egen qutrly_zip_pt35_64 = mean(zip_pt35_64)

by uid_rest_gl year quarter: egen qutrly_zip_pt65up = mean(zip_pt65up)

by uid_rest_gl year quarter: egen qutrly_zip_pt_hispop = mean(zip_pt_hispop)

by uid_rest_gl year quarter: egen qutrly_zip_pt_white = mean(zip_pt_white)

by uid_rest_gl year quarter: egen qutrly_zip_pt_black = mean(zip_pt_black)

by uid_rest_gl year quarter: egen qutrly_zip_pt_asian = mean(zip_pt_asian)

drop grs_rcpts_adj  num_review logYelpIn zip_income log_vis_spend zip_density zip_pt*

drop month

gen yearquarter = year*10+quarter 

order uid_rest_gl stata_ym year quarter yearquarter 

drop stata_ym

duplicates drop 

di _N
//184481

count if quarterly_num_review == 0
//105,808

drop if quarterly_num_review == 0

di _N
//78,673

gen log_num_review = log(quarterly_num_review)

su quarterly_rev_al, de

gen lg_grs_rcpts_adj = log(quarterly_rev_al+1)

gen qutrly_logYelpIn_2 =  qutrly_logYelpIn^2

gen qutrly_logYelpIn_3 =  qutrly_logYelpIn^3

gen qutrly_logYelpIn_4 =  qutrly_logYelpIn^4

gen qutrly_logYelpIn_5 =  qutrly_logYelpIn^5

codebook uid_rest_gl
//5507

gen log_price = log(new_price_num)

regress log_price google_rating
//0.13

su qutrly_zip_income

gen log_income = log(qutrly_zip_income)

regress log_income  google_rating
//0.06

gen dependent_k = log_num_review - lg_grs_rcpts_adj + log_income 

//--------------------------------------------Use these Fixed effects as alcohol ratios

reghdfe dependent_k qutrly_logYelpIn qutrly_logYelpIn_2 qutrly_logYelpIn_3 qutrly_logYelpIn_4 qutrly_logYelpIn_5 qutrly_zip_income, absorb(FE = uid_rest_gl yearquarter) vce(cl uid_rest_gl )

keep uid_rest_gl FE

duplicates drop 

di _N
//5508

drop if missing(FE)

di _N
//5214

su FE

save total_rev_to_alcohol_sales_ratio.dta, replace //This dataset is used to forecast the ratio for other restaurants and for forecasting demand. 

tab nobs_quarter

drop if nobs_quarter < 3 //drop restaurants that lasted less than 3 quarters

codebook uid_rest_gl
//5,438

eststo clear

eststo: reghdfe log_num_review lg_grs_rcpts_adj qutrly_logYelpIn qutrly_logYelpIn_2 qutrly_logYelpIn_3 qutrly_logYelpIn_4 qutrly_logYelpIn_5 log_income, absorb(uid_rest_gl yearquarter) vce(cl uid_rest_gl )

testnl _b[lg_grs_rcpts_adj]/(-_b[log_income]) = 1
// chi2(1) =        3.13
// Prob > chi2 =        0.0770

esttab using "/Users/fanglimi/Dropbox/JMP/Writing/Alcohol_representation_of_demand_raw_quarterly.tex", starlevels(* 0.10 ** 0.05 *** 0.01) varwidth(25) se replace 
//this table produces Column 2 in Table 1 of the online appendix. 

//-----------------------Spline regression using quarterly data

//--------Discretization. 

su lg_grs_rcpts_adj, de
//  9.858813 , 10.96491 , 11.73498 

gen lg_grs_rcpts_adj_grp1 = lg_grs_rcpts_adj if lg_grs_rcpts_adj <= 9.858813

replace lg_grs_rcpts_adj_grp1 = 0 if missing(lg_grs_rcpts_adj_grp1)

gen dum_grp1 = 1 if lg_grs_rcpts_adj <= 9.858813

replace dum_grp1 = 0 if missing(dum_grp1)

gen lg_grs_rcpts_adj_grp2 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 9.858813 & lg_grs_rcpts_adj <= 10.96491

replace lg_grs_rcpts_adj_grp2 = 0 if missing(lg_grs_rcpts_adj_grp2)

gen dum_grp2 = 1 if lg_grs_rcpts_adj > 9.858813 & lg_grs_rcpts_adj <= 10.96491

replace dum_grp2 = 0 if missing(dum_grp2)

gen lg_grs_rcpts_adj_grp3 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 10.96491 & lg_grs_rcpts_adj <= 11.73498

replace lg_grs_rcpts_adj_grp3 = 0 if missing(lg_grs_rcpts_adj_grp3)

gen dum_grp3 = 1 if lg_grs_rcpts_adj > 10.96491 & lg_grs_rcpts_adj <= 11.73498

replace dum_grp3 = 0 if missing(dum_grp3)

gen lg_grs_rcpts_adj_grp4 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 11.73498

replace lg_grs_rcpts_adj_grp4 = 0 if missing(lg_grs_rcpts_adj_grp4)

gen dum_grp4 = 1 if lg_grs_rcpts_adj > 11.73498

replace dum_grp4 = 0 if missing(dum_grp4)


//----------spline regression

gen var1 = lg_grs_rcpts_adj*dum_grp1 + 9.858813*(1-dum_grp1)

gen var2 = (lg_grs_rcpts_adj - 9.858813)*dum_grp2 + (10.94739 - 9.858813)*(dum_grp3 + dum_grp4)

gen var3 = (lg_grs_rcpts_adj - 10.96491)*dum_grp3 + (11.73498 - 10.96491)*dum_grp4

gen var4 = (lg_grs_rcpts_adj - 11.73498)*dum_grp4


eststo clear

eststo: reghdfe log_num_review var1 var2 var3 var4 qutrly_logYelpIn qutrly_logYelpIn_2 qutrly_logYelpIn_3 qutrly_logYelpIn_4 qutrly_logYelpIn_5 log_income, absorb(uid_rest_gl yearquarter) vce(cl uid_rest_gl )

testnl _b[var1]/(-_b[log_income]) = 1
//                 chi2(1) =       77.04
//           Prob > chi2 =        0.0000

testnl _b[var2]/(-_b[log_income]) = 1
//      chi2(1) =        0.72
//           Prob > chi2 =        0.3961

testnl _b[var3]/(-_b[log_income]) = 1
//               chi2(1) =        1.60
//           Prob > chi2 =        0.2060


testnl _b[var4]/(-_b[log_income]) = 1
//                  chi2(1) =        1.96
//           Prob > chi2 =        0.1616

esttab using "/Users/fanglimi/Dropbox/JMP/Writing/Alcohol_representation_of_demand_discrete_Spline_raw_quarterly.tex", starlevels(* 0.10 ** 0.05 *** 0.01) varwidth(25) se replace
//this table produces Column 2 in Table 2 of the online appendix. 


//----------------------------------------   Monthly Data--------------------------------------

use 2018_37full_serv_mixbev_Yelp_review_counts.dta, clear

keep if on_Yelp == 1

drop if num_review == 0

di _N
//155,693

gen log_num_review = log(num_review)

//su new_price_num

//gen log_price = log(new_price_num)

su zip_income

gen log_income = log(zip_income)

//gen Y = log_num_review - lg_grs_rcpts_adj + log_price

gen logYelpIn_2 =  logYelpIn^2

gen logYelpIn_3 =  logYelpIn^3

gen logYelpIn_4 =  logYelpIn^4

gen logYelpIn_5 =  logYelpIn^5

codebook uid_rest_gl
//5507

gen lg_grs_rcpts_adj_2 = lg_grs_rcpts_adj^2

gen lg_grs_rcpts_adj_3 = lg_grs_rcpts_adj^3

gen lg_grs_rcpts_adj_4 = lg_grs_rcpts_adj^4

gen lg_grs_rcpts_adj_5 = lg_grs_rcpts_adj^5

su lg_grs_rcpts_adj


gen dependent_k = log_num_review - lg_grs_rcpts_adj + log_price 

capture drop FE

reghdfe dependent_k logYelpIn logYelpIn_2 logYelpIn_3 logYelpIn_4 logYelpIn_5, absorb(FE = uid_rest_gl stata_ym) vce(cl uid_rest_gl )

eststo clear

capture drop FE

eststo: reghdfe log_num_review lg_grs_rcpts_adj logYelpIn logYelpIn_2 logYelpIn_3 logYelpIn_4 logYelpIn_5 log_income, absorb(uid_rest_gl  stata_ym) vce(cl uid_rest_gl )

testnl _b[lg_grs_rcpts_adj]/(-_b[log_income]) = 1
//            chi2(1) =        0.00
 //     Prob > chi2 =        0.9928

esttab using "/Users/fanglimi/Dropbox/JMP/Writing/Alcohol_representation_of_demand_raw.tex", starlevels(* 0.10 ** 0.05 *** 0.01) varwidth(25) se replace 
//this table produces Column 1 in Table 1 of the online appendix. 

//------Spline Regression 

//--------Discretization. 

su lg_grs_rcpts_adj, de
//8.929118, 9.966185, 10.76811 
//

gen lg_grs_rcpts_adj_grp1 = lg_grs_rcpts_adj if lg_grs_rcpts_adj <= 8.929118

replace lg_grs_rcpts_adj_grp1 = 0 if missing(lg_grs_rcpts_adj_grp1)

gen dum_grp1 = 1 if lg_grs_rcpts_adj <= 8.929118

replace dum_grp1 = 0 if missing(dum_grp1)

gen lg_grs_rcpts_adj_grp2 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 8.929118 & lg_grs_rcpts_adj <= 9.966185

replace lg_grs_rcpts_adj_grp2 = 0 if missing(lg_grs_rcpts_adj_grp2)

gen dum_grp2 = 1 if lg_grs_rcpts_adj > 8.929118 & lg_grs_rcpts_adj <= 9.966185

replace dum_grp2 = 0 if missing(dum_grp2)

gen lg_grs_rcpts_adj_grp3 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 9.966185 & lg_grs_rcpts_adj <= 10.76811

replace lg_grs_rcpts_adj_grp3 = 0 if missing(lg_grs_rcpts_adj_grp3)

gen dum_grp3 = 1 if lg_grs_rcpts_adj > 9.966185 & lg_grs_rcpts_adj <= 10.76811

replace dum_grp3 = 0 if missing(dum_grp3)

gen lg_grs_rcpts_adj_grp4 = lg_grs_rcpts_adj if lg_grs_rcpts_adj > 10.76811

replace lg_grs_rcpts_adj_grp4 = 0 if missing(lg_grs_rcpts_adj_grp4)

gen dum_grp4 = 1 if lg_grs_rcpts_adj > 10.76811

replace dum_grp4 = 0 if missing(dum_grp4)

//----------spline regression

gen var1 = lg_grs_rcpts_adj*dum_grp1 + 8.929118*(1-dum_grp1)

gen var2 = (lg_grs_rcpts_adj - 8.929118)*dum_grp2 + (9.966185 - 8.929118)*(dum_grp3 + dum_grp4)

gen var3 = (lg_grs_rcpts_adj - 9.966185)*dum_grp3 + (10.76811 - 9.966185)*dum_grp4

gen var4 = (lg_grs_rcpts_adj - 10.76811)*dum_grp4

eststo clear

eststo: reghdfe log_num_review var1 var2 var3 var4 logYelpIn logYelpIn_2 logYelpIn_3 logYelpIn_4 logYelpIn_5 log_income, absorb(uid_rest_gl stata_ym) vce(cl uid_rest_gl )

testnl _b[var1]/(-_b[log_income]) = 1
//  chi2(1) =       30.57
//           Prob > chi2 =        0.0000


testnl _b[var2]/(-_b[log_income]) = 1
//                 chi2(1) =        0.72
//           Prob > chi2 =        0.3975

testnl _b[var3]/(-_b[log_income]) = 1
//                 chi2(1) =        0.93
//           Prob > chi2 =        0.3342

testnl _b[var4]/(-_b[log_income]) = 1
//                     chi2(1) =        1.13
//           Prob > chi2 =        0.2876

esttab using "/Users/fanglimi/Dropbox/JMP/Writing/Alcohol_representation_of_demand_discrete_Spline_raw.tex", starlevels(* 0.10 ** 0.05 *** 0.01) varwidth(25) se replace
//this table produces Column 1 in Table 2 of the online appendix. 

pctile pct = lg_grs_rcpts_adj, nq(20)

tab pct

/*
percentiles |
         of |
lg_grs_rcpt |
      s_adj |      Freq.     Percent        Cum.
------------+-----------------------------------
   6.828808 |          1        5.26        5.26
   7.561174 |          1        5.26       10.53
   8.123296 |          1        5.26       15.79
   8.565923 |          1        5.26       21.05
   8.929118 |          1        5.26       26.32
   9.203659 |          1        5.26       31.58
   9.432283 |          1        5.26       36.84
   9.633152 |          1        5.26       42.11
   9.810296 |          1        5.26       47.37
   9.966185 |          1        5.26       52.63
   10.11852 |          1        5.26       57.89
   10.27409 |          1        5.26       63.16
   10.43159 |          1        5.26       68.42
   10.59432 |          1        5.26       73.68
   10.76811 |          1        5.26       78.95
   10.94731 |          1        5.26       84.21
   11.13279 |          1        5.26       89.47
   11.34687 |          1        5.26       94.74
   11.63178 |          1        5.26      100.00
------------+-----------------------------------
      Total |         19      100.00
*/

//9.203659 10.27409 11.34687 11.63178


//--------------Forecast Revenues for All Restaurants in Dataset.

//Forecast uses rating information, so I predict google ratings for all restaurants in the dataset, including those that are not listed online. 

//---Forecast Google ratings

use 2018_37full_serv_mixbev_Yelp_review_counts.dta, clear

keep uid_rest_gl google_rating Yelp_Nov2016_rating TripAd_2018_Jun_Rating

duplicates drop 

di _N
//15,417

//---Forecast based on Yelp_ratings for restaurants that have Yelp ratings but not Google

reg google_rating Yelp_Nov2016_rating 

predict google_rating_pred_Ylp

count if !missing(google_rating_pred_Ylp)
//5,931

count if !missing(google_rating) & !missing(Yelp_Nov2016_rating) 
//  5,307

//---Forecast based on TripAdvisor ratings for restaurants that have TripAdvisor ratings but not Google

reg google_rating TripAd_2018_Jun_Rating

predict google_rating_pred_Trp

count if !missing(google_rating_pred_Trp)
// 5,204

count if !missing(google_rating) & !missing(TripAd_2018_Jun_Rating) 
// 4,726

gen google_rating_predall = google_rating

replace google_rating_predall = google_rating_pred_Ylp if missing(google_rating_predall)

replace google_rating_predall = google_rating_pred_Trp if missing(google_rating_predall)

count if missing(google_rating_predall)

gen google_rating_predall_filler = google_rating_predall

replace google_rating_predall_filler = 4 if missing(google_rating_predall_filler) 

keep uid_rest_gl google_rating_predall google_rating_predall_filler

label var google_rating_predall "predicted Google ratings for restaurants not listed on Google but on Yelp or TripA"

label var google_rating_predall_filler "predicted Google ratings for all restaurants with 4 as filler for restaurants not listed online"

save google_rating_pred_all.dta, replace


//------------------------------------Now predict FE 

use 2018_37full_serv_mixbev_Yelp_review_counts.dta, clear

merge m:1 uid_rest_gl using total_rev_to_alcohol_sales_ratio.dta

drop _merge

keep uid_rest_gl FE cat_dum2 cat_dum3 cat_dum4 cat_dum5 google_rating zip_income log_vis_spend zip_density zip_pt* 

collapse (mean) FE cat_dum2 cat_dum3 cat_dum4 cat_dum5 google_rating zip_income log_vis_spend zip_density zip_pt*,  by(uid_rest_gl)

di _N
//15417

merg 1:1 uid_rest_gl using google_rating_pred_all.dta

drop _merge 

regress FE  cat_dum2 cat_dum3 cat_dum4 cat_dum5 google_rating_predall_filler zip_income log_vis_spend zip_density zip_pt* if !missing(FE)

count if !missing(FE)

//-----predict FE

capture drop ttl_rev_to_alhl_mltpl_pred

predict ttl_rev_to_alhl_mltpl_pred

count if missing(ttl_rev_to_alhl_mltpl_pred)
//0


keep uid_rest_gl google_rating_predall google_rating_predall_filler cat_dum2 cat_dum3 cat_dum4 cat_dum5 ttl_rev_to_alhl_mltpl_pred 

//---now we need to normalize ttl_rev_to_alhl_mltpl such that ttl_rev_to_alhl_mltpl > 0 because we want the multiplier to be greater than 1

//also collectively cat_dum3 should average to be log(5/3)=0.51, i.e. total revenues to alchol sales ratio is 100/60, or 60% of the total revenue comes from alcohol sales on average 
//max is log(50) = 3.912023, min is log(1.1) = .0953103

su ttl_rev_to_alhl_mltpl_pred
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
ttl_rev_to~d |     15,417     .133268    .7054244  -1.720812   2.634659
*/

//This is good. Use this. 

capture drop adj_ttl_rev_to_alhl_mltpl 

gen adj_ttl_rev_to_alhl_mltpl = ttl_rev_to_alhl_mltpl_pred + 1.720812 + log(1.1) - 0.4

su adj_ttl_rev_to_alhl_mltpl
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
adj_ttl_re~l |     15,417     1.94939    .7054244   .0953103   4.450781
*/

hist adj_ttl_rev_to_alhl_mltpl

count if adj_ttl_rev_to_alhl_mltpl < log(1.1)
//24
count if adj_ttl_rev_to_alhl_mltpl < log(1.1) & missing(google_rating_predall)
//0

//--do a cut off

replace adj_ttl_rev_to_alhl_mltpl  = log(1.1) if adj_ttl_rev_to_alhl_mltpl < log(1.1)

su adj_ttl_rev_to_alhl_mltpl, de
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
adj_ttl_re~l |     15,417     1.54964    .7048632   .0953102   4.050781

*/

di 1/exp(4.050781)
//1.7%, that's fine, I think.

count if adj_ttl_rev_to_alhl_mltpl > log(50)
//2

replace adj_ttl_rev_to_alhl_mltpl  = log(50) if adj_ttl_rev_to_alhl_mltpl  > log(50)

su adj_ttl_rev_to_alhl_mltpl

regress adj_ttl_rev_to_alhl_mltpl cat_dum2 cat_dum3 cat_dum4 cat_dum5

di 100/exp( 2.534664)
//7.9% -- breakfast, brunch

di 100/exp(2.534664 +.368594)
//5.5% -- Asian

di 100/exp(2.534664-1.561772)
//38% -- bars

di 100/exp(2.534664-0.8589165)
//19% -- tex-mex

di 100/exp(2.534664 -1.006251)
//22% -- European

//mean absolute
di 100/exp(1.54964)
//21%

hist adj_ttl_rev_to_alhl_mltpl


keep uid_rest_gl google_rating_predall google_rating_predall_filler adj_ttl_rev_to_alhl_mltpl

save total_rev_to_alcohol_sales_ratio_all_restaurants.dta, replace

//---------------------------------------------------Now construct total revenue data. 

use 2018_37full_serv_mixbev_Yelp_review_counts.dta, clear

merge m:1 uid_rest_gl using total_rev_to_alcohol_sales_ratio_all_restaurants.dta

drop _merge

gen exp_ttl_rev_to_alhl_mltpl = exp(adj_ttl_rev_to_alhl_mltpl)

su exp_ttl_rev_to_alhl_mltpl, de

gen ttl_rev = grs_rcpts_adj*exp_ttl_rev_to_alhl_mltpl

su ttl_rev
//This revenue is used in structural analysis. 



/***************************************************************************
*********** Table 7 Efects of Yelp by Restaurant Age and Location **********
****************************************************************************/

clear all 

eststo clear

use 2018_37full_serv_mixbev_Yelp_review_counts_forecastRev.dta, clear

label var lg_grs_rcpts_adj "Log Revenue"

drop IHWY_1K

rename HWY_500 IHWY_1K

drop logYelpIn logYelp_chain

gen logYelpIn = log(Yelp_rvw_p_res_cnty+0.04)

gen logYelpIn_indp = logYelpIn*(1-chain_ind)

gen logYelp_chain = logYelpIn*chain_ind


//------------------------google rating

gen logYelpIn_rating = logYelpIn_indp*google_rating

gen logYelpIn_chain_rating = logYelp_chain*google_rating

//----age break down

gen age_36 = 1 if age <= 36 

replace age_36 = 0 if missing(age_36)

gen age_36_60 = 1 if age > 36 & age <= 72

replace age_36_60  = 0 if missing(age_36_60)

gen age_60_120 = 1 if age > 72 & age <= 108

replace age_60_120  = 0 if missing(age_60_120)

gen age_over120 = 1 if age > 108 & age <= 144

replace age_over120 = 0 if missing(age_over120)


gen age_over144 = 1 if age > 144

replace age_over144 = 0 if missing(age_over144)


//---HWY

//---interact with age

gen logYelpIn_indp_36H = logYelpIn_indp*age_36*IHWY_1K 

gen logYelpIn_rating_36H = logYelpIn_rating*age_36*IHWY_1K

gen logYelpIn_indp_36_60H = logYelpIn_indp*age_36_60*IHWY_1K  

gen logYelpIn_rating_36_60H = logYelpIn_rating*age_36_60*IHWY_1K

gen logYelpIn_indp_60_120H = logYelpIn_indp*age_60_120*IHWY_1K 

gen logYelpIn_rating_60_120H = logYelpIn_rating*age_60_120*IHWY_1K

gen logYelpIn_indp_120H = logYelpIn_indp*age_over120*IHWY_1K  

gen logYelpIn_rating_120H = logYelpIn_rating*age_over120*IHWY_1K  


gen logYelpIn_indp_144H = logYelpIn_indp*age_over144*IHWY_1K  

gen logYelpIn_rating_144H = logYelpIn_rating*age_over144*IHWY_1K  


//---chain

//before
gen logYelp_chain_36H = logYelp_chain*age_36*IHWY_1K

gen logYelpIn_chain_rating_36H = logYelpIn_chain_rating*age_36*IHWY_1K  

gen logYelp_chain_36_60H = logYelp_chain*age_36_60*IHWY_1K 

gen logYelpIn_chain_rating_36_60H = logYelpIn_chain_rating*age_36_60*IHWY_1K

gen logYelp_chain_60_120H = logYelp_chain*age_60_120*IHWY_1K

gen logYelpIn_chain_rating_60_120H = logYelpIn_chain_rating*age_60_120*IHWY_1K

gen logYelp_chain_120H = logYelp_chain*age_over120*IHWY_1K  

gen logYelpIn_chain_rating_120H = logYelpIn_chain_rating*age_over120*IHWY_1K  

gen logYelp_chain_144H = logYelp_chain*age_over144*IHWY_1K  

gen logYelpIn_chain_rating_144H = logYelpIn_chain_rating*age_over144*IHWY_1K 


//---Non-HWY

//---interact with age

gen logYelpIn_indp_36NH = logYelpIn_indp*age_36*(1-IHWY_1K) 

gen logYelpIn_rating_36NH = logYelpIn_rating*age_36*(1-IHWY_1K)

gen logYelpIn_indp_36_60NH = logYelpIn_indp*age_36_60*(1-IHWY_1K)  

gen logYelpIn_rating_36_60NH = logYelpIn_rating*age_36_60*(1-IHWY_1K)

gen logYelpIn_indp_60_120NH = logYelpIn_indp*age_60_120*(1-IHWY_1K)  

gen logYelpIn_rating_60_120NH = logYelpIn_rating*age_60_120*(1-IHWY_1K)

gen logYelpIn_indp_120NH = logYelpIn_indp*age_over120*(1-IHWY_1K)  

gen logYelpIn_rating_120NH = logYelpIn_rating*age_over120*(1-IHWY_1K)  


gen logYelpIn_indp_144NH = logYelpIn_indp*age_over144*(1-IHWY_1K)  

gen logYelpIn_rating_144NH = logYelpIn_rating*age_over144*(1-IHWY_1K)  

//---chain


//before
gen logYelp_chain_36NH = logYelp_chain*age_36*(1-IHWY_1K)

gen logYelpIn_chain_rating_36NH = logYelpIn_chain_rating*age_36*(1-IHWY_1K)  

gen logYelp_chain_36_60NH = logYelp_chain*age_36_60*(1-IHWY_1K) 

gen logYelpIn_chain_rating_36_60NH = logYelpIn_chain_rating*age_36_60*(1-IHWY_1K)

gen logYelp_chain_60_120NH = logYelp_chain*age_60_120*(1-IHWY_1K)

gen logYelpIn_chain_rating_60_120NH = logYelpIn_chain_rating*age_60_120*(1-IHWY_1K)

gen logYelp_chain_120NH = logYelp_chain*age_over120*(1-IHWY_1K)  

gen logYelpIn_chain_rating_120NH = logYelpIn_chain_rating*age_over120*(1-IHWY_1K)  


gen logYelp_chain_144NH = logYelp_chain*age_over144*(1-IHWY_1K)  

gen logYelpIn_chain_rating_144NH = logYelpIn_chain_rating*age_over144*(1-IHWY_1K)  

label var lg_grs_rcpts_adj "Log Revenue"
label var logYelpIn_indp_36H "I(\textless 3yrs old)$\times\$log(Yelp)"
label var logYelpIn_rating_36H "I(\textless 3yrs old)$\times\$log(Yelp)$\times\$rating"

label var logYelpIn_indp_36_60H "\hline I(3-6yrs old)$\times\$log(Yelp)"
label var logYelpIn_rating_36_60H "I(3-6yrs old)$\times\$log(Yelp)$\times\$rating"

label var logYelpIn_indp_60_120H "\hline I(6-9yrs old)$\times\$log(Yelp)"
label var logYelpIn_rating_60_120H "I(6-9yrs old)$\times\$log(Yelp)$\times\$rating"

label var logYelpIn_indp_120H "\hline I(9-12yrs old)$\times\$log(Yelp)"
label var logYelpIn_rating_120H "I(9-12yrs old)$\times\$log(Yelp)$\times\$rating"

label var logYelpIn_indp_144H "\hline I(\textgreater 12yrs old)$\times\$log(Yelp)"
label var logYelpIn_rating_144H "I(\textgreater 12yrs old)$\times\$log(Yelp)$\times\$rating"

reghdfe lg_grs_rcpts_adj logYelpIn_indp_36H logYelpIn_rating_36H logYelp_chain_36H logYelpIn_chain_rating_36H ///
logYelpIn_indp_36_60H logYelpIn_rating_36_60H logYelp_chain_36_60H logYelpIn_chain_rating_36_60H ///
logYelpIn_indp_60_120H logYelpIn_rating_60_120H logYelp_chain_60_120H logYelpIn_chain_rating_60_120H ///
logYelpIn_indp_120H  logYelpIn_rating_120H  logYelp_chain_120H  logYelpIn_chain_rating_120H ///
logYelpIn_indp_144H  logYelpIn_rating_144H  logYelp_chain_144H  logYelpIn_chain_rating_144H ///
logYelpIn_indp_36NH logYelpIn_rating_36NH logYelp_chain_36NH logYelpIn_chain_rating_36NH ///
logYelpIn_indp_36_60NH logYelpIn_rating_36_60NH logYelp_chain_36_60NH logYelpIn_chain_rating_36_60NH ///
logYelpIn_indp_60_120NH logYelpIn_rating_60_120NH logYelp_chain_60_120NH logYelpIn_chain_rating_60_120NH ///
logYelpIn_indp_120NH logYelpIn_rating_120NH logYelp_chain_120NH logYelpIn_chain_rating_120NH ///
logYelpIn_indp_144NH logYelpIn_rating_144NH logYelp_chain_144NH logYelpIn_chain_rating_144NH ///
weigh_traffic zip_logtlpop zip_income log_vis_spend ///
zip_density zip_pt* zip_indep_rival zip_chain_rival hecklambda ///
if first_same_rest == 1 & last_2mnth ==0  & age > 0 & on_Yelp ==1 & sample_1strvw ==1, ///
absorb(uid_rest_gl#month stata_ym#core_id#chain_ind) vce(cl county)


eststo model1

estadd local erating "\multicolumn{4}{c}{Google Rating} \tabularnewline %"
estadd local controls "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local restFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local restbymonthFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local timeFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local timebychainFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local timebymetroFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"
estadd local timebymetrobychainFE "\multicolumn{4}{c}{\checkmark} \tabularnewline %"

estadd local eN ="\multicolumn{4}{c}{`e(N)'} \tabularnewline %"  
estadd local evce ="\multicolumn{4}{c}{County} \tabularnewline %"  
estadd local eNclust ="\multicolumn{4}{c}{`e(N_clust)'} \tabularnewline %"  


//------one more time

gen elogYelpIn_indp_36H = logYelpIn_indp*age_36*IHWY_1K 

gen elogYelpIn_rating_36H = logYelpIn_rating*age_36*IHWY_1K

gen elogYelpIn_indp_36_60H = logYelpIn_indp*age_36_60*IHWY_1K  

gen elogYelpIn_rating_36_60H = logYelpIn_rating*age_36_60*IHWY_1K

gen elogYelpIn_indp_60_120H = logYelpIn_indp*age_60_120*IHWY_1K 

gen elogYelpIn_rating_60_120H = logYelpIn_rating*age_60_120*IHWY_1K

gen elogYelpIn_indp_120H = logYelpIn_indp*age_over120*IHWY_1K  

gen elogYelpIn_rating_120H = logYelpIn_rating*age_over120*IHWY_1K  

gen elogYelpIn_indp_144H = logYelpIn_indp*age_over144*IHWY_1K  

gen elogYelpIn_rating_144H = logYelpIn_rating*age_over144*IHWY_1K  


//---chain

//before
gen elogYelp_chain_36H = logYelp_chain*age_36*IHWY_1K

gen elogYelpIn_chain_rating_36H = logYelpIn_chain_rating*age_36*IHWY_1K  

gen elogYelp_chain_36_60H = logYelp_chain*age_36_60*IHWY_1K 

gen elogYelpIn_chain_rating_36_60H = logYelpIn_chain_rating*age_36_60*IHWY_1K

gen elogYelp_chain_60_120H = logYelp_chain*age_60_120*IHWY_1K

gen elogYelpIn_chain_rating_60_120H = logYelpIn_chain_rating*age_60_120*IHWY_1K

gen elogYelp_chain_120H = logYelp_chain*age_over120*IHWY_1K  

gen elogYelpIn_chain_rating_120H = logYelpIn_chain_rating*age_over120*IHWY_1K  

gen elogYelp_chain_144H = logYelp_chain*age_over144*IHWY_1K  

gen elogYelpIn_chain_rating_144H = logYelpIn_chain_rating*age_over144*IHWY_1K 


//---Non-HWY

//---interact with age

gen elogYelpIn_indp_36NH = logYelpIn_indp*age_36*(1-IHWY_1K) 

gen elogYelpIn_rating_36NH = logYelpIn_rating*age_36*(1-IHWY_1K)

gen elogYelpIn_indp_36_60NH = logYelpIn_indp*age_36_60*(1-IHWY_1K)  

gen elogYelpIn_rating_36_60NH = logYelpIn_rating*age_36_60*(1-IHWY_1K)

gen elogYelpIn_indp_60_120NH = logYelpIn_indp*age_60_120*(1-IHWY_1K)  

gen elogYelpIn_rating_60_120NH = logYelpIn_rating*age_60_120*(1-IHWY_1K)

gen elogYelpIn_indp_120NH = logYelpIn_indp*age_over120*(1-IHWY_1K)  

gen elogYelpIn_rating_120NH = logYelpIn_rating*age_over120*(1-IHWY_1K)  


gen elogYelpIn_indp_144NH = logYelpIn_indp*age_over144*(1-IHWY_1K)  

gen elogYelpIn_rating_144NH = logYelpIn_rating*age_over144*(1-IHWY_1K)  

//---chain

//before
gen elogYelp_chain_36NH = logYelp_chain*age_36*(1-IHWY_1K)

gen elogYelpIn_chain_rating_36NH = logYelpIn_chain_rating*age_36*(1-IHWY_1K)  

gen elogYelp_chain_36_60NH = logYelp_chain*age_36_60*(1-IHWY_1K) 

gen elogYelpIn_chain_rating_36_60NH = logYelpIn_chain_rating*age_36_60*(1-IHWY_1K)

gen elogYelp_chain_60_120NH = logYelp_chain*age_60_120*(1-IHWY_1K)

gen elogYelpIn_chain_rating_60_120NH = logYelpIn_chain_rating*age_60_120*(1-IHWY_1K)

gen elogYelp_chain_120NH = logYelp_chain*age_over120*(1-IHWY_1K)  

gen elogYelpIn_chain_rating_120NH = logYelpIn_chain_rating*age_over120*(1-IHWY_1K)  


gen elogYelp_chain_144NH = logYelp_chain*age_over144*(1-IHWY_1K)  

gen elogYelpIn_chain_rating_144NH = logYelpIn_chain_rating*age_over144*(1-IHWY_1K)  


reghdfe lg_grs_rcpts_adj elogYelpIn_indp_36H elogYelpIn_rating_36H elogYelp_chain_36H elogYelpIn_chain_rating_36H ///
elogYelpIn_indp_36_60H elogYelpIn_rating_36_60H elogYelp_chain_36_60H elogYelpIn_chain_rating_36_60H ///
elogYelpIn_indp_60_120H elogYelpIn_rating_60_120H elogYelp_chain_60_120H elogYelpIn_chain_rating_60_120H ///
elogYelpIn_indp_120H  elogYelpIn_rating_120H  elogYelp_chain_120H  elogYelpIn_chain_rating_120H ///
elogYelpIn_indp_144H  elogYelpIn_rating_144H  elogYelp_chain_144H  elogYelpIn_chain_rating_144H ///
elogYelpIn_indp_36NH elogYelpIn_rating_36NH elogYelp_chain_36NH elogYelpIn_chain_rating_36NH ///
elogYelpIn_indp_36_60NH elogYelpIn_rating_36_60NH elogYelp_chain_36_60NH elogYelpIn_chain_rating_36_60NH ///
elogYelpIn_indp_60_120NH elogYelpIn_rating_60_120NH elogYelp_chain_60_120NH elogYelpIn_chain_rating_60_120NH ///
elogYelpIn_indp_120NH elogYelpIn_rating_120NH elogYelp_chain_120NH elogYelpIn_chain_rating_120NH ///
elogYelpIn_indp_144NH elogYelpIn_rating_144NH elogYelp_chain_144NH elogYelpIn_chain_rating_144NH ///
weigh_traffic zip_logtlpop zip_income log_vis_spend ///
zip_density zip_pt* zip_indep_rival zip_chain_rival hecklambda ///
if first_same_rest == 1 & last_2mnth ==0  & age > 0 & on_Yelp ==1 & sample_1strvw ==1, ///
absorb(uid_rest_gl uid_rest_gl#month stata_ym stata_ym#chain_ind stata_ym#core_id stata_ym#core_id#chain_ind) vce(cl county)


eststo model2

//----CHAIN column
//---HWY

//---interact with age

gen clogYelpIn_indp_36H = logYelpIn_indp*age_36*IHWY_1K 

gen clogYelpIn_rating_36H = logYelpIn_rating*age_36*IHWY_1K

gen clogYelpIn_indp_36_60H = logYelpIn_indp*age_36_60*IHWY_1K  

gen clogYelpIn_rating_36_60H = logYelpIn_rating*age_36_60*IHWY_1K

gen clogYelpIn_indp_60_120H = logYelpIn_indp*age_60_120*IHWY_1K 

gen clogYelpIn_rating_60_120H = logYelpIn_rating*age_60_120*IHWY_1K

gen clogYelpIn_indp_120H = logYelpIn_indp*age_over120*IHWY_1K  

gen clogYelpIn_rating_120H = logYelpIn_rating*age_over120*IHWY_1K  


gen clogYelpIn_indp_144H = logYelpIn_indp*age_over144*IHWY_1K  

gen clogYelpIn_rating_144H = logYelpIn_rating*age_over144*IHWY_1K  


//---chain

//before
gen clogYelp_chain_36H = logYelp_chain*age_36*IHWY_1K

gen clogYelpIn_chain_rating_36H = logYelpIn_chain_rating*age_36*IHWY_1K  

gen clogYelp_chain_36_60H = logYelp_chain*age_36_60*IHWY_1K 

gen clogYelpIn_chain_rating_36_60H = logYelpIn_chain_rating*age_36_60*IHWY_1K

gen clogYelp_chain_60_120H = logYelp_chain*age_60_120*IHWY_1K

gen clogYelpIn_chain_rating_60_120H = logYelpIn_chain_rating*age_60_120*IHWY_1K

gen clogYelp_chain_120H = logYelp_chain*age_over120*IHWY_1K  

gen clogYelpIn_chain_rating_120H = logYelpIn_chain_rating*age_over120*IHWY_1K  

gen clogYelp_chain_144H = logYelp_chain*age_over144*IHWY_1K  

gen clogYelpIn_chain_rating_144H = logYelpIn_chain_rating*age_over144*IHWY_1K 


//---Non-HWY

//---interact with age

gen clogYelpIn_indp_36NH = logYelpIn_indp*age_36*(1-IHWY_1K) 

gen clogYelpIn_rating_36NH = logYelpIn_rating*age_36*(1-IHWY_1K)

gen clogYelpIn_indp_36_60NH = logYelpIn_indp*age_36_60*(1-IHWY_1K)  

gen clogYelpIn_rating_36_60NH = logYelpIn_rating*age_36_60*(1-IHWY_1K)

gen clogYelpIn_indp_60_120NH = logYelpIn_indp*age_60_120*(1-IHWY_1K)  

gen clogYelpIn_rating_60_120NH = logYelpIn_rating*age_60_120*(1-IHWY_1K)

gen clogYelpIn_indp_120NH = logYelpIn_indp*age_over120*(1-IHWY_1K)  

gen clogYelpIn_rating_120NH = logYelpIn_rating*age_over120*(1-IHWY_1K)  


gen clogYelpIn_indp_144NH = logYelpIn_indp*age_over144*(1-IHWY_1K)  

gen clogYelpIn_rating_144NH = logYelpIn_rating*age_over144*(1-IHWY_1K)  

//---chain

//before
gen clogYelp_chain_36NH = logYelp_chain*age_36*(1-IHWY_1K)

gen clogYelpIn_chain_rating_36NH = logYelpIn_chain_rating*age_36*(1-IHWY_1K)  

gen clogYelp_chain_36_60NH = logYelp_chain*age_36_60*(1-IHWY_1K) 

gen clogYelpIn_chain_rating_36_60NH = logYelpIn_chain_rating*age_36_60*(1-IHWY_1K)

gen clogYelp_chain_60_120NH = logYelp_chain*age_60_120*(1-IHWY_1K)

gen clogYelpIn_chain_rating_60_120NH = logYelpIn_chain_rating*age_60_120*(1-IHWY_1K)

gen clogYelp_chain_120NH = logYelp_chain*age_over120*(1-IHWY_1K)  

gen clogYelpIn_chain_rating_120NH = logYelpIn_chain_rating*age_over120*(1-IHWY_1K)  


gen clogYelp_chain_144NH = logYelp_chain*age_over144*(1-IHWY_1K)  

gen clogYelpIn_chain_rating_144NH = logYelpIn_chain_rating*age_over144*(1-IHWY_1K)  



reghdfe lg_grs_rcpts_adj clogYelpIn_indp_36H clogYelpIn_rating_36H clogYelp_chain_36H clogYelpIn_chain_rating_36H ///
clogYelpIn_indp_36_60H clogYelpIn_rating_36_60H clogYelp_chain_36_60H clogYelpIn_chain_rating_36_60H ///
clogYelpIn_indp_60_120H clogYelpIn_rating_60_120H clogYelp_chain_60_120H clogYelpIn_chain_rating_60_120H ///
clogYelpIn_indp_120H  clogYelpIn_rating_120H  clogYelp_chain_120H  clogYelpIn_chain_rating_120H ///
clogYelpIn_indp_144H  clogYelpIn_rating_144H  clogYelp_chain_144H  clogYelpIn_chain_rating_144H ///
clogYelpIn_indp_36NH clogYelpIn_rating_36NH clogYelp_chain_36NH clogYelpIn_chain_rating_36NH ///
clogYelpIn_indp_36_60NH clogYelpIn_rating_36_60NH clogYelp_chain_36_60NH clogYelpIn_chain_rating_36_60NH ///
clogYelpIn_indp_60_120NH clogYelpIn_rating_60_120NH clogYelp_chain_60_120NH clogYelpIn_chain_rating_60_120NH ///
clogYelpIn_indp_120NH clogYelpIn_rating_120NH clogYelp_chain_120NH clogYelpIn_chain_rating_120NH ///
clogYelpIn_indp_144NH clogYelpIn_rating_144NH clogYelp_chain_144NH clogYelpIn_chain_rating_144NH ///
weigh_traffic zip_logtlpop zip_income log_vis_spend ///
zip_density zip_pt* zip_indep_rival zip_chain_rival hecklambda ///
if first_same_rest == 1 & last_2mnth ==0  & age > 0 & on_Yelp ==1 & sample_1strvw ==1, ///
absorb(uid_rest_gl uid_rest_gl#month stata_ym stata_ym#chain_ind stata_ym#core_id stata_ym#core_id#chain_ind) vce(cl county)



eststo model3



//------one more time

gen dlogYelpIn_indp_36H = logYelpIn_indp*age_36*IHWY_1K 

gen dlogYelpIn_rating_36H = logYelpIn_rating*age_36*IHWY_1K

gen dlogYelpIn_indp_36_60H = logYelpIn_indp*age_36_60*IHWY_1K  

gen dlogYelpIn_rating_36_60H = logYelpIn_rating*age_36_60*IHWY_1K

gen dlogYelpIn_indp_60_120H = logYelpIn_indp*age_60_120*IHWY_1K 

gen dlogYelpIn_rating_60_120H = logYelpIn_rating*age_60_120*IHWY_1K

gen dlogYelpIn_indp_120H = logYelpIn_indp*age_over120*IHWY_1K  

gen dlogYelpIn_rating_120H = logYelpIn_rating*age_over120*IHWY_1K  

gen dlogYelpIn_indp_144H = logYelpIn_indp*age_over144*IHWY_1K  

gen dlogYelpIn_rating_144H = logYelpIn_rating*age_over144*IHWY_1K  


//---chain

//before
gen dlogYelp_chain_36H = logYelp_chain*age_36*IHWY_1K

gen dlogYelpIn_chain_rating_36H = logYelpIn_chain_rating*age_36*IHWY_1K  

gen dlogYelp_chain_36_60H = logYelp_chain*age_36_60*IHWY_1K 

gen dlogYelpIn_chain_rating_36_60H = logYelpIn_chain_rating*age_36_60*IHWY_1K

gen dlogYelp_chain_60_120H = logYelp_chain*age_60_120*IHWY_1K

gen dlogYelpIn_chain_rating_60_120H = logYelpIn_chain_rating*age_60_120*IHWY_1K

gen dlogYelp_chain_120H = logYelp_chain*age_over120*IHWY_1K  

gen dlogYelpIn_chain_rating_120H = logYelpIn_chain_rating*age_over120*IHWY_1K  

gen dlogYelp_chain_144H = logYelp_chain*age_over144*IHWY_1K  

gen dlogYelpIn_chain_rating_144H = logYelpIn_chain_rating*age_over144*IHWY_1K 


//---Non-HWY

//---interact with age

gen dlogYelpIn_indp_36NH = logYelpIn_indp*age_36*(1-IHWY_1K) 

gen dlogYelpIn_rating_36NH = logYelpIn_rating*age_36*(1-IHWY_1K)

gen dlogYelpIn_indp_36_60NH = logYelpIn_indp*age_36_60*(1-IHWY_1K)  

gen dlogYelpIn_rating_36_60NH = logYelpIn_rating*age_36_60*(1-IHWY_1K)

gen dlogYelpIn_indp_60_120NH = logYelpIn_indp*age_60_120*(1-IHWY_1K)  

gen dlogYelpIn_rating_60_120NH = logYelpIn_rating*age_60_120*(1-IHWY_1K)

gen dlogYelpIn_indp_120NH = logYelpIn_indp*age_over120*(1-IHWY_1K)  

gen dlogYelpIn_rating_120NH = logYelpIn_rating*age_over120*(1-IHWY_1K)  


gen dlogYelpIn_indp_144NH = logYelpIn_indp*age_over144*(1-IHWY_1K)  

gen dlogYelpIn_rating_144NH = logYelpIn_rating*age_over144*(1-IHWY_1K)  

//---chain

//before
gen dlogYelp_chain_36NH = logYelp_chain*age_36*(1-IHWY_1K)

gen dlogYelpIn_chain_rating_36NH = logYelpIn_chain_rating*age_36*(1-IHWY_1K)  

gen dlogYelp_chain_36_60NH = logYelp_chain*age_36_60*(1-IHWY_1K) 

gen dlogYelpIn_chain_rating_36_60NH = logYelpIn_chain_rating*age_36_60*(1-IHWY_1K)

gen dlogYelp_chain_60_120NH = logYelp_chain*age_60_120*(1-IHWY_1K)

gen dlogYelpIn_chain_rating_60_120NH = logYelpIn_chain_rating*age_60_120*(1-IHWY_1K)

gen dlogYelp_chain_120NH = logYelp_chain*age_over120*(1-IHWY_1K)  

gen dlogYelpIn_chain_rating_120NH = logYelpIn_chain_rating*age_over120*(1-IHWY_1K)  


gen dlogYelp_chain_144NH = logYelp_chain*age_over144*(1-IHWY_1K)  

gen dlogYelpIn_chain_rating_144NH = logYelpIn_chain_rating*age_over144*(1-IHWY_1K)  


reghdfe lg_grs_rcpts_adj dlogYelpIn_indp_36H dlogYelpIn_rating_36H dlogYelp_chain_36H dlogYelpIn_chain_rating_36H ///
dlogYelpIn_indp_36_60H dlogYelpIn_rating_36_60H dlogYelp_chain_36_60H dlogYelpIn_chain_rating_36_60H ///
dlogYelpIn_indp_60_120H dlogYelpIn_rating_60_120H dlogYelp_chain_60_120H dlogYelpIn_chain_rating_60_120H ///
dlogYelpIn_indp_120H  dlogYelpIn_rating_120H  dlogYelp_chain_120H  dlogYelpIn_chain_rating_120H ///
dlogYelpIn_indp_144H  dlogYelpIn_rating_144H  dlogYelp_chain_144H  dlogYelpIn_chain_rating_144H ///
dlogYelpIn_indp_36NH dlogYelpIn_rating_36NH dlogYelp_chain_36NH dlogYelpIn_chain_rating_36NH ///
dlogYelpIn_indp_36_60NH dlogYelpIn_rating_36_60NH dlogYelp_chain_36_60NH dlogYelpIn_chain_rating_36_60NH ///
dlogYelpIn_indp_60_120NH dlogYelpIn_rating_60_120NH dlogYelp_chain_60_120NH dlogYelpIn_chain_rating_60_120NH ///
dlogYelpIn_indp_120NH dlogYelpIn_rating_120NH dlogYelp_chain_120NH dlogYelpIn_chain_rating_120NH ///
dlogYelpIn_indp_144NH dlogYelpIn_rating_144NH dlogYelp_chain_144NH dlogYelpIn_chain_rating_144NH ///
weigh_traffic zip_logtlpop zip_income log_vis_spend ///
zip_density zip_pt* zip_indep_rival zip_chain_rival hecklambda ///
if first_same_rest == 1 & last_2mnth ==0  & age > 0 & on_Yelp ==1 & sample_1strvw ==1, ///
absorb(uid_rest_gl uid_rest_gl#month stata_ym stata_ym#chain_ind stata_ym#core_id stata_ym#core_id#chain_ind) vce(cl county)

eststo model4


esttab model* using "/Users/fanglimi/Dropbox/JMP/Writing/2020_Sept_draft_results/2020_09_09_byage_HWY_county_independent_google_rating.tex", se ///
starlevels(* 0.10 ** 0.05 *** 0.01) label stats(controls restbymonthFE timebymetrobychainFE eN eNclust erating) ///
substitute(controls "Controls" restbymonthFE "Restaurant\$\times\$Month FE" timebymetrobychainFE "Year$\times\$Month$\times\$Metro$\times\$Chain FE" ///
 eN "N" Nclust "N of Clusters" erating "Quality Measure") ///
drop(_cons logYelp*NH logYelp_chain_* logYelpIn_chain_rating_* elogYelp*36H elogYelp*36_60H elogYelp*60_120H elogYelp*120H elogYelp*144H elogYelp_chain_* elogYelpIn_chain_rating_* ///
 clogYelp*NH clogYelpIn_indp_* clogYelpIn_rating_* dlogYelp*36H dlogYelp*36_60H dlogYelp*60_120H dlogYelp*120H dlogYelp*144H dlogYelpIn_indp_* dlogYelpIn_rating_* ///
 weigh_traffic zip_logtlpop zip_income log_vis_spend zip_density zip_pt* zip_indep_rival zip_chain_rival hecklambda) replace ///
rename(elogYelpIn_indp_36NH logYelpIn_indp_36H elogYelpIn_rating_36NH logYelpIn_rating_36H ///
elogYelpIn_indp_36_60NH logYelpIn_indp_36_60H elogYelpIn_rating_36_60NH logYelpIn_rating_36_60H ///
elogYelpIn_indp_60_120NH logYelpIn_indp_60_120H elogYelpIn_rating_60_120NH logYelpIn_rating_60_120H ///
elogYelpIn_indp_120NH logYelpIn_indp_120H elogYelpIn_rating_120NH logYelpIn_rating_120H ///
elogYelpIn_indp_144NH logYelpIn_indp_144H elogYelpIn_rating_144NH logYelpIn_rating_144H ///
clogYelp_chain_36H logYelpIn_indp_36H clogYelpIn_chain_rating_36H logYelpIn_rating_36H ///
clogYelp_chain_36_60H logYelpIn_indp_36_60H clogYelpIn_chain_rating_36_60H logYelpIn_rating_36_60H ///
clogYelp_chain_60_120H logYelpIn_indp_60_120H clogYelpIn_chain_rating_60_120H logYelpIn_rating_60_120H ///
clogYelp_chain_120H logYelpIn_indp_120H clogYelpIn_chain_rating_120H logYelpIn_rating_120H ///
clogYelp_chain_144H logYelpIn_indp_144H clogYelpIn_chain_rating_144H logYelpIn_rating_144H ///
dlogYelp_chain_36NH logYelpIn_indp_36H dlogYelpIn_chain_rating_36NH logYelpIn_rating_36H ///
dlogYelp_chain_36_60NH logYelpIn_indp_36_60H dlogYelpIn_chain_rating_36_60NH logYelpIn_rating_36_60H ///
dlogYelp_chain_60_120NH logYelpIn_indp_60_120H dlogYelpIn_chain_rating_60_120NH logYelpIn_rating_60_120H ///
dlogYelp_chain_120NH logYelpIn_indp_120H dlogYelpIn_chain_rating_120NH logYelpIn_rating_120H ///
dlogYelp_chain_144NH logYelpIn_indp_144H dlogYelpIn_chain_rating_144NH logYelpIn_rating_144H) ///
title(Effects by Restaurant Age and Location) ///
nonumbers mtitles("Highway" "Non-Highway" "Highway" "Non-Highway") 	///
mgroups("Independent" "Chain", pattern(1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span)  ///     
prehead("\begin{table}[htbp]\centering"  "\resizebox{0.7\textwidth}{!}{\begin{threeparttable}" "\scriptsize" "\caption{@title}" "\label{hwyage}" "\begin{tabular}{l*{@E}{c}}" ///
"\hline\hline" "\multicolumn{1}{l}{Dependent variable}& \multicolumn{4}{c}{Log Revenue}\\") ///
		posthead("\hline") ///
		prefoot("\\" "\hline")  ///
		postfoot("\hline\hline" "\end{tabular}" ///
		 "\begin{tablenotes}" "\footnotesize" "\item The regressions account for all \lowercase{controls} including demographics, traffic counts, visitor's spending, the number of chain and independent rivals in the same zip code tabulation area, and Heckman's lambda to control for endogenous exits. All standard errors are clustered at the county level and are shown in parentheses. * p\textless 0.10, ** p\textless 0.05, *** p\textless 0.01" ///
		 "\end{tablenotes}" "\end{threeparttable}}" "\end{table}")	 


		 
