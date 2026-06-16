* People's Voice Survey data cleaning for Malawi - Wave 1
* Last updated by: L Xiang   (structured to mirror crPVS_cln_JP.do)
/*
This file cleans the Malawi PVS export (SurveyCTO).
Unlike the Japan Ipsos file, Malawi stores answers as TEXT labels, so each
question is ENCODED from string -> PVS numeric code (no +8000 offset needed).

Missingness codes: .a = NA (skipped/blank), .r = refused, .d = don't know
Items needing confirmation are flagged // TODO.
*/

clear all
set more off

*********************** MALAWI ***********************

* Import raw data (supplied as .dta)
use "Malawi_PVS_data_20250620.dta", clear

* Keep consented interviews; drop consent, PII and empty columns
keep if q1=="Yes"
drop interviewer_name Phone_Number_of_client cell1 cell1_1 cell2 cell3 cell3_1 q1 q23a
capture drop var104-var123

*------------------------------------------------------------------------------*
* Generate variables

gen respondent_id = "MW" + string(_n)   // no serial in export; use survey KEY/uuid if available

gen country = .          // TODO: set Malawi PVS country code (confirm with Todd)
lab var country "Country"

gen wave = 1

* language (from form_language)
gen language = .
replace language = 1 if form_language=="Chichewa"
replace language = 2 if form_language=="Tumbuka"
replace language = 3 if form_language=="English"
lab def language_lbl 1 "Chichewa" 2 "Tumbuka" 3 "English"
lab val language language_lbl
drop form_language

* date & interview length (start/end are ISO8601 strings)
gen double _s = clock(subinstr(start,"T"," ",1),"YMD#hms#")
gen double _e = clock(subinstr(end,  "T"," ",1),"YMD#hms#")
gen date = dofc(_e)
format date %tdDD_Month_CCYY
gen int_length = (_e - _s)/60000
label var int_length "time difference (minutes)"
drop _s _e start end

* mode  // TODO confirm: 1=F2F, 2=Phone
gen _m = .
replace _m = 1 if mode=="Face to Face"
replace _m = 2 if mode=="Phone"
drop mode
rename _m mode
lab def mode_lbl 1 "Face to Face" 2 "Phone"
lab val mode mode_lbl

*------------------------------------------------------------------------------*
* Demographics & core

* q1 (exact age) from q1b; q1a flags refused/DK
rename q1b q1
capture confirm string variable q1
if !_rc destring q1, replace force
replace q1 = .r if q1a=="Refused to answer"
replace q1 = .d if q1a==`"Don't know"'
drop q1a
lab var q1 "Q1. Respondent's exact age"

* q2 (age group) from agecat (2..8) -> PVS 1..7
gen q2 = agecat - 1
drop agecat ageband
lab def q2_lbl 1 "18 to 29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70-79" 7 "80 or older"
lab val q2 q2_lbl
lab var q2 "Q2. Respondent's age group"

* q3 (gender)
gen q3_n = .
replace q3_n = 0 if q3==`"Male"'
replace q3_n = 1 if q3==`"Female"'
replace q3_n = .a if q3==""
drop q3
rename q3_n q3
lab def q3_lbl 0 "Male" 1 "Female", replace
lab val q3 q3_lbl
lab var q3 "Q3. Gender"

* q4 (region (Malawi))
gen q4_n = .
replace q4_n = 1 if q4==`"Central"'
replace q4_n = 2 if q4==`"Northern"'
replace q4_n = 3 if q4==`"Southern"'
replace q4_n = .a if q4==""
drop q4
rename q4_n q4
lab def q4_lbl 1 "Central" 2 "Northern" 3 "Southern", replace
lab val q4 q4_lbl
lab var q4 "Q4. Region"

* q4_1 (district, Malawi-specific)
encode q4_1, gen(q4_district)
drop q4_1
lab var q4_district "Q4_1. District (Malawi)"

* q5 (residence // TODO confirm PVS coding)
gen q5_n = .
replace q5_n = 1 if q5==`"Urban"'
replace q5_n = 2 if q5==`"Rural"'
replace q5_n = .a if q5==""
drop q5
rename q5_n q5
lab def q5_lbl 1 "Urban" 2 "Rural", replace
lab val q5 q5_lbl
lab var q5 "Q5. Residence"

* q6 (has insurance)
gen q6_n = .
replace q6_n = 0 if q6==`"No"'
replace q6_n = 1 if q6==`"Yes"'
replace q6_n = .r if q6==`"Refused to answer"'
replace q6_n = .r if q6==`"Refused to answer / Blank"'
replace q6_n = .d if q6==`"Don't know"'
replace q6_n = .a if q6==""
drop q6
rename q6_n q6
lab def q6_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q6 q6_lbl
lab var q6 "Q6. Do you have health insurance?"

* q7 (insurance type // TODO confirm codes)
gen q7_n = .
replace q7_n = 1 if q7==`"Health insurance through your or someone else's employer"'
replace q7_n = 2 if q7==`"Privately purchased commercial Insurance"'
replace q7_n = 9 if q7==`"Other (Specify)"'
replace q7_n = .r if q7==`"Refused to answer"'
replace q7_n = .r if q7==`"Refused to answer / Blank"'
replace q7_n = .d if q7==`"Don't know"'
replace q7_n = .a if q7==""
drop q7
rename q7_n q7
lab def q7_lbl 1 "Health insurance through your or someone else's employer" 2 "Privately purchased commercial Insurance" 9 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q7 q7_lbl
lab var q7 "Q7. Type of health insurance"

* q8 (education // TODO confirm collapse)
gen q8_n = .
replace q8_n = 0 if q8==`"No education"'
replace q8_n = 1 if q8==`"Primary school"'
replace q8_n = 2 if q8==`"Secondary school"'
replace q8_n = 3 if q8==`"Tertiary"'
replace q8_n = .a if q8==""
drop q8
rename q8_n q8
lab def q8_lbl 0 "No education" 1 "Primary school" 2 "Secondary school" 3 "Tertiary", replace
lab val q8 q8_lbl
lab var q8 "Q8. Education"

* q8a (ethnicity (Malawi-specific))
gen q8a_n = .
replace q8a_n = 1 if q8a==`"Chichewa"'
replace q8a_n = 2 if q8a==`"Tumbuka"'
replace q8a_n = 3 if q8a==`"Yao"'
replace q8a_n = 4 if q8a==`"Other"'
replace q8a_n = .a if q8a==""
drop q8a
rename q8a_n q8a
lab def q8a_lbl 1 "Chichewa" 2 "Tumbuka" 3 "Yao" 4 "Other", replace
lab val q8a q8a_lbl
lab var q8a "Q8a_mw. Ethnicity"

* q8b (income band (kwacha))
gen q8b_n = .
replace q8b_n = 1 if q8b==`"Less than MK52,000"'
replace q8b_n = 2 if q8b==`"MK52,000 to <MK100,000"'
replace q8b_n = 3 if q8b==`"MK100,000 to <MK500,000"'
replace q8b_n = 4 if q8b==`"MK500,000 to <MK1,000,000"'
replace q8b_n = 5 if q8b==`"MK1,000,000 or more"'
replace q8b_n = .r if q8b==`"Refused to answer"'
replace q8b_n = .r if q8b==`"Refused to answer / Blank"'
replace q8b_n = .d if q8b==`"Don't know"'
replace q8b_n = .a if q8b==""
drop q8b
rename q8b_n q8b
lab def q8b_lbl 1 "Less than MK52,000" 2 "MK52,000 to <MK100,000" 3 "MK100,000 to <MK500,000" 4 "MK500,000 to <MK1,000,000" 5 "MK1,000,000 or more" .a "NA" .r "Refused", replace
lab val q8b q8b_lbl
lab var q8b "Q8b. Monthly income"

* q9 (general health)
gen q9_n = .
replace q9_n = 0 if q9==`"Poor"'
replace q9_n = 1 if q9==`"Fair"'
replace q9_n = 2 if q9==`"Good"'
replace q9_n = 3 if q9==`"Very good"'
replace q9_n = 4 if q9==`"Excellent"'
replace q9_n = .r if q9==`"Refused to answer"'
replace q9_n = .r if q9==`"Refused to answer / Blank"'
replace q9_n = .d if q9==`"Don't know"'
replace q9_n = .a if q9==""
drop q9
rename q9_n q9
lab def q9_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q9 q9_lbl
lab var q9 "Q9. General health"

* q10 (mental health)
gen q10_n = .
replace q10_n = 0 if q10==`"Poor"'
replace q10_n = 1 if q10==`"Fair"'
replace q10_n = 2 if q10==`"Good"'
replace q10_n = 3 if q10==`"Very good"'
replace q10_n = 4 if q10==`"Excellent"'
replace q10_n = .r if q10==`"Refused to answer"'
replace q10_n = .r if q10==`"Refused to answer / Blank"'
replace q10_n = .d if q10==`"Don't know"'
replace q10_n = .a if q10==""
drop q10
rename q10_n q10
lab def q10_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q10 q10_lbl
lab var q10 "Q10. Mental health"

* q11 (longstanding illness)
gen q11_n = .
replace q11_n = 0 if q11==`"No"'
replace q11_n = 1 if q11==`"Yes"'
replace q11_n = .r if q11==`"Refused to answer"'
replace q11_n = .r if q11==`"Refused to answer / Blank"'
replace q11_n = .d if q11==`"Don't know"'
replace q11_n = .a if q11==""
drop q11
rename q11_n q11
lab def q11_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q11 q11_lbl
lab var q11 "Q11. Longstanding illness?"

* q12a (confident managing health)
gen q12a_n = .
replace q12a_n = 0 if q12a==`"Not at all confident"'
replace q12a_n = 1 if q12a==`"Not too confident"'
replace q12a_n = 2 if q12a==`"Somewhat confident"'
replace q12a_n = 3 if q12a==`"Very confident"'
replace q12a_n = .r if q12a==`"Refused to answer"'
replace q12a_n = .r if q12a==`"Refused to answer / Blank"'
replace q12a_n = .d if q12a==`"Don't know"'
replace q12a_n = .a if q12a==""
drop q12a
rename q12a_n q12a
lab def q12a_lbl 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
lab val q12a q12a_lbl
lab var q12a "Q12a. Confident managing health"

* q12b (tell provider concerns)
gen q12b_n = .
replace q12b_n = 0 if q12b==`"Not at all confident"'
replace q12b_n = 1 if q12b==`"Not too confident"'
replace q12b_n = 2 if q12b==`"Somewhat confident"'
replace q12b_n = 3 if q12b==`"Very confident"'
replace q12b_n = .r if q12b==`"Refused to answer"'
replace q12b_n = .r if q12b==`"Refused to answer / Blank"'
replace q12b_n = .d if q12b==`"Don't know"'
replace q12b_n = .a if q12b==""
drop q12b
rename q12b_n q12b
lab def q12b_lbl 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
lab val q12b q12b_lbl
lab var q12b "Q12b. Can tell provider concerns"

* q13 (has usual facility)
gen q13_n = .
replace q13_n = 0 if q13==`"No"'
replace q13_n = 1 if q13==`"Yes"'
replace q13_n = .r if q13==`"Refused to answer"'
replace q13_n = .r if q13==`"Refused to answer / Blank"'
replace q13_n = .d if q13==`"Don't know"'
replace q13_n = .a if q13==""
drop q13
rename q13_n q13
lab def q13_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q13 q13_lbl
lab var q13 "Q13. Usual facility?"

* q14 (facility ownership // TODO)
gen q14_n = .
replace q14_n = 1 if q14==`"Public"'
replace q14_n = 2 if q14==`"Private"'
replace q14_n = 3 if q14==`"Faith-based or NGO"'
replace q14_n = 4 if q14==`"Other (Specify)"'
replace q14_n = .r if q14==`"Refused to answer"'
replace q14_n = .r if q14==`"Refused to answer / Blank"'
replace q14_n = .d if q14==`"Don't know"'
replace q14_n = .a if q14==""
drop q14
rename q14_n q14
lab def q14_lbl 1 "Public" 2 "Private" 3 "Faith-based or NGO" 4 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q14 q14_lbl
lab var q14 "Q14. Facility ownership"

* q15 (facility type // TODO Malawi codes)
gen q15_n = .
replace q15_n = 1 if q15==`"Health post"'
replace q15_n = 2 if q15==`"Health center"'
replace q15_n = 3 if q15==`"Community hospital"'
replace q15_n = 4 if q15==`"District hospital"'
replace q15_n = 5 if q15==`"Central hospital"'
replace q15_n = 6 if q15==`"Private clinic"'
replace q15_n = 7 if q15==`"Private hospital"'
replace q15_n = 8 if q15==`"Other (Specify)"'
replace q15_n = .r if q15==`"Refused to answer"'
replace q15_n = .r if q15==`"Refused to answer / Blank"'
replace q15_n = .d if q15==`"Don't know"'
replace q15_n = .a if q15==""
drop q15
rename q15_n q15
lab def q15_lbl 1 "Health post" 2 "Health center" 3 "Community hospital" 4 "District hospital" 5 "Central hospital" 6 "Private clinic" 7 "Private hospital" 8 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q15 q15_lbl
lab var q15 "Q15. Facility type"

* q16 (reason chose facility)
gen q16_n = .
replace q16_n = 1 if q16==`"Low cost"'
replace q16_n = 2 if q16==`"Short distance"'
replace q16_n = 3 if q16==`"Short waiting time"'
replace q16_n = 4 if q16==`"Good healthcare provider skills"'
replace q16_n = 5 if q16==`"Staff shows respect"'
replace q16_n = 6 if q16==`"Medicines and equipment are available"'
replace q16_n = 7 if q16==`"Only facility available"'
replace q16_n = 8 if q16==`"Covered or assigned by insurance"'
replace q16_n = 9 if q16==`"Other (Specify)"'
replace q16_n = .r if q16==`"Refused to answer"'
replace q16_n = .r if q16==`"Refused to answer / Blank"'
replace q16_n = .d if q16==`"Don't know"'
replace q16_n = .a if q16==""
drop q16
rename q16_n q16
lab def q16_lbl 1 "Low cost" 2 "Short distance" 3 "Short waiting time" 4 "Good healthcare provider skills" 5 "Staff shows respect" 6 "Medicines and equipment are available" 7 "Only facility available" 8 "Covered or assigned by insurance" 9 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q16 q16_lbl
lab var q16 "Q16. Why this facility?"

* q17 (overall quality (5='did not receive'->NA))
gen q17_n = .
replace q17_n = 0 if q17==`"Poor"'
replace q17_n = 1 if q17==`"Fair"'
replace q17_n = 2 if q17==`"Good"'
replace q17_n = 3 if q17==`"Very good"'
replace q17_n = 4 if q17==`"Excellent"'
replace q17_n = .a if q17==`"I did not receive healthcare from this provider in the past 12 months"'
replace q17_n = .r if q17==`"Refused to answer"'
replace q17_n = .r if q17==`"Refused to answer / Blank"'
replace q17_n = .d if q17==`"Don't know"'
replace q17_n = .a if q17==""
drop q17
rename q17_n q17
lab def q17_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q17 q17_lbl
lab var q17 "Q17. Overall quality received"

* q18 (total # visits past 12m) - open numeric
capture confirm string variable q18
if !_rc {
    gen double q18_n = real(q18)
    replace q18_n = .r if strpos(q18,"Refused")>0
    replace q18_n = .d if q18==`"Don't know"'
    drop q18
    rename q18_n q18
}
lab var q18 "Q18. Total healthcare visits past 12 months"

* q19 (visits range)
gen q19_n = .
replace q19_n = 0 if q19==`"0"'
replace q19_n = 1 if q19==`"1 to 4"'
replace q19_n = 2 if q19==`"5 to 9"'
replace q19_n = 3 if q19==`"10 or more"'
replace q19_n = .r if q19==`"Refused to answer"'
replace q19_n = .r if q19==`"Refused to answer / Blank"'
replace q19_n = .d if q19==`"Don't know"'
replace q19_n = .a if q19==""
drop q19
rename q19_n q19
lab def q19_lbl 0 "0" 1 "1 to 4" 2 "5 to 9" 3 "10 or more" .a "NA" .r "Refused", replace
lab val q19 q19_lbl
lab var q19 "Q19. Total visits (range)"

* q20 (all same facility)
gen q20_n = .
replace q20_n = 0 if q20==`"No"'
replace q20_n = 1 if q20==`"Yes"'
replace q20_n = .r if q20==`"Refused to answer"'
replace q20_n = .r if q20==`"Refused to answer / Blank"'
replace q20_n = .d if q20==`"Don't know"'
replace q20_n = .a if q20==""
drop q20
rename q20_n q20
lab def q20_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q20 q20_lbl
lab var q20 "Q20. All visits same facility?"

* q21 (# different facilities) - open numeric
capture confirm string variable q21
if !_rc {
    gen double q21_n = real(q21)
    replace q21_n = .r if strpos(q21,"Refused")>0
    replace q21_n = .d if q21==`"Don't know"'
    drop q21
    rename q21_n q21
}
lab var q21 "Q21. Number of different facilities"

* q22 (# home visits) - open numeric
capture confirm string variable q22
if !_rc {
    gen double q22_n = real(q22)
    replace q22_n = .r if strpos(q22,"Refused")>0
    replace q22_n = .d if q22==`"Don't know"'
    drop q22
    rename q22_n q22
}
lab var q22 "Q22. Home-provider visits"

* q23 (# telemedicine visits) - open numeric
capture confirm string variable q23
if !_rc {
    gen double q23_n = real(q23)
    replace q23_n = .r if strpos(q23,"Refused")>0
    replace q23_n = .d if q23==`"Don't know"'
    drop q23
    rename q23_n q23
}
lab var q23 "Q23. Telemedicine visits"

* q24 (reason last virtual visit)
gen q24_n = .
replace q24_n = 1 if strpos(q24,"Care for an urgent or new health problem")>0
replace q24_n = 2 if strpos(q24,"Follow-up care for a longstanding illness")>0
replace q24_n = 3 if strpos(q24,"Preventive care or a visit to check on your health")>0
replace q24_n = 4 if strpos(q24,"Other")>0
replace q24_n = .r if q24==`"Refused to answer"'
replace q24_n = .r if q24==`"Refused to answer / Blank"'
replace q24_n = .d if q24==`"Don't know"'
replace q24_n = .a if q24==""
drop q24
rename q24_n q24
lab def q24_lbl 1 "Care for an urgent or new health problem" 2 "Follow-up care for a longstanding illness" 3 "Preventive care or a visit to check on your health" 4 "Other" .a "NA" .r "Refused", replace
lab val q24 q24_lbl
lab var q24 "Q24. Reason for last virtual visit"

* q25 (quality last virtual visit)
gen q25_n = .
replace q25_n = 0 if q25==`"Poor"'
replace q25_n = 1 if q25==`"Fair"'
replace q25_n = 2 if q25==`"Good"'
replace q25_n = 3 if q25==`"Very good"'
replace q25_n = 4 if q25==`"Excellent"'
replace q25_n = .r if q25==`"Refused to answer"'
replace q25_n = .r if q25==`"Refused to answer / Blank"'
replace q25_n = .d if q25==`"Don't know"'
replace q25_n = .a if q25==""
drop q25
rename q25_n q25
lab def q25_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q25 q25_lbl
lab var q25 "Q25. Quality of last telemedicine visit"

* q26 (stayed overnight)
gen q26_n = .
replace q26_n = 0 if q26==`"No"'
replace q26_n = 1 if q26==`"Yes"'
replace q26_n = .r if q26==`"Refused to answer"'
replace q26_n = .r if q26==`"Refused to answer / Blank"'
replace q26_n = .d if q26==`"Don't know"'
replace q26_n = .a if q26==""
drop q26
rename q26_n q26
lab def q26_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q26 q26_lbl
lab var q26 "Q26. Inpatient stay past 12m?"

* q27a (Blood pressure)
gen q27a_n = .
replace q27a_n = 0 if q27a==`"No"'
replace q27a_n = 1 if q27a==`"Yes"'
replace q27a_n = .r if q27a==`"Refused to answer"'
replace q27a_n = .r if q27a==`"Refused to answer / Blank"'
replace q27a_n = .d if q27a==`"Don't know"'
replace q27a_n = .a if q27a==""
drop q27a
rename q27a_n q27a
lab def q27a_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27a q27a_lbl
lab var q27a "Q27. Blood pressure"

* q27b (Mammogram)
gen q27b_n = .
replace q27b_n = 0 if q27b==`"No"'
replace q27b_n = 1 if q27b==`"Yes"'
replace q27b_n = .r if q27b==`"Refused to answer"'
replace q27b_n = .r if q27b==`"Refused to answer / Blank"'
replace q27b_n = .d if q27b==`"Don't know"'
replace q27b_n = .a if q27b==""
drop q27b
rename q27b_n q27b
lab def q27b_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27b q27b_lbl
lab var q27b "Q27. Mammogram"

* q27c (Cervical cancer screen)
gen q27c_n = .
replace q27c_n = 0 if q27c==`"No"'
replace q27c_n = 1 if q27c==`"Yes"'
replace q27c_n = .r if q27c==`"Refused to answer"'
replace q27c_n = .r if q27c==`"Refused to answer / Blank"'
replace q27c_n = .d if q27c==`"Don't know"'
replace q27c_n = .a if q27c==""
drop q27c
rename q27c_n q27c
lab def q27c_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27c q27c_lbl
lab var q27c "Q27. Cervical cancer screen"

* q27d (Eyes/vision)
gen q27d_n = .
replace q27d_n = 0 if q27d==`"No"'
replace q27d_n = 1 if q27d==`"Yes"'
replace q27d_n = .r if q27d==`"Refused to answer"'
replace q27d_n = .r if q27d==`"Refused to answer / Blank"'
replace q27d_n = .d if q27d==`"Don't know"'
replace q27d_n = .a if q27d==""
drop q27d
rename q27d_n q27d
lab def q27d_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27d q27d_lbl
lab var q27d "Q27. Eyes/vision"

* q27e (Teeth)
gen q27e_n = .
replace q27e_n = 0 if q27e==`"No"'
replace q27e_n = 1 if q27e==`"Yes"'
replace q27e_n = .r if q27e==`"Refused to answer"'
replace q27e_n = .r if q27e==`"Refused to answer / Blank"'
replace q27e_n = .d if q27e==`"Don't know"'
replace q27e_n = .a if q27e==""
drop q27e
rename q27e_n q27e
lab def q27e_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27e q27e_lbl
lab var q27e "Q27. Teeth"

* q27f (Blood sugar)
gen q27f_n = .
replace q27f_n = 0 if q27f==`"No"'
replace q27f_n = 1 if q27f==`"Yes"'
replace q27f_n = .r if q27f==`"Refused to answer"'
replace q27f_n = .r if q27f==`"Refused to answer / Blank"'
replace q27f_n = .d if q27f==`"Don't know"'
replace q27f_n = .a if q27f==""
drop q27f
rename q27f_n q27f
lab def q27f_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27f q27f_lbl
lab var q27f "Q27. Blood sugar"

* q27g (Blood cholesterol)
gen q27g_n = .
replace q27g_n = 0 if q27g==`"No"'
replace q27g_n = 1 if q27g==`"Yes"'
replace q27g_n = .r if q27g==`"Refused to answer"'
replace q27g_n = .r if q27g==`"Refused to answer / Blank"'
replace q27g_n = .d if q27g==`"Don't know"'
replace q27g_n = .a if q27g==""
drop q27g
rename q27g_n q27g
lab def q27g_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27g q27g_lbl
lab var q27g "Q27. Blood cholesterol"

* q27h (Mental health care)
gen q27h_n = .
replace q27h_n = 0 if q27h==`"No"'
replace q27h_n = 1 if q27h==`"Yes"'
replace q27h_n = .r if q27h==`"Refused to answer"'
replace q27h_n = .r if q27h==`"Refused to answer / Blank"'
replace q27h_n = .d if q27h==`"Don't know"'
replace q27h_n = .a if q27h==""
drop q27h
rename q27h_n q27h
lab def q27h_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q27h q27h_lbl
lab var q27h "Q27. Mental health care"

* q28a (medical mistake)
gen q28a_n = .
replace q28a_n = 0 if q28a==`"No"'
replace q28a_n = 1 if q28a==`"Yes"'
replace q28a_n = .r if q28a==`"Refused to answer"'
replace q28a_n = .r if q28a==`"Refused to answer / Blank"'
replace q28a_n = .d if q28a==`"Don't know"'
replace q28a_n = .a if q28a==""
drop q28a
rename q28a_n q28a
lab def q28a_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q28a q28a_lbl
lab var q28a "Q28a. Medical mistake made?"

* q28b (treated unfairly/discriminated)
gen q28b_n = .
replace q28b_n = 0 if q28b==`"No"'
replace q28b_n = 1 if q28b==`"Yes"'
replace q28b_n = .r if q28b==`"Refused to answer"'
replace q28b_n = .r if q28b==`"Refused to answer / Blank"'
replace q28b_n = .d if q28b==`"Don't know"'
replace q28b_n = .a if q28b==""
drop q28b
rename q28b_n q28b
lab def q28b_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q28b q28b_lbl
lab var q28b "Q28b. Treated unfairly/discriminated?"

* q29 (needed care but did not get)
gen q29_n = .
replace q29_n = 0 if q29==`"No"'
replace q29_n = 1 if q29==`"Yes"'
replace q29_n = .r if q29==`"Refused to answer"'
replace q29_n = .r if q29==`"Refused to answer / Blank"'
replace q29_n = .d if q29==`"Don't know"'
replace q29_n = .a if q29==""
drop q29
rename q29_n q29
lab def q29_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q29 q29_lbl
lab var q29 "Q29. Needed care but did not get it?"

* q30 (reason did not receive care)
gen q30_n = .
replace q30_n = 1 if strpos(q30,"High cost")>0
replace q30_n = 2 if strpos(q30,"Far distance")>0
replace q30_n = 3 if strpos(q30,"Long wait time")>0
replace q30_n = 4 if strpos(q30,"Poor healthcare provider skills")>0
replace q30_n = 5 if strpos(q30,"show respect")>0
replace q30_n = 6 if strpos(q30,"Medicines and equipment are not available")>0
replace q30_n = 7 if strpos(q30,"Illness not serious enough")>0
replace q30_n = 10 if strpos(q30,"Other")>0
replace q30_n = .r if q30==`"Refused to answer"'
replace q30_n = .r if q30==`"Refused to answer / Blank"'
replace q30_n = .d if q30==`"Don't know"'
replace q30_n = .a if q30==""
drop q30
rename q30_n q30
lab def q30_lbl 1 "High cost" 2 "Far distance" 3 "Long wait time" 4 "Poor healthcare provider skills" 5 "show respect" 6 "Medicines and equipment are not available" 7 "Illness not serious enough" 10 "Other" .a "NA" .r "Refused", replace
lab val q30 q30_lbl
lab var q30 "Q30. Main reason care not received"

* q31a (borrow money for care)
gen q31a_n = .
replace q31a_n = 0 if q31a==`"No"'
replace q31a_n = 1 if q31a==`"Yes"'
replace q31a_n = .r if q31a==`"Refused to answer"'
replace q31a_n = .r if q31a==`"Refused to answer / Blank"'
replace q31a_n = .d if q31a==`"Don't know"'
replace q31a_n = .a if q31a==""
drop q31a
rename q31a_n q31a
lab def q31a_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q31a q31a_lbl
lab var q31a "Q31a. Borrowed money for healthcare"

* q31b (sell items for care)
gen q31b_n = .
replace q31b_n = 0 if q31b==`"No"'
replace q31b_n = 1 if q31b==`"Yes"'
replace q31b_n = .r if q31b==`"Refused to answer"'
replace q31b_n = .r if q31b==`"Refused to answer / Blank"'
replace q31b_n = .d if q31b==`"Don't know"'
replace q31b_n = .a if q31b==""
drop q31b
rename q31b_n q31b
lab def q31b_lbl 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
lab val q31b q31b_lbl
lab var q31b "Q31b. Sold items for healthcare"

* q32 (facility ownership (last visit) // TODO)
gen q32_n = .
replace q32_n = 1 if q32==`"Public"'
replace q32_n = 2 if q32==`"Private"'
replace q32_n = 3 if q32==`"Faith-based or NGO"'
replace q32_n = .r if q32==`"Refused to answer"'
replace q32_n = .r if q32==`"Refused to answer / Blank"'
replace q32_n = .d if q32==`"Don't know"'
replace q32_n = .a if q32==""
drop q32
rename q32_n q32
lab def q32_lbl 1 "Public" 2 "Private" 3 "Faith-based or NGO" .a "NA" .r "Refused", replace
lab val q32 q32_lbl
lab var q32 "Q32. Facility ownership (visit)"

* q33 (facility type (last visit) // TODO)
gen q33_n = .
replace q33_n = 1 if q33==`"Health post"'
replace q33_n = 2 if q33==`"Health center"'
replace q33_n = 3 if q33==`"Community hospital"'
replace q33_n = 4 if q33==`"District hospital"'
replace q33_n = 5 if q33==`"Central hospital"'
replace q33_n = 6 if q33==`"Private clinic"'
replace q33_n = 7 if q33==`"Private hospital"'
replace q33_n = 8 if q33==`"Other (Specify)"'
replace q33_n = .r if q33==`"Refused to answer"'
replace q33_n = .r if q33==`"Refused to answer / Blank"'
replace q33_n = .d if q33==`"Don't know"'
replace q33_n = .a if q33==""
drop q33
rename q33_n q33
lab def q33_lbl 1 "Health post" 2 "Health center" 3 "Community hospital" 4 "District hospital" 5 "Central hospital" 6 "Private clinic" 7 "Private hospital" 8 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q33 q33_lbl
lab var q33 "Q33. Facility type (visit)"

* q34 (main reason for visit)
gen q34_n = .
replace q34_n = 1 if strpos(q34,"Care for an urgent or new health problem")>0
replace q34_n = 2 if strpos(q34,"Follow-up care for a longstanding illness")>0
replace q34_n = 3 if strpos(q34,"Preventive care or a visit to check on your health")>0
replace q34_n = 4 if strpos(q34,"Other (Specify)")>0
replace q34_n = .r if q34==`"Refused to answer"'
replace q34_n = .r if q34==`"Refused to answer / Blank"'
replace q34_n = .d if q34==`"Don't know"'
replace q34_n = .a if q34==""
drop q34
rename q34_n q34
lab def q34_lbl 1 "Care for an urgent or new health problem" 2 "Follow-up care for a longstanding illness" 3 "Preventive care or a visit to check on your health" 4 "Other (Specify)" .a "NA" .r "Refused", replace
lab val q34 q34_lbl
lab var q34 "Q34. Main reason for visit"

* q35 (appointment or walk-in)
gen q35_n = .
replace q35_n = 0 if q35==`"I went without an appointment"'
replace q35_n = 1 if q35==`"I made an appointment"'
replace q35_n = .r if q35==`"Refused to answer"'
replace q35_n = .r if q35==`"Refused to answer / Blank"'
replace q35_n = .d if q35==`"Don't know"'
replace q35_n = .a if q35==""
drop q35
rename q35_n q35
lab def q35_lbl 0 "I went without an appointment" 1 "I made an appointment" .a "NA" .r "Refused", replace
lab val q35 q35_lbl
lab var q35 "Q35. Scheduled vs walk-in"

* q36 (wait to appointment)
gen q36_n = .
replace q36_n = 1 if q36==`"Same or next day"'
replace q36_n = 2 if q36==`"2 days to less than one week"'
replace q36_n = 3 if q36==`"1 week to less than 2 weeks"'
replace q36_n = 4 if q36==`"2 weeks to less than 1 month"'
replace q36_n = 5 if q36==`"1 month to less than 2 months"'
replace q36_n = 6 if q36==`"2 months to less than 3 months"'
replace q36_n = 7 if q36==`"3 months to less than 6 months"'
replace q36_n = 8 if q36==`"6 months or more"'
replace q36_n = .r if q36==`"Refused to answer"'
replace q36_n = .r if q36==`"Refused to answer / Blank"'
replace q36_n = .d if q36==`"Don't know"'
replace q36_n = .a if q36==""
drop q36
rename q36_n q36
lab def q36_lbl 1 "Same or next day" 2 "2 days to less than one week" 3 "1 week to less than 2 weeks" 4 "2 weeks to less than 1 month" 5 "1 month to less than 2 months" 6 "2 months to less than 3 months" 7 "3 months to less than 6 months" 8 "6 months or more" .a "NA" .r "Refused", replace
lab val q36 q36_lbl
lab var q36 "Q36. Wait between appointment and visit"

* q37 (wait at facility)
gen q37_n = .
replace q37_n = 1 if strpos(q37,"Less than 15 minutes")>0
replace q37_n = 2 if strpos(q37,"15 minutes to less than 30 minutes")>0
replace q37_n = 3 if strpos(q37,"30 minutes to less than 1 hour")>0
replace q37_n = 4 if strpos(q37,"1 hour to less than 2 hours")>0
replace q37_n = 5 if strpos(q37,"2 hours to less than 3 hours")>0
replace q37_n = 6 if strpos(q37,"3 hours to less than 4 hours")>0
replace q37_n = 7 if strpos(q37,"More than 4 hours")>0
replace q37_n = .r if q37==`"Refused to answer"'
replace q37_n = .r if q37==`"Refused to answer / Blank"'
replace q37_n = .d if q37==`"Don't know"'
replace q37_n = .a if q37==""
drop q37
rename q37_n q37
lab def q37_lbl 1 "Less than 15 minutes" 2 "15 minutes to less than 30 minutes" 3 "30 minutes to less than 1 hour" 4 "1 hour to less than 2 hours" 5 "2 hours to less than 3 hours" 6 "3 hours to less than 4 hours" 7 "More than 4 hours" .a "NA" .r "Refused", replace
lab val q37 q37_lbl
lab var q37 "Q37. Wait before being seen"

* q37_specify_hours - open numeric (hours, when 'More than 4 hours')
capture confirm string variable q37_specify_hours
if !_rc destring q37_specify_hours, replace force
lab var q37_specify_hours "Q37. Specify number of hours"

* q38a (overall quality)
gen q38a_n = .
replace q38a_n = 0 if q38a==`"Poor"'
replace q38a_n = 1 if q38a==`"Fair"'
replace q38a_n = 2 if q38a==`"Good"'
replace q38a_n = 3 if q38a==`"Very good"'
replace q38a_n = 4 if q38a==`"Excellent"'
replace q38a_n = 5 if q38a==`"I have not had prior visits or tests"'
replace q38a_n = 6 if q38a==`"The clinic had no other staff"'
replace q38a_n = .r if q38a==`"Refused to answer"'
replace q38a_n = .r if q38a==`"Refused to answer / Blank"'
replace q38a_n = .d if q38a==`"Don't know"'
replace q38a_n = .a if q38a==""
drop q38a
rename q38a_n q38a
lab def q38a_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38a q38a_lbl
lab var q38a "Q38. overall quality"

* q38b (knowledge/skills)
gen q38b_n = .
replace q38b_n = 0 if q38b==`"Poor"'
replace q38b_n = 1 if q38b==`"Fair"'
replace q38b_n = 2 if q38b==`"Good"'
replace q38b_n = 3 if q38b==`"Very good"'
replace q38b_n = 4 if q38b==`"Excellent"'
replace q38b_n = 5 if q38b==`"I have not had prior visits or tests"'
replace q38b_n = 6 if q38b==`"The clinic had no other staff"'
replace q38b_n = .r if q38b==`"Refused to answer"'
replace q38b_n = .r if q38b==`"Refused to answer / Blank"'
replace q38b_n = .d if q38b==`"Don't know"'
replace q38b_n = .a if q38b==""
drop q38b
rename q38b_n q38b
lab def q38b_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38b q38b_lbl
lab var q38b "Q38. knowledge/skills"

* q38c (equipment/supplies)
gen q38c_n = .
replace q38c_n = 0 if q38c==`"Poor"'
replace q38c_n = 1 if q38c==`"Fair"'
replace q38c_n = 2 if q38c==`"Good"'
replace q38c_n = 3 if q38c==`"Very good"'
replace q38c_n = 4 if q38c==`"Excellent"'
replace q38c_n = 5 if q38c==`"I have not had prior visits or tests"'
replace q38c_n = 6 if q38c==`"The clinic had no other staff"'
replace q38c_n = .r if q38c==`"Refused to answer"'
replace q38c_n = .r if q38c==`"Refused to answer / Blank"'
replace q38c_n = .d if q38c==`"Don't know"'
replace q38c_n = .a if q38c==""
drop q38c
rename q38c_n q38c
lab def q38c_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38c q38c_lbl
lab var q38c "Q38. equipment/supplies"

* q38d (respect)
gen q38d_n = .
replace q38d_n = 0 if q38d==`"Poor"'
replace q38d_n = 1 if q38d==`"Fair"'
replace q38d_n = 2 if q38d==`"Good"'
replace q38d_n = 3 if q38d==`"Very good"'
replace q38d_n = 4 if q38d==`"Excellent"'
replace q38d_n = 5 if q38d==`"I have not had prior visits or tests"'
replace q38d_n = 6 if q38d==`"The clinic had no other staff"'
replace q38d_n = .r if q38d==`"Refused to answer"'
replace q38d_n = .r if q38d==`"Refused to answer / Blank"'
replace q38d_n = .d if q38d==`"Don't know"'
replace q38d_n = .a if q38d==""
drop q38d
rename q38d_n q38d
lab def q38d_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38d q38d_lbl
lab var q38d "Q38. respect"

* q38e (medical history knowledge)
gen q38e_n = .
replace q38e_n = 0 if q38e==`"Poor"'
replace q38e_n = 1 if q38e==`"Fair"'
replace q38e_n = 2 if q38e==`"Good"'
replace q38e_n = 3 if q38e==`"Very good"'
replace q38e_n = 4 if q38e==`"Excellent"'
replace q38e_n = 5 if q38e==`"I have not had prior visits or tests"'
replace q38e_n = 6 if q38e==`"The clinic had no other staff"'
replace q38e_n = .r if q38e==`"Refused to answer"'
replace q38e_n = .r if q38e==`"Refused to answer / Blank"'
replace q38e_n = .d if q38e==`"Don't know"'
replace q38e_n = .a if q38e==""
drop q38e
rename q38e_n q38e
lab def q38e_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38e q38e_lbl
lab var q38e "Q38. medical history knowledge"

* q38f (explained clearly)
gen q38f_n = .
replace q38f_n = 0 if q38f==`"Poor"'
replace q38f_n = 1 if q38f==`"Fair"'
replace q38f_n = 2 if q38f==`"Good"'
replace q38f_n = 3 if q38f==`"Very good"'
replace q38f_n = 4 if q38f==`"Excellent"'
replace q38f_n = 5 if q38f==`"I have not had prior visits or tests"'
replace q38f_n = 6 if q38f==`"The clinic had no other staff"'
replace q38f_n = .r if q38f==`"Refused to answer"'
replace q38f_n = .r if q38f==`"Refused to answer / Blank"'
replace q38f_n = .d if q38f==`"Don't know"'
replace q38f_n = .a if q38f==""
drop q38f
rename q38f_n q38f
lab def q38f_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38f q38f_lbl
lab var q38f "Q38. explained clearly"

* q38g (involved in decisions)
gen q38g_n = .
replace q38g_n = 0 if q38g==`"Poor"'
replace q38g_n = 1 if q38g==`"Fair"'
replace q38g_n = 2 if q38g==`"Good"'
replace q38g_n = 3 if q38g==`"Very good"'
replace q38g_n = 4 if q38g==`"Excellent"'
replace q38g_n = 5 if q38g==`"I have not had prior visits or tests"'
replace q38g_n = 6 if q38g==`"The clinic had no other staff"'
replace q38g_n = .r if q38g==`"Refused to answer"'
replace q38g_n = .r if q38g==`"Refused to answer / Blank"'
replace q38g_n = .d if q38g==`"Don't know"'
replace q38g_n = .a if q38g==""
drop q38g
rename q38g_n q38g
lab def q38g_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38g q38g_lbl
lab var q38g "Q38. involved in decisions"

* q38h (time spent)
gen q38h_n = .
replace q38h_n = 0 if q38h==`"Poor"'
replace q38h_n = 1 if q38h==`"Fair"'
replace q38h_n = 2 if q38h==`"Good"'
replace q38h_n = 3 if q38h==`"Very good"'
replace q38h_n = 4 if q38h==`"Excellent"'
replace q38h_n = 5 if q38h==`"I have not had prior visits or tests"'
replace q38h_n = 6 if q38h==`"The clinic had no other staff"'
replace q38h_n = .r if q38h==`"Refused to answer"'
replace q38h_n = .r if q38h==`"Refused to answer / Blank"'
replace q38h_n = .d if q38h==`"Don't know"'
replace q38h_n = .a if q38h==""
drop q38h
rename q38h_n q38h
lab def q38h_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38h q38h_lbl
lab var q38h "Q38. time spent"

* q38i (wait time)
gen q38i_n = .
replace q38i_n = 0 if q38i==`"Poor"'
replace q38i_n = 1 if q38i==`"Fair"'
replace q38i_n = 2 if q38i==`"Good"'
replace q38i_n = 3 if q38i==`"Very good"'
replace q38i_n = 4 if q38i==`"Excellent"'
replace q38i_n = 5 if q38i==`"I have not had prior visits or tests"'
replace q38i_n = 6 if q38i==`"The clinic had no other staff"'
replace q38i_n = .r if q38i==`"Refused to answer"'
replace q38i_n = .r if q38i==`"Refused to answer / Blank"'
replace q38i_n = .d if q38i==`"Don't know"'
replace q38i_n = .a if q38i==""
drop q38i
rename q38i_n q38i
lab def q38i_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38i q38i_lbl
lab var q38i "Q38. wait time"

* q38j (courtesy/helpfulness)
gen q38j_n = .
replace q38j_n = 0 if q38j==`"Poor"'
replace q38j_n = 1 if q38j==`"Fair"'
replace q38j_n = 2 if q38j==`"Good"'
replace q38j_n = 3 if q38j==`"Very good"'
replace q38j_n = 4 if q38j==`"Excellent"'
replace q38j_n = 5 if q38j==`"I have not had prior visits or tests"'
replace q38j_n = 6 if q38j==`"The clinic had no other staff"'
replace q38j_n = .r if q38j==`"Refused to answer"'
replace q38j_n = .r if q38j==`"Refused to answer / Blank"'
replace q38j_n = .d if q38j==`"Don't know"'
replace q38j_n = .a if q38j==""
drop q38j
rename q38j_n q38j
lab def q38j_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38j q38j_lbl
lab var q38j "Q38. courtesy/helpfulness"

* q38k (wait to appointment)
gen q38k_n = .
replace q38k_n = 0 if q38k==`"Poor"'
replace q38k_n = 1 if q38k==`"Fair"'
replace q38k_n = 2 if q38k==`"Good"'
replace q38k_n = 3 if q38k==`"Very good"'
replace q38k_n = 4 if q38k==`"Excellent"'
replace q38k_n = 5 if q38k==`"I have not had prior visits or tests"'
replace q38k_n = 6 if q38k==`"The clinic had no other staff"'
replace q38k_n = .r if q38k==`"Refused to answer"'
replace q38k_n = .r if q38k==`"Refused to answer / Blank"'
replace q38k_n = .d if q38k==`"Don't know"'
replace q38k_n = .a if q38k==""
drop q38k
rename q38k_n q38k
lab def q38k_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
lab val q38k q38k_lbl
lab var q38k "Q38. wait to appointment"

* q39 (recommend 0-10) - open numeric
capture confirm string variable q39
if !_rc {
    gen double q39_n = real(q39)
    replace q39_n = .r if strpos(q39,"Refused")>0
    replace q39_n = .d if q39==`"Don't know"'
    drop q39
    rename q39_n q39
}
lab var q39 "Q39. Likelihood to recommend (0-10)"

* q40a (care for pregnant women)
gen q40a_n = .
replace q40a_n = 0 if q40a==`"Poor"'
replace q40a_n = 1 if q40a==`"Fair"'
replace q40a_n = 2 if q40a==`"Good"'
replace q40a_n = 3 if q40a==`"Very good"'
replace q40a_n = 4 if q40a==`"Excellent"'
replace q40a_n = .r if q40a==`"Refused to answer"'
replace q40a_n = .r if q40a==`"Refused to answer / Blank"'
replace q40a_n = .d if q40a==`"I am unable to judge"'
replace q40a_n = .d if q40a==`"Don't know"'
replace q40a_n = .a if q40a==""
drop q40a
rename q40a_n q40a
lab def q40a_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q40a q40a_lbl
lab var q40a "Q40. care for pregnant women"

* q40b (care for children)
gen q40b_n = .
replace q40b_n = 0 if q40b==`"Poor"'
replace q40b_n = 1 if q40b==`"Fair"'
replace q40b_n = 2 if q40b==`"Good"'
replace q40b_n = 3 if q40b==`"Very good"'
replace q40b_n = 4 if q40b==`"Excellent"'
replace q40b_n = .r if q40b==`"Refused to answer"'
replace q40b_n = .r if q40b==`"Refused to answer / Blank"'
replace q40b_n = .d if q40b==`"I am unable to judge"'
replace q40b_n = .d if q40b==`"Don't know"'
replace q40b_n = .a if q40b==""
drop q40b
rename q40b_n q40b
lab def q40b_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q40b q40b_lbl
lab var q40b "Q40. care for children"

* q40c (care for chronic conditions)
gen q40c_n = .
replace q40c_n = 0 if q40c==`"Poor"'
replace q40c_n = 1 if q40c==`"Fair"'
replace q40c_n = 2 if q40c==`"Good"'
replace q40c_n = 3 if q40c==`"Very good"'
replace q40c_n = 4 if q40c==`"Excellent"'
replace q40c_n = .r if q40c==`"Refused to answer"'
replace q40c_n = .r if q40c==`"Refused to answer / Blank"'
replace q40c_n = .d if q40c==`"I am unable to judge"'
replace q40c_n = .d if q40c==`"Don't know"'
replace q40c_n = .a if q40c==""
drop q40c
rename q40c_n q40c
lab def q40c_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q40c q40c_lbl
lab var q40c "Q40. care for chronic conditions"

* q40d (care for mental health)
gen q40d_n = .
replace q40d_n = 0 if q40d==`"Poor"'
replace q40d_n = 1 if q40d==`"Fair"'
replace q40d_n = 2 if q40d==`"Good"'
replace q40d_n = 3 if q40d==`"Very good"'
replace q40d_n = 4 if q40d==`"Excellent"'
replace q40d_n = .r if q40d==`"Refused to answer"'
replace q40d_n = .r if q40d==`"Refused to answer / Blank"'
replace q40d_n = .d if q40d==`"I am unable to judge"'
replace q40d_n = .d if q40d==`"Don't know"'
replace q40d_n = .a if q40d==""
drop q40d
rename q40d_n q40d
lab def q40d_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q40d q40d_lbl
lab var q40d "Q40. care for mental health"

* q41a (confident get good care if sick)
gen q41a_n = .
replace q41a_n = 0 if q41a==`"Not at all confident"'
replace q41a_n = 1 if q41a==`"Not too confident"'
replace q41a_n = 2 if q41a==`"Somewhat confident"'
replace q41a_n = 3 if q41a==`"Very confident"'
replace q41a_n = .r if q41a==`"Refused to answer"'
replace q41a_n = .r if q41a==`"Refused to answer / Blank"'
replace q41a_n = .d if q41a==`"Don't know"'
replace q41a_n = .a if q41a==""
drop q41a
rename q41a_n q41a
lab def q41a_lbl 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
lab val q41a q41a_lbl
lab var q41a "Q41a. Confident get good care if sick"

* q41b (confident afford care)
gen q41b_n = .
replace q41b_n = 0 if q41b==`"Not at all confident"'
replace q41b_n = 1 if q41b==`"Not too confident"'
replace q41b_n = 2 if q41b==`"Somewhat confident"'
replace q41b_n = 3 if q41b==`"Very confident"'
replace q41b_n = .r if q41b==`"Refused to answer"'
replace q41b_n = .r if q41b==`"Refused to answer / Blank"'
replace q41b_n = .d if q41b==`"Don't know"'
replace q41b_n = .a if q41b==""
drop q41b
rename q41b_n q41b
lab def q41b_lbl 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
lab val q41b q41b_lbl
lab var q41b "Q41b. Confident afford care"

* q41c (confident govt considers opinion)
gen q41c_n = .
replace q41c_n = 0 if q41c==`"Not at all confident"'
replace q41c_n = 1 if q41c==`"Not too confident"'
replace q41c_n = 2 if q41c==`"Somewhat confident"'
replace q41c_n = 3 if q41c==`"Very confident"'
replace q41c_n = .r if q41c==`"Refused to answer"'
replace q41c_n = .r if q41c==`"Refused to answer / Blank"'
replace q41c_n = .d if q41c==`"Don't know"'
replace q41c_n = .a if q41c==""
drop q41c
rename q41c_n q41c
lab def q41c_lbl 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
lab val q41c q41c_lbl
lab var q41c "Q41c. Confident govt considers public opinion"

* q42 (quality public system)
gen q42_n = .
replace q42_n = 0 if q42==`"Poor"'
replace q42_n = 1 if q42==`"Fair"'
replace q42_n = 2 if q42==`"Good"'
replace q42_n = 3 if q42==`"Very good"'
replace q42_n = 4 if q42==`"Excellent"'
replace q42_n = .r if q42==`"Refused to answer"'
replace q42_n = .r if q42==`"Refused to answer / Blank"'
replace q42_n = .d if q42==`"Don't know"'
replace q42_n = .a if q42==""
drop q42
rename q42_n q42
lab def q42_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q42 q42_lbl
lab var q42 "Q42. Quality of public health system"

* q43 (quality private system)
gen q43_n = .
replace q43_n = 0 if q43==`"Poor"'
replace q43_n = 1 if q43==`"Fair"'
replace q43_n = 2 if q43==`"Good"'
replace q43_n = 3 if q43==`"Very good"'
replace q43_n = 4 if q43==`"Excellent"'
replace q43_n = .r if q43==`"Refused to answer"'
replace q43_n = .r if q43==`"Refused to answer / Blank"'
replace q43_n = .d if q43==`"Don't know"'
replace q43_n = .a if q43==""
drop q43
rename q43_n q43
lab def q43_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q43 q43_lbl
lab var q43 "Q43. Quality of private health system"

* q44 (quality overall system)
gen q44_n = .
replace q44_n = 0 if q44==`"Poor"'
replace q44_n = 1 if q44==`"Fair"'
replace q44_n = 2 if q44==`"Good"'
replace q44_n = 3 if q44==`"Very good"'
replace q44_n = 4 if q44==`"Excellent"'
replace q44_n = .r if q44==`"Refused to answer"'
replace q44_n = .r if q44==`"Refused to answer / Blank"'
replace q44_n = .d if q44==`"Don't know"'
replace q44_n = .a if q44==""
drop q44
rename q44_n q44
lab def q44_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q44 q44_lbl
lab var q44 "Q44. Quality of overall health system"

* q45 (system better/same/worse)
gen q45_n = .
replace q45_n = 0 if q45==`"Getting worse"'
replace q45_n = 1 if q45==`"Staying the same"'
replace q45_n = 2 if q45==`"Getting better"'
replace q45_n = .r if q45==`"Refused to answer"'
replace q45_n = .r if q45==`"Refused to answer / Blank"'
replace q45_n = .d if q45==`"Don't know"'
replace q45_n = .a if q45==""
drop q45
rename q45_n q45
lab def q45_lbl 0 "Getting worse" 1 "Staying the same" 2 "Getting better" .a "NA" .r "Refused", replace
lab val q45 q45_lbl
lab var q45 "Q45. System trajectory"

* q46 (statement agree most)
gen q46_n = .
replace q46_n = 1 if strpos(q46,"Number 1")>0
replace q46_n = 2 if strpos(q46,"Number 2")>0
replace q46_n = 3 if strpos(q46,"Number 3")>0
replace q46_n = .r if q46==`"Refused to answer"'
replace q46_n = .r if q46==`"Refused to answer / Blank"'
replace q46_n = .d if q46==`"Don't know"'
replace q46_n = .a if q46==""
drop q46
rename q46_n q46
lab def q46_lbl 1 "Number 1" 2 "Number 2" 3 "Number 3" .a "NA" .r "Refused", replace
lab val q46 q46_lbl
lab var q46 "Q46. Statement agreed with"

* q47 (govt COVID management)
gen q47_n = .
replace q47_n = 0 if q47==`"Poor"'
replace q47_n = 1 if q47==`"Fair"'
replace q47_n = 2 if q47==`"Good"'
replace q47_n = 3 if q47==`"Very good"'
replace q47_n = 4 if q47==`"Excellent"'
replace q47_n = .r if q47==`"Refused to answer"'
replace q47_n = .r if q47==`"Refused to answer / Blank"'
replace q47_n = .d if q47==`"Don't know"'
replace q47_n = .a if q47==""
drop q47
rename q47_n q47
lab def q47_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q47 q47_lbl
lab var q47 "Q47. Govt COVID management"

* q48 (govt management (other))
gen q48_n = .
replace q48_n = 0 if q48==`"Poor"'
replace q48_n = 1 if q48==`"Fair"'
replace q48_n = 2 if q48==`"Good"'
replace q48_n = 3 if q48==`"Very good"'
replace q48_n = 4 if q48==`"Excellent"'
replace q48_n = .r if q48==`"Refused to answer"'
replace q48_n = .r if q48==`"Refused to answer / Blank"'
replace q48_n = .d if q48==`"Don't know"'
replace q48_n = .a if q48==""
drop q48
rename q48_n q48
lab def q48_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q48 q48_lbl
lab var q48 "Q48. Govt management rating"

* q49 (vignette 1)
gen q49_n = .
replace q49_n = 0 if q49==`"Poor"'
replace q49_n = 1 if q49==`"Fair"'
replace q49_n = 2 if q49==`"Good"'
replace q49_n = 3 if q49==`"Very good"'
replace q49_n = 4 if q49==`"Excellent"'
replace q49_n = .r if q49==`"Refused to answer"'
replace q49_n = .r if q49==`"Refused to answer / Blank"'
replace q49_n = .d if q49==`"Don't know"'
replace q49_n = .a if q49==""
drop q49
rename q49_n q49
lab def q49_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q49 q49_lbl
lab var q49 "Q49. Vignette quality (option 1)"

* q50 (vignette 2)
gen q50_n = .
replace q50_n = 0 if q50==`"Poor"'
replace q50_n = 1 if q50==`"Fair"'
replace q50_n = 2 if q50==`"Good"'
replace q50_n = 3 if q50==`"Very good"'
replace q50_n = 4 if q50==`"Excellent"'
replace q50_n = .r if q50==`"Refused to answer"'
replace q50_n = .r if q50==`"Refused to answer / Blank"'
replace q50_n = .d if q50==`"Don't know"'
replace q50_n = .a if q50==""
drop q50
rename q50_n q50
lab def q50_lbl 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
lab val q50 q50_lbl
lab var q50 "Q50. Vignette quality (option 2)"

*------------------------------------------------------------------------------*
* Check for implausible values (mirrors JP script)
gen q18_q19 = q18
replace q18_q19 = 0   if missing(q18_q19) & q19==0
replace q18_q19 = 2.5 if missing(q18_q19) & q19==1
replace q18_q19 = 7   if missing(q18_q19) & q19==2
replace q18_q19 = 10  if missing(q18_q19) & q19==3
lab var q18_q19 "Q18/Q19. Total visits past 12m (q18, q19 mid-point)"

* flag q21 (different facilities) exceeding total visits
replace q21 = .a if q21 > q18_q19 & !missing(q21) & !missing(q18_q19)

*------------------------------------------------------------------------------*
* Create weights  // TODO: Malawi census margins not available here.
* Mirror JP raking once you have target proportions, e.g.:
*   ipfweight region edu_gen age3, gen(weight) val(<margins>) maxit(50)
gen weight = .
lab var weight "Survey weight (to be created via raking)"

*------------------------------------------------------------------------------*
* Reorder & save
order respondent_id country wave language date int_length mode weight, first
save "pvs_mw.dta", replace
di as result "Done. Wrote pvs_mw.dta (" _N " obs)."
