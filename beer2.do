clear

* SETUP STUFF
*cd "E:\Dropbox\1-Research\1-Papers\Places as Brands - Beer\"
cd "S:"
cd "beer2feb23"
glo RESULTS "Regressions\Results_4_1"
*glo RESULTS "C:\beer_output_2"

*use "Data\breweries_to_use_1.dta"
use "Data\breweries_en_only.dta"

* Lots of zeros in the data so let's drop em
drop if brewery_rating_score ==0
drop if brewery_rating_count < 100

* Encode city, state, other string vars...
encode brewery_city, generate(brewery_city_id)
encode brewery_state, generate(brewery_state_id)
encode country_name, generate(country_name_id)

*******************************************
* VARIABLES w/ SUFFICIENT VARIATION:
*******************************************
* date, fac, gpe, loc, norp, org, person
*******************************************

glo RHS = "date fac gpe loc norp org person"

* Create Dummy rather than level variables

gen date_dummy = 1 if date > 0
replace date_dummy = 0 if date_dummy == .

gen fac_dummy = 1 if fac > 0
replace fac_dummy = 0 if fac_dummy == .

gen gpe_dummy = 1 if gpe > 0
replace gpe_dummy = 0 if gpe_dummy == .

gen loc_dummy = 1 if loc > 0
replace loc_dummy = 0 if loc_dummy == .

gen norp_dummy = 1 if norp > 0
replace norp_dummy = 0 if norp_dummy == .

gen org_dummy = 1 if org > 0
replace org_dummy = 0 if org_dummy == .

gen person_dummy = 1 if person > 0
replace person_dummy = 0 if person_dummy == .

glo RHS_dummies = "date_dummy fac_dummy gpe_dummy loc_dummy norp_dummy org_dummy person_dummy"

* Generate log variables
* LHS:
gen log_brewery_rating_score = ln(brewery_rating_score)

* RHS:
gen log_date = ln(date)
gen log_fac = ln(fac)
gen log_gpe = ln(gpe)
gen log_loc = ln(loc)
gen log_norp = ln(norp)
gen log_org = ln(org)
gen log_person = ln(person)

glo RHS_logs = "log_date log_fac log_gpe log_loc log_norp log_org log_person"

* Controls:
gen log_brewery_rating_count = ln(brewery_rating_count)
gen log_brewery_age_on_service = ln(brewery_age_on_service)
gen log_beer_count = ln(beer_count)

* Generate Lables:
label variable is_independent "Independent?"
label variable beer_count "Beer Count"
label variable brewery_type "Brewery Type"
label variable brewery_rating_score "Brewery Rating Score"
label variable brewery_age_on_service "Age on Service"
label variable brewery_rating_count "Rating Count"
label variable brewery_in_production "In Production?"

* LIST OF CONTROLS:
* brewery_in_production, is_independent, beer_count, brewery_type_id, brewery_rating_count, brewery_age_on_service 

* Summary stats
sum brewery_rating_score date fac gpe loc norp org person beer_count is_independent brewery_in_production brewery_age_on_service brewery_rating_count
outreg2 using "$RESULTS\sum_stats.tex", replace label sum(log) keep(brewery_rating_score date fac gpe loc norp org person beer_count is_independent brewery_in_production brewery_age_on_service brewery_rating_count)


* LHS Histogram
hist brewery_rating_score if brewery_rating_score > 0, freq normal xtitle("Brewery Rating Score") ytitle("Number of Observations")
graph export "$RESULTS\histogram_brewery_rating_score.tif", width(1000) replace
graph export "$RESULTS\histogram_brewery_rating_score.eps", preview(on) replace
graph export "$RESULTS\histogram_brewery_rating_score.png", width(2000) replace

* Correlation Matrix
*estpost corr cardinal date event fac gpe language law loc money norp ordinal org percent person product quantity time work_of_art, matrix listwise
*esttab using correlationresults_all_vars.csv, replace unstack not noobs compress b(2) nonote label
estpost corr cardinal date event fac gpe language law loc money norp ordinal org percent person, matrix listwise
esttab using correlationresults_main_vars.csv, replace unstack not noobs compress b(2) nonote label


* Bar Chart of Top 10 Countries in Sample

* Bar Chart of Frequency of Brewery Type
* TO-DO

*************************************
* REGRESSIONS
*************************************

* TABLE 1 LEVEL-LEVEL: Building up to preferred spec.

* Baseline reg - no areg b/c no f.e.s
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count
outreg2 using "$RESULTS\baseline.tex", adjr2 ctitle("All") addtext(Country FE, NO, State FE, NO, City FE, NO) label replace

* Robust 
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, vce(robust)
outreg2 using "$RESULTS\baseline.tex", adjr2 ctitle("Robust Errors") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by brewery type
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, vce(cluster brewery_type_id)
outreg2 using "$RESULTS\baseline.tex", adjr2 ctitle("Cluster - Brewery Type") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by country
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, vce(cluster country_name_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Cluster - Country") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by state
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, vce(cluster brewery_state_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Cluster - State") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by city
reg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, vce(cluster brewery_city_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Cluster - City") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Country F.E.s - cluster by brewery_type_id - might want to try different combos for robust
areg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, absorb(country_name_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, YES, State FE, NO, City FE, NO) label append

* State F.E.s
areg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, absorb(brewery_state_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, NO, State FE, YES, City FE, NO) label append

* City F.E.s
areg brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production brewery_age_on_service brewery_rating_count beer_count, absorb(brewery_city_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\baseline.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, NO, State FE, NO, City FE, YES) label append

* TABLE 2 LOG-LEVEL: Building up to preferred spec. Do we want this to be levels/logs?
* NOTE: Log LHS and some continuous controls. Don't Log counts tho as too few are actually set

* Baseline reg - no areg b/c no f.e.s
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("All") addtext(Country FE, NO, State FE, NO, City FE, NO) label replace

* Robust 
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, vce(robust)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Robust Errors") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by brewery type
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, vce(cluster brewery_type_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Cluster - Brewery Type") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by country
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, vce(cluster country_name_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Cluster - Country") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by state
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, vce(cluster brewery_state_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Cluster - State") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Cluster by city
reg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, vce(cluster brewery_city_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Cluster - City") addtext(Country FE, NO, State FE, NO, City FE, NO) label append

* Country F.E.s - cluster by brewery_type_id - might want to try different combos for robust
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, absorb(country_name_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, YES, State FE, NO, City FE, NO) label append

* State F.E.S
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, absorb(brewery_state_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, NO, State FE, YES, City FE, NO) label append

* City
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, absorb(brewery_city_id) vce(cluster brewery_type_id)
outreg2 using "$RESULTS\log-level.tex",  adjr2 ctitle("Fixed Effects") addtext(Country FE, NO, State FE, NO, City FE, YES) label append

* log-level regression - NOTE: we have lots of zeros so this is another robustness check
*reg log_brewery_rating_score cardinal date event fac gpe language law loc money norp ordinal org percent person product quantity time work_of_art beer_count is_independent brewery_in_production brewery_age_on_service brewery_rating_count brewery_state_id, vce(cluster brewery_age_on_service)

* Rating >0, In production, only independent:
*reg log_brewery_rating_score cardinal date event fac gpe language law loc money norp ordinal org percent person product quantity time work_of_art beer_count is_independent brewery_in_production brewery_age_on_service brewery_rating_count brewery_state_id if brewery_rating_score >0 & brewery_in_production ==1 & is_independent ==1, vce(cluster brewery_age_on_service)


* TABLE 3: BASELING REG STRATIFY BY BREWERY TYPE
* 1 - Macro Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 1, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Macro Brewery") label replace

* 2 - Micro Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Micro Brewery") label append

* 3 - Nano Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 3, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Nano Brewery") label append

* 4 - Brew Pub
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 4, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Brew Pub") label append

* 5 - Home Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 5, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Home Brewery") label append

* 7 - Bar / Restaurant / Store
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 7, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Bar/Restaurant/Store") label append

* 8 - Cidery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 8, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Cidery") label append

* 9 - Meadery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 9, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Meadery") label append

* 10 - Contract Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 10, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Contract Brewery") label append

* 11 - Regional Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 11, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\brewery-type.tex",  adjr2 ctitle("Regional Brewery") label append

* TABLE 4: Dummies Instead of Counts
**************************************

* 1 - Preferred Spec
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\dummy-count.tex",  adjr2 ctitle("Counts") label replace

* 2 - Dummies
areg log_brewery_rating_score date_dummy  fac_dummy  gpe_dummy  loc_dummy  norp_dummy  org_dummy  person_dummy  is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\dummy-count.tex",  adjr2 ctitle("Dummies") label replace



* TABLE 5: BASELINCE SPEC REG STRATIFY BY BREWERY TYPE STATE FE's
* 1 - Macro Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 1, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Macro Brewery") label replace

* 2 - Micro Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Micro Brewery") label append

* 3 - Nano Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 3, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Nano Brewery") label append

* 4 - Brew Pub
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 4, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Brew Pub") label append

* 5 - Home Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 5, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Home Brewery") label append

* 7 - Bar / Restaurant / Store
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 7, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Bar/Restaurant/Store") label append

* 8 - Cidery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 8, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Cidery") label append

* 9 - Meadery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 9, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Meadery") label append

* 10 - Contract Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 10, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Contract Brewery") label append

* 11 - Regional Brewery
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 11, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\brewery-type-state.tex",  adjr2 ctitle("Regional Brewery") label append


* TABLE 6: MICRO ONLY - Country, State, City count and dummy
************************************************
* 1 - Country, Count
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Count - Country") label append

*2 - State, Count
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Count - State") label append

*3 - City, Count
areg log_brewery_rating_score date fac gpe loc norp org person is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(brewery_city_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Count - City") label append

*4 - Country, Dummy
areg log_brewery_rating_score date_dummy fac_dummy gpe_dummy loc_dummy norp_dummy org_dummy person_dummy is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(country_name_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Dummies - Country") label append

*5 - State, Dummy
areg log_brewery_rating_score date_dummy fac_dummy gpe_dummy loc_dummy norp_dummy org_dummy person_dummy is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(brewery_state_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Dummies - State") label append

*6 - City, Dummy
areg log_brewery_rating_score date_dummy fac_dummy gpe_dummy loc_dummy norp_dummy org_dummy person_dummy is_independent brewery_in_production log_brewery_age_on_service log_brewery_rating_count log_beer_count if brewery_type_id == 2, absorb(brewery_city_id) vce(robust)
outreg2 using "$RESULTS\micro-count-dummy.tex",  adjr2 ctitle("Dummies - City") label append


* TABLE N: Only Top N% of Breweries - i.e. drop the homebrewers and only look at places with at least several thousand ratings...

* TABLE N: Probably robustness check/label appendix - use dummies instead of counts

* Clustering - 
* within country b/c of preference? 
* within region?
* within type 
* independent

* FE's
* type
* some sort of location
* idependent
* active

* Values of Tags
* Value or dummy?

* Do a PCA with the placey variables
* hist of score, hist of gpe
* dummy vs. integer regression
