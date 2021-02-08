
* cough suppressant: relieves cough by reducing the activity of cough centre in the brain
replace comps_adj = lower(comps_adj)
gen temp_cough1 = strpos(comps_adj, "dextromethor") >0
gen temp_cough2 = strpos(comps_adj, "camphor") >0
gen temp_cough3 = strpos(comps_adj, "eucalyptus") >0
gen temp_cough4 = strpos(comps_adj, "menthol") >0
gen temp_cough5 = strpos(comps_adj, "benprop") >0
gen temp_cough6 = strpos(comps_adj, "cofrel") >0

* mucolytic: thin and loosen mucus, easier to cough out
gen temp_muco1 = strpos(comps_adj, "ambroxol") >0
gen temp_muco2 = strpos(comps_adj, "guaifenesin") >0
gen temp_muco3 = strpos(comps_adj, "glycyrrhi") >0
gen temp_muco4 = strpos(comps_adj, "licorice") >0
gen temp_muco5 = strpos(comps_adj, "carbocis") >0
gen temp_muco6 = strpos(comps_adj, "ipecac") >0
gen temp_muco7 = strpos(comps_adj, "acetyl") >0
gen temp_muco8 = strpos(comps_adj, "bambusa") >0

* congestion
gen temp_congest1 = strpos(comps_adj, "ephedrine")>0
gen temp_congest2 = strpos(comps_adj, "phenyle")>0
gen temp_congest3 = strpos(comps_adj, "pseudoephe")>0
gen temp_congest4 = strpos(comps_adj, "oxymetaz")>0
gen temp_congest5 = strpos(comps_adj, "xylometazoline")>0
gen temp_congest6 = strpos(comps_adj, "sodium")>0

* pain and fever
gen temp_pain1 = strpos(comps_adj, "paraceta")>0
gen temp_pain2 = strpos(comps_adj, "acetamin")>0
gen temp_pain3 = strpos(comps_adj, "ibupro")>0
gen temp_pain4 = strpos(comps_adj, "naprox")>0

* relieve symptons
gen temp_symp1 = strpos(comps_adj, "chlorphen")>0
gen temp_symp2 = strpos(comps_adj, "cetirizine")>0
gen temp_symp3 = strpos(comps_adj, "promethazine")>0
gen temp_symp4 = strpos(comps_adj, "amantadine")>0
gen temp_symp5 = strpos(comps_adj, "clemastine")>0

* medicine that contains unhealthy elements
gen temp_side1 = strpos(comps_adj, "qiang li") >0
gen temp_side2 = strpos(comps_adj, "fufang") >0
gen temp_side3 = strpos(comps_adj, "zhi ke") >0
gen temp_side4 = strpos(comps_adj, "tan ke") >0
gen temp_side5 = strpos(comps_adj, "xiao er") >0
gen temp_side6 = strpos(comps_adj, "codeine") >0
gen temp_side7 = strpos(comps_adj, "opium") >0
gen temp_side8 = strpos(comps_adj, "xiaoer") >0

* medicine that contains caffeine
gen temp_caffeine = strpos(comps_adj, "caffeine")>0

egen ind_cough = rowmax(temp_cough*)
egen ind_muco = rowmax(temp_muco*)
egen ind_congest = rowmax(temp_congest*)
egen ind_pain = rowmax(temp_pain*)
egen ind_sympton = rowmax(temp_symp*)
egen ind_side = rowmax(temp_side*)

egen ind_all = rowtotal(ind_cough ind_muco ind_congest ind_pain ind_sympton)

* group different ingredients: 30 different groups
* medicine that contains only 1 active ingredients
gen molecule_group = ""
foreach i in "cough" "muco" "congest" "pain" "sympton"{
replace molecule_group = "`i'" if ind_`i' == 1 & ind_all == 1
}

* with two ingredients
foreach i in "muco" "congest" "pain" "sympton"{
replace molecule_group = "cough" + "+"+ "`i'" if ind_cough == 1 & ind_`i' == 1 & ind_all == 2
}

foreach i in "congest" "pain" "sympton"{
replace molecule_group = "muco" + "+"+"`i'" if ind_muco == 1 & ind_`i' == 1 & ind_all == 2
}

foreach i in "pain" "sympton"{
replace molecule_group = "congest" +"+"+ "`i'" if ind_congest == 1 & ind_`i' == 1 & ind_all == 2
}

foreach i in "sympton"{
replace molecule_group = "pain" + "+"+"`i'" if ind_pain == 1 & ind_`i' == 1 & ind_all == 2
}

* with three ingredients
foreach i in "congest" "pain" "sympton"{
replace molecule_group = "cough" + "+" + "muco" + "+"+ "`i'" if ind_cough == 1 & ind_muco == 1 &  ind_`i' == 1 & ind_all == 3
}

foreach i in "pain" "sympton"{
replace molecule_group = "cough" + "+" + "congest" + "+"+ "`i'" if ind_cough == 1 & ind_congest == 1 &  ind_`i' == 1 & ind_all == 3
}

foreach i in "sympton"{
replace molecule_group = "cough" + "+" + "pain" + "+" + "`i'" if ind_cough == 1 & ind_pain == 1 &  ind_`i' == 1 & ind_all == 3
}

foreach i in "pain" "sympton"{
replace molecule_group = "muco" + "+" + "congest" + "+"+ "`i'" if ind_muco == 1 & ind_congest == 1 &  ind_`i' == 1 & ind_all == 3
}

foreach i in "sympton"{
replace molecule_group = "muco" + "+" + "pain" + "+"+ "`i'" if ind_muco == 1 & ind_pain == 1 &  ind_`i' == 1 & ind_all == 3
}

replace molecule_group = "congest" + "+" + "pain" + "+"+ "sympton" if ind_congest == 1 & ind_pain == 1 &  ind_sympton == 1 & ind_all == 3

* with four active ingredients
replace molecule_group = "cough+muco+congest+pain" if  ind_all == 4 & ind_sympton == 0
replace molecule_group = "cough+muco+congest+sympton" if  ind_all == 4 & ind_pain == 0
replace molecule_group = "cough+muco+pain+sympton" if  ind_all == 4 & ind_congest == 0
replace molecule_group = "cough+congest+pain+sympton" if  ind_all == 4 & ind_muco == 0
replace molecule_group = "muco+congest+pain+sympton" if  ind_all == 4 & ind_cough == 0

* with five active ingredients
replace molecule_group = "cough+muco+congest+pain+sympton" if  ind_all == 5
replace molecule_group = "others" if ind_all == 0 & ind_herb == 0
replace molecule_group = "herb" if  ind_all == 0 & ind_herb == 1

drop temp_*
egen mole_group = group(molecule_group), label
