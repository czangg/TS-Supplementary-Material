***************************
***    Course choice    ***
***************************

set seed 14582

*1. Load the data from SAS
clear
cd "C:\Users\Christoph Zangger\OneDrive - Universität Zürich UZH\LMU\Lehre\WiSe 2021\Simulation\Course Choice CE\"
use "courses.dta" 


*2. Rename the vignette dimensions
rename (x1 x2 x3 x4 x5 x6) (ects prerequisites schedule assessments organization mixedgroup) 
 
*3. Label values (levels of the dimensions)
label def ects_l 1 "3 ECTS" 2 "6 ECTS"
label values ects ects_l

label def prerequisites_l ///
	1 "none" ///
	2 "introductory statistics" ///
	3 "multivariate statistics"
label values prerequisites prerequisites_l

label def schedule_l 1 "two blocks, FR-SA, 9 a.m. - 5 p.m." 2 "weekly, Monday, 2 - 4 p.m." 
label values schedule schedule_l

label def assessments_l ///
	1 "written exam, end of semester" ///
	2 "oral presentation & term paper" ///
	3 "graded exercises & small project"
label values assessments assessments_l

label def organization_l 1 "mostly lectures/presentations" 2 "applied, working on problems"
label values organization organization_l

label def mixedgroup_l 1 "homogenous (either BA or MA)" 2 "mixed (BA & MA)"
label values mixedgroup mixedgroup_l

*4. Reshape to wide format, first for the three alternatives per choice set, then by choice set

* Alternatives
reshape wide ects prerequisites schedule assessments organization mixedgroup, i(Block Set) j(Alt)

* Choice sets (such that each individual will rate 6)
reshape wide ects* prerequisites* schedule* assessments* organization* mixedgroup*, i(Block) j(Set)


*5. Expand and reshuffle the choice sets, make an ID for later matching of results with exp. design
expand 60 

gen r = runiform()
sort r
drop r

gen ID = char(runiformint(65,90)) + ///
    string(runiformint(0,9)) + ///
    char(runiformint(65,90)) + ///
    char(runiformint(65,90)) + ///
    string(runiformint(0,9))
fre ID

order ID, before(Block)

export excel using "course choice.xls", firstrow(variables) replace 
save "courses_labeled.dta", replace
