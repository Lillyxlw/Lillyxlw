* People's Voice Survey data cleaning for Japan - Wave 1
* Date of last update: Jan 20026
* Last updated by: Liwei Xiang

/*

This file cleans Ipsos data for Japan. 

Cleaning includes:
	- Recoding outliers to missing 
	- Recoding skip patterns, refused, and don't know 
	- Creating new variables (e.g., time variables), renaming variables, labeling variables 
	- Correcting any values and value labels and their direction 
	
Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing 

*/

clear all
set more off 

*********************** Japan ***********************

* Import raw data 
import excel using "/Users/liwei.x/Desktop/QuEst/Japan/Data cleaning/25-055861-01 Kyushu Univ Data_revised.xlsx", firstrow clear case(lower)

* data cleaning:
drop q0 q4 q5 q5codes q13*scale /// we removed the extra questions in JP questionnaires: q4,5,13,24,25,26,27,58
		q24 q25 q25other1 q2616 q2626 q2636 q2646 q2656 q2666 q26other1 q27 q437confirm ///
		trp1 trp214 trp224 trp234 trp244

*------------------------------------------------------------------------------*
* Generate variables

*respondent id
gen respondent_id = "JP" + string(respondentserial)
drop  respondentserial

* country
gen country = 8
lab def country 8 "Japan"
lab values country country

* country_reg
gen country_reg = 25 // which number???
lab def country_reg 25 "Japan"
lab values country_reg country_reg

*Label as wave 1 data:
gen wave = 1

* language
gen language = 8001
lab def Language 8001 "JP: Japanese"
lab val language Language

* date
* gen date = . // we don't have it

* int_length
* gen int_length = . // we don't have it

* mode
gen mode = 1 
lab def mode 1 "CAWI" // check with Todd to see 
lab val mode mode

* weight, psu_id_for_svy_cmds

*------------------------------------------------------------------------------*
* Rename variables  

rename respondentserial respondent_serial
rename (q6 q7 q8) (q4 q5 q7) // here we will add q6 later
rename (q9 q10 q11) (q8 q9 q10)
rename (q121scale q122scale q123scale q124scale q125scale q126scale q127scale q128scale q129scale q1210scale q1211scale q1212scale q1213scale q1214scale q1215scale q1216scale q1217scale q121) ///
		(q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp q11q_jp q11_other)
rename (q141scale q142scale q143scale q144scale q145scale) (q12_a q12_b q12c_jp q12d_jp q12e_jp)
rename (q15 q16 q16other1) (q13 q14_jp q14_other)
rename (q17 q17other1 q18 q18other1) (q15 q15_other q16 q16_other)
rename (q19 q20 q20codes q21 q22 q23 q23codes) (q17 q18 q18codes q19 q20 q21 q21codes)
rename (q28 q28codes q29 q29codes q30 q30other1 q31 q32) (q22 q22codes q23 q23codes q24 q24_other q25 q26)
rename (q331scale q332scale q333scale q334scale q335scale q336scale q337scale q338scale q339scale q3310scale q3311scale q3312scale) (q27_a q27_b q27_c q27_d q27_e q27_f q27_g q27_h q27i_jp q27j_jp q27k_jp q27l_jp)
rename (q341scale q342scale q343scale q344scale) (q28_a q28_b q28c_jp q28d_jp)
rename (q35 q36 q36other1) (q29 q30 q30_other)
rename (q371scale q372scale q373scale q374scale) (q31a q31b q31c_jp q31d_jp)
rename (q38 q38other1 q39 q39other1 q40 q40other1) (q32_jp q32_other q33 q33_other q34 q34_other)
rename (q41 q42 q43 q43other1) (q35 q36 q37 q37_other)
rename (q441scale q442scale q443scale q444scale q445scale q446scale q447scale q448scale q449scale q4410scale q4411scale) (q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k)
rename (q45 q45codes) (q39 q39codes)
rename (q461scale q462scale q463scale q464scale q465scale q466scale) (q40_a q40_b q40_c q40_d q40e_jp q40f_jp)
rename (q471scale q472scale q473scale q474scale q475scale q476scale) (q41_a q41_b q41_c q41d_jp q41e_jp q41f_jp)
rename (q48 q49) (q42 q43)
rename (q50 q51 q52 q53 q54) (q45 q46 q47 q48 q49)
rename (q55 q55other1) (q50 q50_other)
rename (q56 q57 q58 q58other1) (q51 q52a_jp q53a_jp q53a_jp_other)



*------------------------------------------------------------------------------*
* Generate recoded variables

*combined 998 into the vatriables because they are sepreate 
replace q18 = q18codes if !missing(q18codes)
replace q21 = q21codes if !missing(q21codes)
replace q22 = q22codes if !missing(q22codes)
replace q23 = q23codes if !missing(q23codes)
replace q39 = q39codes if !missing(q39codes)
drop q18codes q21codes q22codes q23codes q39codes

* q2(age group)
lab def q2_label 1 "18 to 29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70-79" 7 "80 or older"
lab val q2 q2_label

* q3 (gender)
lab def q3_label 0 "Male" 1 "Female" 2 "Another gender"
lab val q3 q3_label

* q4 (region)
lab def q4_label 1 "Hokkaido" 2 "Aomori" 3 "Iwate" 4 "Miyagi" 5 "Akita" ///
              6 "Yamagata" 7 "Fukushima" 8 "Ibaraki" 9 "Tochigi" ///
              10 "Gunma" 11 "Saitama" 12 "Chiba" 13 "Tokyo" 14 "Kanagawa" ///
              15 "Niigata" 16 "Toyama" 17 "Ishikawa" 18 "Fukui" 19 "Yamanashi" ///
              20 "Nagano" 21 "Gifu" 22 "Shizuoka" 23 "Aichi" 24 "Mie" ///
              25 "Shiga" 26 "Kyoto" 27 "Osaka" 28 "Hyogo" 29 "Nara" ///
              30 "Wakayama" 31 "Tottori" 32 "Shimane" 33 "Okayama" 34 "Hiroshima" ///
              35 "Yamaguchi" 36 "Tokushima" 37 "Kagawa" 38 "Ehime" 39 "Kochi" ///
              40 "Fukuoka" 41 "Saga" 42 "Nagasaki" 43 "Kumamoto" 44 "Oita" ///
              45 "Miyazaki" 46 "Kagoshima" 47 "Okinawa"
lab val q4 q4_label

* q5 (urban/rural)
lab def q5_label 1 "JP: City" 2 "JP: Suburb of city" 3 "JP: Small town" 4 "JP: Rural area" 
lab val q5 q5_label

* q6 (insured)
recode q7 (1 = 1) (2 = 0), gen(q6_jp) // Confirm with Todd how to code 999: BLANK
lab def q6_label 0 " No, do not have private insurance" 1 "Yes, have private insurance"  
lab val q6_jp q6_label
 
* q7 (insured_type)
recode q7 (999 = .a) // Confirm with Todd how to code 999: BLANK
lab def q7_label 1 "JP: Additional private insurance" 2 "JP: Only public insurance" .a "NA"
lab val q7 q7_label

* q8 (education)
recode q8 (1 = 1) (3 = 2) (4 = 3) (5 = 3) // Confirm with Todd how to code this since we don;t have primary and none
lab def q8_label 0 "None (or no formal education)" 1 "Primary" 2 "Secondary" 3 "Post-secondary" 4 "Other" 
lab val q8 q8_label

* q9 (general health)
recode q9 (999 = .a) // Confirm with Todd how to code 999: BLANK
lab def q9_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q9 q9_label

* q10 (mental health)
recode q10 (999 = .a) // Confirm with Todd how to code 999: BLANK
lab def q10_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q10 q10_label

* q11 (chronic health)
foreach v of varlist q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp {
    replace `v' = .a if `v' == 999
}

egen total_q11 = rowtotal(q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp)
gen q11 = total_q11 > 0
label define q11_label 0 "No" 1 "Yes"
label values q11 q11_label

drop q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp total_q11

* q12_a (confendent managing health)
recode q12_a (999 = .a)
lab def q12_label 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA"
lab val q12_a q12_a_label

* q12_b (tell provider concerns) 
recode q12_b (999 = .a)
lab val q12_b q12_label

* q12c_jp (best treatment)
recode q12c_jp (999 = .a) // extra questions, ask Todd if we drop them
lab val q12c_jp q12_label

* q12d_jp (understand)
recode q12d_jp (999 = .a) // extra questions, ask Todd if we drop them
lab val q12d_jp q12_label

* q12e_jp (find information)
recode q12e_jp (999 = .a) // extra questions, ask Todd if we drop them
lab val q12e_jp q12_label

* q13 (sepcific facility visit)
recode q13 (999 = .a) // extra questions, ask Todd if we drop them
lab def q13_label 0 "No" 1 "Yes" .a "NA"
lab val q13 q13_label

* q14_jp (pub/pri facility)
replace q14_jp = .a if q14_jp == . // code as .a since they are skipped for having no facility going
lab def q14_jp_label 1 "Public" 2 "Private" 3 "Other(specify)" .a "NA"
lab val q14_jp q14_jp_label

* q15 (type of facility)
replace q15 = .a if q15 == . // code as .a since they are skipped for the facility is public
lab def q15_label 1 "Doctor's office or clinic" 2 "Hospital where referrals are not required" 3 "Hospital where referrals are required" 4 "Other(specify)" .a "NA"
lab val q15 q15_label

* q16 (why this facility)
recode q16 (8 = 21) // Ask Todd to check if i should code this to 21
replace q16 = .a if q16 == .
lab def q16_label 1	"Low cost" 2 "Short distance" 3	"Short waiting time" 4 "Good healthcare provider skills" ///
				  5	"Staff shows respect" 6	"Medicines and equipment are available" 7 "Only facility available" ///
				  8	"Covered by insurance" 9 "Other(specify)" 21 "JP: Positive online or social media reviews".a "NA"
lab val q16 q16_label

* q17 (overall rating of received healthcare)
replace q17 = .a if q17 == .
recode q17 (5 = .a) (999 = .) // Confirm with Todd how to code 999: BLANK
lab def q17_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q17 q17_label

* q18 (# of visits)
recode q18 (998 = .d) (999 = .a)
lab def q18_label .d "Don't know" .a "NA"
lab val q18 q18_label

* q19 (categorized of # of visits)
replace q19 = .a if q19 == .
recode q19 (999 = .)
lab def q19_label 1 "0" 2 "1-4" 3 "5-9" 4 "10 or more" .a "NA"
lab val q19 q19_label

* q20 (same or different facility)
replace q20 = .a if q20 == .
recode q20 (999 = .)
lab def q20_label 0 "No" 1 "Yes" .a "NA"
lab val q20 q20_label

* q21 (# of different facilities)
replace q21 = .a if q21 == .
recode q21 (999 = .a) (998 = .d)
lab def q21_label .d "Don't know" .a "NA"
lab val q21 q21_label

* q22 (# of home visits)
recode q22 (999 = .a) (998 = .d)
lab def q22_label .d "Don't know" .a "NA"
lab val q22 q22_label

* q23 (# of virtual visits)
recode q23 (999 = .a) (998 = .d)
lab def q23_label .d "Don't know" .a "NA"
lab val q23 q23_label

* q24 (reason of virtual)
replace q24 = .a if q24 == .
lab def q24_label 1 "Care for an urgent or new health problem such as an accident or injury or a new" ///
					2 "Follow-up care for a longstanding illness or chronic disease such as hypertension or diabetes. This may include mental health conditions." ///
					3 "Preventive care or a visit to check on your health, such as an annual check-up, antenatal care, or vaccination." 4 "Other (specify)" .a "NA"
lab val q24 q24_label

* q25 (overall rating of virtual)
replace q25 = .a if q25 == .
lab def q25_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q25 q25_label

* q26 (stay overnight)
lab def q26_label 0 "No" 1 "Yes"
lab val q26 q26_label

* q27_a (bp check)
recode q27_a (999 = .a) (998 = .d)
lab def q27_label 0 "No" 1 "Yes" .a "NA" .d "Don't know"
lab val q27_a q27_label

* q27_b (mammo)
replace q27_b = .a if q27_b == .
recode q27_b (999 = .a) (998 = .d)
lab val q27_b q27_label

* q27_c (cervical)
replace q27_c = .a if q27_c == .
recode q27_c (999 = .a) (998 = .d)
lab val q27_c q27_label

* q27_d (vision)
recode q27_d (999 = .a) (998 = .d)
lab val q27_d q27_label

* q27_e (teeth)
recode q27_e (999 = .a) (998 = .d)
lab val q27_e q27_label

* q27_f (bs)
recode q27_f (999 = .a) (998 = .d)
lab val q27_f q27_label

* q27_g (cholesterol)
recode q27_g (999 = .a) (998 = .d)
lab val q27_g q27_label

* q27_h (deoression)
recode q27_h (999 = .a) (998 = .d)
lab val q27_h q27_label

* q27i_jp (endoscope)
recode q27i_jp (999 = .a) (998 = .d)
lab val q27i_jp q27_label

* q27j_jp (barium swalllow)
recode q27j_jp (999 = .a) (998 = .d)
lab val q27j_jp q27_label

* q27k_jp (fecal occult bloot test)
recode q27k_jp (999 = .a) (998 = .d)
lab val q27k_jp q27_label

* q27l_jp (electrocardiogram)
recode q27l_jp (999 = .a) (998 = .d)
lab val q27l_jp q27_label

* q28_a (medical mistake)
replace q28_a = .a if q28_a == .
recode q28_a (999 = .)
lab def q28_label 0 "No" 1 "Yes" .a "I did not get healthcare in past 12 months"
lab val q28_a q28_label

* q28_b (treat unfairly)
replace q28_b = .a if q28_b == .
recode q28_b (999 = .)
lab val q28_b q28_label

* q28c_jp (not enough explaination)
replace q28c_jp = .a if q28c_jp == .
recode q28c_jp (999 = .)
lab val q28c_jp q28_label

* q28d_jp (wait long time)
replace q28d_jp = .a if q28d_jp == .
recode q28d_jp (999 = .)
lab val q28d_jp q28_label

* q29 (not get healthcare)
recode q29 (999 = .a) 
lab def q29_label 0 "No" 1 "Yes" .a "NA"
lab val q29 q29_label

* q30 (reason)
recode q30 (7 = 24) (9 = 25) (10 = 26) (11 = 27) (8 = 7) (12 = 10)
lab def q30_label 1	"High cost (e.g., high out of pocket payment, not covered by insurance)" ///
				  2	"Far distance (e.g., too far to walk or drive, transport not readily available)" ///
				  3	"Long waiting time (e.g., long line to access facility, long wait for the provider)" ///
				  4	"Poor healthcare provider skills (e.g., spent too little time with patient, did not conduct a thorough exam)" ///
				  5	"Staff don't show respect (e.g., staff is rude, impolite, dismissive)" ///
				  6	"Medicines and equipment are not available (e.g., medicines regularly out of stock, equipment like X-ray machines broken or unavailable)" ///
				  7	"Illness not serious enough" 10 "Other (specify)"  24 "JP: Equipment like X-ray machines are broken or unavailable" /// 
				  25 "JP: Do not want health care providers to know of the disease or to show the symptomatic part of the body" ///
				  26 "JP: Busyness" 27 "JP: Did not want to hear about unfavorable diagnoses" .a "NA"
lab val q30 q30_label

* q31a (borrow)
lab def q31_label 0 "No" 1 "Yes" .a "NA"
lab val q31a q31_label

* q31b (sell)
recode q31b (999 = .a) 
lab val q31b q31_label

* q31c_jp (government)
recode q31c_jp (999 = .a) 
lab val q31c_jp q31_label

* q31d_jp (worried)
recode q31d_jp (999 = .a) 
lab val q31d_jp q31_label

* q32_jp (pub/pri facility)
recode q32_jp (999 = .a) 
lab def q32_jp_label 1 "Public" 2 "Private" 3 "Other (specify)" .a "NA" 
lab val q32_jp q32_jp_label

* q33 (type of facility)
recode q33 (999 = .a) 
lab def q33_label 1 "JP: Public" 2 "JP: Private" 3 "JP: Other (specify)" .a "NA" 
lab val q33 q33_label

* q34 (main reason)
replace q34 = .a if q34 == .
lab def q34_label 1 "Care for an urgent or new health problem (an accident or a new symptom like fever, pain, diarrhea, or depression)" ///
				  2 "Follow-up care for a longstanding illness or chronic disease (hypertension or diabetes, mental health conditions)" ///
				  3 "Preventive care or a visit to check on your health (for example, antenatal care, vaccination, or eye checks)" ///
				  4 "Other (specify)" .a "NA"
lab val q34 q34_label

* q35 (schedule or walk in)
replace q35 = .a if q35 == .
recode q35 (999 = .)
lab def q35_label 0 "No, I did not have an appointment" 1 "Yes, the visit was scheduled, and I had an appointment" .a "NA"
lab val q35 q35_label	

* q36 (wait)
replace q36 = .a if q36 == .
lab def q36_label 1	"Same or next day" 2 "2 days to less than one week" 3 "1 week to less than 2 weeks" ///
				  4	"2 weeks to less than 1 month" 5 "1 month to less than 2 months" 6 "2 months to less than 3 months" ///
				  7	"3 months to less than 6 months" 8	"6 months or more" .a "NA"
lab val q36 q36_label

* q37 (wait min)
replace q37 = .a if q37 == .
recode q37 (999 = .)
lab def q37_label 1	"Less than 15 minutes" 2 "15 minutes to less than 30 minutes" 3	"30 minutes to less than 1 hour" ///
				  4	"1 hour to less than 2 hours" 5	"2 hours to less than 3 hours" 6 "3 hours to less than 4 hours" ///
				  7	"More than 4 hours (specify))" .a "NA" .r "Refused"
lab val q37 q37_label

* q38_a (overall quality)
replace q38_a = .a if q38_a == .
recode q38_a (999 = .)
lab def q38_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair"  0 "Poor" .a "NA" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" // ask Todd how to deal with this extra answer
lab val q38_a q38_label  

* q38_b (knowledge and skill)
replace q38_b = .a if q38_b == .
recode q38_b (999 = .)
lab val q38_b q38_label 

* q38_c (equip and clinical)
replace q38_c = .a if q38_c == .
recode q38_c (999 = .)
lab val q38_c q38_label 

* q38_d (respect)
replace q38_d = .a if q38_d == .
recode q38_d (999 = .)
lab val q38_d q38_label 

* q38_e (prior)
replace q38_e = .a if q38_e == .
recode q38_e (999 = .)
lab val q38_e q38_label 

* q38_f (explain)
replace q38_f = .a if q38_f == .
recode q38_f (999 = .)
lab val q38_f q38_label 

* q38_g (your opnion)
replace q38_g = .a if q38_g == .
recode q38_g (999 = .)
lab val q38_g q38_label 

* q38_h (time spent)
replace q38_h = .a if q38_h == .
recode q38_h (999 = .)
lab val q38_h q38_label 

* q38_i (wait time)
replace q38_i = .a if q38_i == .
recode q38_i (999 = .)
lab val q38_i q38_label 

* q38_j (courtesy and helpfulness)
replace q38_j = .a if q38_j == .
recode q38_j (999 = .)
lab val q38_j q38_label 

* q38_k (time to get appointment)
replace q38_k = .a if q38_k == .
recode q38_k (999 = .)
lab val q38_k q38_label 

* q39 (recommment)
replace q39 = .a if q39 == .
recode q39 (999 = .)
lab def q39_label .a "NA"
lab val q39 q39_label

* q40_a (women)
recode q40_a (999 = .a) (5 = .d)
lab def q40_label 4	"Excellent" 3 "Very good" 2	"Good" 1 "Fair" 0 "Poor" ///
				  .d "I am unable to judge" .a "NA"
lab val q40_a q40_label

* q40_b (children)
recode q40_b (999 = .a) (5 = .d)
lab val q40_b q40_label

* q40_c (chronic condition)
recode q40_c (999 = .a) (5 = .d)
lab val q40_c q40_label

* q40_d (mental health)
recode q40_d (999 = .a) (5 = .d)
lab val q40_d q40_label

* q40e_jp (health checkup)
recode q40e_jp (999 = .a) (5 = .d)
lab val q40e_jp q40_label

* q40f_jp (infertility treatment)
recode q40f_jp (999 = .a) (5 = .d)
lab val q40f_jp q40_label

* q41_a (get)
recode q41_a (999 = .a)
lab def q41_label 3 "Very confident" 2"Somewhat confident" 1 "Not too confident" 0 "Not at all confident" .a "NA"
lab val q41_a q41_label

* q41_b (afford)
recode q41_b (999 = .a)
lab val q41_b q41_label

* q41_c (government opnion)
recode q41_c (999 = .a)
lab val q41_c q41_label

* q41d_jp (afford when old)
recode q41d_jp (999 = .a)
lab val q41d_jp q41_label

* q41e_jp (get in disaster)
recode q41e_jp (999 = .a)
lab val q41e_jp q41_label

* q41f_jp (get in area not city)
recode q41f_jp (999 = .a)
lab val q41f_jp q41_label

* q42 (pub system)
recode q42 (999 = .)
lab def q42_label 4	"Excellent" 3 "Very good" 2	"Good" 1 "Fair" 0 "Poor"
lab val q42 q42_label

* q43 (pri system)
recode q43 (999 = .)
lab val q43 q42_label

* q45 (better, same, worse)
recode q45 (999 = .) (1 = 2) (2 = 1) (3 = 0)
lab def q45_label 2	"Getting better" 1 "Staying the same" 0	"Getting worse"
lab val q45 q45_label

* q46 (rebuild, major, minor)
recode q46 (999 = .) 
lab def q46_label 1	"Our healthcare system has so much wrong with it that we need to completely rebuild it." ///
					2 "There are some good things in our healthcare system, but major changes are needed to make it work better." ///
					3 "On the whole, the system works pretty well and only minor changes are necessary to make it work better."
lab val q46 q46_label

* q47 (covid mamangement)
recode q47 (999 = .) 
lab def q47_label 4	"Excellent" 3 "Very good" 2	"Good" 1 "Fair" 0 "Poor" 
lab val q47 q47_label

* q48 (vignette 1)
recode q48 (999 = .) 
lab def q48_label 4	"Excellent" 3 "Very good" 2	"Good" 1 "Fair" 0 "Poor" 
lab val q48 q48_label

* q49 (vignette 2)
recode q49 (999 = .) 
lab def q49_label 4	"Excellent" 3 "Very good" 2	"Good" 1 "Fair" 0 "Poor" 
lab val q49 q49_label

* q50 (mother tongue)
recode q50 (999 = .) 
lab def q50_label 1	"Japanese" 2 "Chinese" 3 "Korean" 4 "Vietnamese" 5 "Tagalog" 6 "Spanish" 7 "English" 8 "Other (specify)"
lab val q50 q50_label

* q51 (income)
recode q51 (999 = .) 
lab def q51_label 1	"Less than 3 million yen" 2 "3 million-less than 4.8 million yen" 3 "4.8 million-less than 6.5 million yen" ///
					4 "6.5 million-less than 8.5 million yen" 5 "8.5 million yen or over" 
lab val q51 q51_label

* q52a_jp (political party)
recode q52a_jp (998 = .d)
lab def q52_label 1	"Liberal Democratic Party" 2 "Constitutional Democratic Party" 3 "Komeito" ///
					4 "Japan Innovation Party" 5 "Japanese Communist Party" 6 "Reiwa Shinsengumi" 7 "Social Democratic Party" 8 "Democratic Party for the People" ///
					9 "Sanseito" 10 "Other" 11 "Did not vote" .d "Don't know"
lab val q52a_jp q52_label

* q53a_jp (priority of election)
recode q53a_jp (999 = .a) (998 = .d)
lab def q53_label 1	"Healthcare system" 2 "Economic policy" 3 "Education" ///
					4 "Welfare" 5 "Foreign affairs" 6 "Defense" 7 "Environmental and energy policy" 8 "Employment and labor policy" ///
					9 "Taxation and fiscal policy" 10 "Transportation and infrastructure policy" 11 "Other (specify)" .d "Don't know"
lab val q53a_jp q53_label

* Relabel some variables now so we can use the orignal label values
local q4l  q4_label
local q5l  q5_label
local q7l  q7_label
local q8l  q8_label
local q15l q15_label
local q33l q33_label
local q50l q50_label
local q51l q51_label
local q52l q52_label
local q53l q53_label

foreach q in q4 q5 q7 q8 q15 q33 q50 q51 q52a_jp q53a_jp{

    * 1) SHIFT the values to 8000+ (do not touch missing values)
    replace `q' = 8000 + `q' if `q' < .

    * 2) Read original label set
    quietly elabel list ``q'l'
    local n   = r(k)
    local val = r(values)
    local lab = r(labels)

    * 3) Build new label set, skipping missing-coded values
    forvalues i = 1/`n' {
        local v : word `i' of `val'
        local l : word `i' of `lab'

        * skip if v is missing (., .a-.z)
        if (`v' < .) {
            local newcode = 8000 + `v'
            elabel define `q'_label `newcode' `"JP: `l'"', modify
        }
    }

    * 4) Apply the new labels
    label values `q' `q'_label
}


*------------------------------------------------------------------------------*
* Fix interview length variable and other time variables (Don't have it yet)



*------------------------------------------------------------------------------*
* Check for implausible values 
* Q17. Overall respondent's rating of the quality received in this facility
* Q18/Q19. Total number of visits made in past 12 months (q23, q24 mid-point)
* Q20. Were all of the visits you made to the same healthcare facility? 
* Q21. How many different healthcare facilities did you go to? 
* Q22. How many visits did you have with a healthcare provider at your home?
* Q23. How many virtual or telemedicine visits did you have?

* Q20, Q21
gen q18_q19 = q18 // con firm with Todd how we should create the rest
recode q18_q19 (. = 0) if q19 == 1
recode q18_q19 (. = 2.5) if q19 == 2
recode q18_q19 (. = 5) if q19 == 3
recode q18_q19 (. = 10) if q19 == 4 
	
list q18_q19 q19 q21 if q21 > q18_q19 & q21 < . 
*replace q21 = q18_q19 if q21 > q18_q19 & q21 < . // Ask todd what to do about discrepant info between q18 and q19

list q20 q21 if q21 == 0 | q21 == 1
* None

* List if yes to q20: "all visits in the same facility" but q21: "how many different healthcare facilities did you go to" is more than 0
list q20 q21 if q20 ==1 & q21 > 0 & q21 < . 
* None

* Q28a, Q28b 
* list if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months - Note: q28_a and q28_b in this dataset does not have this option
egen visits_total = rowtotal(q18_q19 q22 q23) 
list visits_total q17 if q17 == 5 & visits_total > 0 & visits_total < . 
* None


drop visits_total

*------------------------------------------------------------------------------*
* Renaming variables 

*for appending process:



*------------------------------------------------------------------------------*
* Other specify recode 
* This command recodes all "other specify" variables as listed in /specifyrecode_inputs spreadsheet
* This command requires an input file that lists all the variables to be recoded and their new values
* The command in data quality checks below extracts other, specify values 

gen q11_other_original = q11_other
label var q11_other_original "Q11_other. Other"

gen q14_other_original = q14_other
label var q14_other_original "Q14. Other"	
	
gen q15_other_original = q15_other
label var q15_other_original "Q15. Other"

gen q16_other_original = q16_other
label var q16_other_original "Q16. Other"

gen q24_other_original = q24_other
label var q24_other_original "Q24. Other"

gen q30_other_original = q30_other
label var q30_other_original "Q30. Other"

gen q32_other_original = q32_other
label var q32_other_original "Q32. Other"

gen q33_other_original = q33_other
label var q33_other_original "Q33. Other"
	
gen q34_other_original = q34_other
label var q34_other_original "Q34. Other"

gen q37_other_original = q37_other
label var q37_other_original "Q37. Other"	

gen q50_other_original = q50_other 
label var q50_other_original "Q50. Other"

gen q53a_jp_other_original = q53a_jp_other
label var q53a_jp_other_original "Q53a. Other"	

foreach i in 6 {

ipacheckspecifyrecode using "/Users/liwei.x/Desktop/QuEst/Japan/Data cleaning/specifyrecode_inputs_`i'.xlsx",	///
	sheet(other_specify_recode)							///	
	id(respondent_id)	
 
}	

drop q11_other q14_other q15_other q16_other q24_other q30_other q32_other q33_other q34_other q37_other q50_other q53a_jp_other
	 
ren q11_other_original q11_other
ren q14_other_original q14_other
ren q15_other_original q15_other
ren q16_other_original q16_other
ren q24_other_original q24_other
ren q30_other_original q30_other
ren q32_other_original q32_other
ren q33_other_original q33_other
ren q34_other_original q34_other
ren q37_other_original q37_other
ren q50_other_original q50_other
ren q53a_jp_other_original q53a_jp_other
 



*------------------------------------------------------------------------------*
* Create weights





*------------------------------------------------------------------------------*
* Reorder variables

	order q*, sequential
	* order respondent_id country country_reg wave language date int_length mode weight // we have missing varables so far add later
	order respondent_id country country_reg wave language mode 

*------------------------------------------------------------------------------*

* Save data
 save "$data_mc/02 recoded data/input data files/pvs_jp.dta", replace

*------------------------------------------------------------------------------*

