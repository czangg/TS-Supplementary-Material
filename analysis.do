********************************************************
***				Course Choice: Analysis				****
********************************************************

	
clear
set more off

cd "$data"

import excel "data.xlsx", sheet("Export 1.1") firstrow


********************************************
****	A) Prepare and reshape data		****
********************************************

***A.1) Drop unwanted vars

drop rts* external_lfdn tester quality lastpage v_14 v_31 v_33 v_35 v_37 v_39 referer device_type quota* ///
	page_history hflip vflip output_mode javascript flash session_id language cleaned ats ///
	date_of_last_access date_of_first_mail
	

***A.2) Rename 
rename (c_0001	c_0002	c_0003	c_0004	c_0005	c_0006	c_0007	c_0008	c_0009	c_0010	c_0011	c_0012	c_0013 ///
	c_0014	c_0015	c_0016	c_0017	c_0018	c_0019	c_0020	c_0021	c_0022	c_0023	c_0024	c_0025	c_0026	///
	c_0027	c_0028	c_0029	c_0030	c_0031	c_0032	c_0033	c_0034	c_0035	c_0036	c_0037	c_0038	c_0039	///
	c_0040	c_0041	c_0042	c_0043	c_0044	c_0045	c_0046	c_0047	c_0048	c_0049	c_0050	c_0051	c_0052	///
	c_0053	c_0054	c_0055	c_0056	c_0057	c_0058	c_0059	c_0060	c_0061	c_0062	c_0063	c_0064	c_0065	///
	c_0066	c_0067	c_0068	c_0069	c_0070	c_0071	c_0072	c_0073	c_0074	c_0075	c_0076	c_0077	c_0078	///
	c_0079	c_0080	c_0081	c_0082	c_0083	c_0084	c_0085	c_0086	c_0087	c_0088	c_0089	c_0090	c_0091	///
	c_0092	c_0093	c_0094	c_0095	c_0096	c_0097	c_0098	c_0099	c_0100	c_0101	c_0102	c_0103	c_0104	///
	c_0105	c_0106	c_0107	c_0108) ///
	(ects1_1	prerequisites1_1	schedule1_1	assessments1_1	organization1_1	mixedgroup1_1	ects2_1	///
	prerequisites2_1	schedule2_1	assessments2_1	organization2_1	mixedgroup2_1	ects3_1	prerequisites3_1	///
	schedule3_1	assessments3_1	organization3_1	mixedgroup3_1	ects1_2	prerequisites1_2	schedule1_2	///
	assessments1_2	organization1_2	mixedgroup1_2	ects2_2	prerequisites2_2	schedule2_2	assessments2_2 ///
	organization2_2	mixedgroup2_2	ects3_2	prerequisites3_2	schedule3_2	assessments3_2	organization3_2 ///
	mixedgroup3_2	ects1_3	prerequisites1_3	schedule1_3	assessments1_3	organization1_3	mixedgroup1_3	///
	ects2_3	prerequisites2_3	schedule2_3	assessments2_3	organization2_3	mixedgroup2_3	ects3_3	///
	prerequisites3_3	schedule3_3	assessments3_3	organization3_3	mixedgroup3_3	ects1_4	prerequisites1_4	///
	schedule1_4	assessments1_4	organization1_4	mixedgroup1_4	ects2_4	prerequisites2_4	schedule2_4	///
	assessments2_4	organization2_4	mixedgroup2_4	ects3_4	prerequisites3_4	schedule3_4	assessments3_4 ///
	organization3_4	mixedgroup3_4	ects1_5	prerequisites1_5	schedule1_5	assessments1_5	organization1_5 ///
	mixedgroup1_5	ects2_5	prerequisites2_5	schedule2_5	assessments2_5	organization2_5	mixedgroup2_5	///
	ects3_5	prerequisites3_5	schedule3_5	assessments3_5	organization3_5	mixedgroup3_5	ects1_6	///
	prerequisites1_6	schedule1_6	assessments1_6	organization1_6	mixedgroup1_6	ects2_6	prerequisites2_6	///
	schedule2_6	assessments2_6	organization2_6	mixedgroup2_6	ects3_6	prerequisites3_6	schedule3_6	///
	assessments3_6	organization3_6	mixedgroup3_6)

rename (v_24 v_32 v_34 v_36 v_38 v_40) ///
	(choice_1 choice_2 choice_3 choice_4 choice_5 choice_6)
	
rename (v_1 v_2 v_3 v_4 v_5 v_6 v_7 v_8 v_46) ///
	(field field_other program program_other N_courses sat_variety sat_teaching  sat_career comments)
	
rename lfdn ID

***A.3) Reshape to long, for the 6 choice sets each respondent answered

reshape long ects1_	prerequisites1_ schedule1_ assessments1_ organization1_ mixedgroup1_ ects2_	///
	prerequisites2_ schedule2_ assessments2_ organization2_ mixedgroup2_ ects3_ prerequisites3_	///
	schedule3_ assessments3_ organization3_ mixedgroup3_ choice_, i(ID) j(ChoiceSet)

*Add the deck information
gen deck=2
replace deck=1 if ects2_=="6 ECTS"
fre deck	

rename  (*_) (*)

***A.4) Reshape another time to long format, this time for the different alternatives of each choice set

*Identify unique choice situations for reshape
egen ChoiceSituation=concat(ID ChoiceSet)
destring ChoiceSituation, replace

reshape long ects prerequisites schedule assessments organization mixedgroup, i(ChoiceSituation) j(alternative)

*Binary choice variable: Has alternative been chosen or not (dep var)
gen chosen=choice==alternative
fre choice

*Encode string variables to numeric
foreach var of varlist ects prerequisites schedule assessments organization mixedgroup {
	encode `var', gen(`var'_n)
	drop `var'
	rename `var'_n `var'
}


*** A5) Recode missing values (-99)
recode field program N_courses sat_variety sat_teaching sat_career (-99=.)


***********************************************************
***					B: Some descriptives				***	
***********************************************************


*Number of times each vignette and choice set was evaluated

sort ects prerequisites schedule assessments organization mixedgroup
quietly by ects prerequisites schedule assessments organization mixedgroup:  gen dup = cond(_N==1,0,_N)
tab dup
//each vignette evaluated between 22 and 46 times

drop dup

preserve 

keep ChoiceSituation alternative ects prerequisites schedule assessments organization mixedgroup
reshape wide ects prerequisites schedule assessments organization mixedgroup, i(ChoiceSituation) j(alternative)

sort ects1 prerequisites1 schedule1 assessments1 organization1 mixedgroup1 ///
	ects2 prerequisites2 schedule2 assessments2 organization2 mixedgroup2 ///
	ects3 prerequisites3 schedule3 assessments3 organization3 mixedgroup3
quietly by ects1 prerequisites1 schedule1 assessments1 organization1 mixedgroup1 ///
	ects2 prerequisites2 schedule2 assessments2 organization2 mixedgroup2 ///
	ects3 prerequisites3 schedule3 assessments3 organization3 mixedgroup3:  gen dup = cond(_N==1,0,_N)
tab dup
//choice sets were evaluated between 10 and 22 times

restore

*Check: Correlation with deck induced by design!
bysort deck: fre choice   //3rd alternative dominates in deck 2 --> also see corr matrix exp. design

label var ects "ECTS"
label var prerequisites "Prerequisites"
label var schedule "Schedule"
label var assessments "Assessment"
label var organization "Methods"
label var mixedgroup "Composition"
label var deck "Deck"
label var chosen "Outcome"

corr ects prerequisites schedule assessments ///
	organization mixedgroup deck chosen
matrix correlations = r(C)

capture graph drop _all

heatplot correlations, values(format(%4.3f) size(medium)) color(tab Gray Warm, intensity(0.5))  ///
	lower nodiagonal xlabel(,alternate) label legend(off) graphregion(color(white)) xscale(range(1/8)) name(g0)

graph export "$graphs\correlations_all.eps", name(g0) replace
graph export "$graphs\correlations_all.png", name(g0) width(2000) replace
	



*******************************************
***		C: Conditional logit models		***
*******************************************

	
*Control for deck since correlated with vignette dimension(s)!
cmset ID ChoiceSet alternative	
sort ID ChoiceSet alternative
list ID ChoiceSet alternative _* in 1/20
	
cmclogit chosen i.ects i.prerequisites i.schedule i.assessments i.organization i.mixedgroup, /// 
	casevars(i.deck) vce(cluster ID)

*equivalent	
clogit chosen i.alternative i.ects i.prerequisites i.schedule i.assessments i.organization i.mixedgroup ///
	i.deck i.alternative#i.deck, /// 
	group(ChoiceSituation) vce(cluster ID)
eststo clogit


*Add a respondent-level variable (interaction)
clogit chosen i.alternative i.ects i.prerequisites i.schedule i.assessments i.organization i.mixedgroup ///
	i.deck i.alternative#i.deck c.sat_teaching c.sat_teaching#i.prerequisites, /// 
	group(ChoiceSituation) vce(cluster ID)
eststo clogit_rl
	

*********************************************
****		D: Mixed logit models		*****
*********************************************

*Panel
cmxtmixlogit chosen i.ects i.prerequisites i.schedule i.assessments i.organization i.mixedgroup, casevars(i.deck)

*Add random effect for prerequisites
cmxtmixlogit chosen i.ects i.schedule i.assessments i.organization i.mixedgroup, ///
	random(i.prerequisites) casevars(i.deck)

eststo mixlogit

esttab clogit clogit_rl mixlogit, pr2 b(%8.2f) se(%8.2f) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
esttab clogit clogit_rl mixlogit using "$tables/models.rtf", pr2 b(%8.3f) se(%8.3f) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) onecell replace

	
	
	
	
	
	
	
*********************************************	
****				Revision 1			*****
*********************************************

eststo clear

clogit chosen i.alternative i.ects i.prerequisites i.schedule ib3.assessments ib2.organization i.mixedgroup ///
	i.deck i.alternative#i.deck, /// 
	group(ChoiceSituation) vce(cluster ID)
eststo clogit

*Add a respondent-level variable (interaction)
clogit chosen i.alternative i.ects i.prerequisites i.schedule ib3.assessments ib2.organization i.mixedgroup ///
	i.deck i.alternative#i.deck c.sat_teaching c.sat_teaching#i.prerequisites, /// 
	group(ChoiceSituation) vce(cluster ID)
eststo clogit_rl

cmxtmixlogit chosen i.ects i.schedule ib3.assessments ib2.organization i.mixedgroup, ///
	random(i.prerequisites) casevars(i.deck)

eststo mixlogit

esttab clogit clogit_rl mixlogit, pr2 b(%8.2f) se(%8.2f) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
esttab clogit clogit_rl mixlogit using "$tables/models.rtf", pr2 b(%8.3f) se(%8.3f) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) onecell replace

	
	


