*==============================================================================
* clean_pvs_jp.do
* Purpose : Clean the raw People's Voice Survey (PVS) Japan export
*           "25-055861-01 Kyushu Univ Data_revised.xlsx" into the analysis
*           dataset "pvs_jp.dta" (QuEST/PVS standard variable conventions).
* Notes   : Reverse-engineered from the raw export and the released pvs_jp.dta.
*           Run from the folder that contains the .xlsx file.
*==============================================================================

clear all
set more off
version 14

* ---- 0. Paths -----------------------------------------------------------
* Edit this if you run the do-file from a different working directory.
local raw  "25-055861-01 Kyushu Univ Data_revised.xlsx"
local sheet "S25050491修正"

* ---- 1. Import raw Excel (no firstrow: keep stable A,B,C... names) -------
* The raw header row contains characters that are illegal in Stata names
* (e.g. "Q12[{1}].scale", "Q26 (1/6)"), so we import positionally and rename.
import excel using "`raw'", sheet("`sheet'") cellrange(A1) clear
drop in 1            // drop the header row that import kept as data

* ---- 2. Rename the positional columns to readable raw names -------------
rename (A B C D E F G H) (resp_serial Q0 Q1 Q2 Q3 Q4 Q5 Q5_codes)
rename (I J K L M N O P) (Q6 Q7 Q8 Q9 Q10 Q11 Q12_1 Q12_2)
rename (Q R S T U V W X) (Q12_3 Q12_4 Q12_5 Q12_6 Q12_7 Q12_8 Q12_9 Q12_10)
rename (Y Z AA AB AC AD AE AF) (Q12_11 Q12_12 Q12_13 Q12_14 Q12_15 Q12_16 Q12_17 Q121)
rename (AG AH AI AJ AK AL AM AN) (Q13_1 Q13_2 Q13_3 Q13_4 Q13_5 Q13_6 Q13_7 Q13_8)
rename (AO AP AQ AR AS AT AU AV) (Q13_9 Q13_10 Q13_11 Q13_12 Q13_13 Q13_14 Q13_15 Q13_16)
rename (AW AX AY AZ BA BB BC BD) (Q13_17 Q14_1 Q14_2 Q14_3 Q14_4 Q14_5 Q15 Q16)
rename (BE BF BG BH BI BJ BK BL) (Q16_oth Q17 Q17_oth Q18 Q18_oth Q19 Q20 Q20_codes)
rename (BM BN BO BP BQ BR BS BT) (Q21 Q22 Q23 Q23_codes Q24 Q25 Q25_oth Q26_1_6)
rename (BU BV BW BX BY BZ CA CB) (Q26_2_6 Q26_3_6 Q26_4_6 Q26_5_6 Q26_6_6 Q26_oth Q27 Q28)
rename (CC CD CE CF CG CH CI CJ) (Q28_codes Q29 Q29_codes Q30 Q30_oth Q31 Q32 Q33_1)
rename (CK CL CM CN CO CP CQ CR) (Q33_2 Q33_3 Q33_4 Q33_5 Q33_6 Q33_7 Q33_8 Q33_9)
rename (CS CT CU CV CW CX CY CZ) (Q33_10 Q33_11 Q33_12 Q34_1 Q34_2 Q34_3 Q34_4 Q35)
rename (DA DB DC DD DE DF DG DH) (Q36 Q36_oth Q37_1 Q37_2 Q37_3 Q37_4 TRP1 Q38)
rename (DI DJ DK DL DM DN DO DP) (Q38_oth Q39 Q39_oth Q40 Q40_oth Q41 Q42 Q43)
rename (DQ DR DS DT DU DV DW DX) (Q43_oth Q437confirm Q44_1 Q44_2 Q44_3 Q44_4 Q44_5 Q44_6)
rename (DY DZ EA EB EC ED EE EF) (Q44_7 Q44_8 Q44_9 Q44_10 Q44_11 Q45 Q45_codes Q46_1)
rename (EG EH EI EJ EK EL EM EN) (Q46_2 Q46_3 Q46_4 Q46_5 Q46_6 Q47_1 Q47_2 Q47_3)
rename (EO EP EQ ER ES ET EU EV) (Q47_4 Q47_5 Q47_6 Q48 Q49 Q50 Q51 Q52)
rename (EW EX EY EZ FA FB FC FD) (Q53 Q54 TRP2_1_4 TRP2_2_4 TRP2_3_4 TRP2_4_4 Q55 Q55_oth)
rename (FE FF FG FH) (Q56 Q57 Q58 Q58_oth)

* ---- 3. Destring numeric raw variables ----------------------------------
* Q5 holds an interview date string and the *_oth vars hold free text; keep them as string.
ds, has(type string)
destring resp_serial Q0 Q1 Q2 Q3 Q4 Q5_codes Q6 Q7 Q8 Q9 Q10 Q11 Q12_1 Q12_2 Q12_3 Q12_4 Q12_5 Q12_6 Q12_7 Q12_8 Q12_9 Q12_10 Q12_11 Q12_12 Q12_13 Q12_14 Q12_15 Q12_16 Q12_17 Q121 Q13_1 Q13_2 Q13_3 Q13_4 Q13_5 Q13_6 Q13_7 Q13_8 Q13_9 Q13_10 Q13_11 Q13_12 Q13_13 Q13_14 Q13_15 Q13_16 Q13_17 Q14_1 Q14_2 Q14_3 Q14_4 Q14_5 Q15 Q16 Q17 Q18 Q19 Q20 Q20_codes Q21 Q22 Q23 Q23_codes Q24 Q25 Q26_1_6 Q26_2_6 Q26_3_6 Q26_4_6 Q26_5_6 Q26_6_6 Q27 Q28 Q28_codes Q29 Q29_codes Q30 Q31 Q32 Q33_1 Q33_2 Q33_3 Q33_4 Q33_5 Q33_6 Q33_7 Q33_8 Q33_9 Q33_10 Q33_11 Q33_12 Q34_1 Q34_2 Q34_3 Q34_4 Q35 Q36 Q37_1 Q37_2 Q37_3 Q37_4 TRP1 Q38 Q39 Q40 Q41 Q42 Q43 Q437confirm Q44_1 Q44_2 Q44_3 Q44_4 Q44_5 Q44_6 Q44_7 Q44_8 Q44_9 Q44_10 Q44_11 Q45 Q45_codes Q46_1 Q46_2 Q46_3 Q46_4 Q46_5 Q46_6 Q47_1 Q47_2 Q47_3 Q47_4 Q47_5 Q47_6 Q48 Q49 Q50 Q51 Q52 Q53 Q54 TRP2_1_4 TRP2_2_4 TRP2_3_4 TRP2_4_4 Q55 Q56 Q57 Q58, replace force

* =====================================================================
* 4. Build the PVS analysis variables
* =====================================================================

* ---- 4a. Administrative / constant fields -------------------------------
gen double respondent_serial = resp_serial
tostring resp_serial, gen(_idnum) force
gen respondent_id = "JP" + _idnum
drop _idnum
gen byte country  = 8       // Japan
gen byte wave     = 1
gen int  language = 8001    // JP: Japanese
gen byte mode     = 3       // CAWI

* NOTE: "date" (fieldwork date), "int_length" (interview minutes) and
*       "weight" (survey/post-stratification weight) are NOT contained in the
*       raw Excel export. In the released pvs_jp.dta they come from the survey
*       vendor's sample/paradata + weighting file and must be merged in here,
*       e.g.:  merge 1:1 respondent_serial using "pvs_jp_sampleinfo.dta"
* We create them as empty placeholders so the saved file matches the released
* variable layout; replace this block with the merge once the file is available.
gen double date       = .
gen double int_length = .
gen double weight      = .
format date %tdDD_Month_CCYY

* ---- 4b. Direct copies (raw value == final value) -----------------------
gen double q1 = Q1
gen double q2 = Q2
gen double q3 = Q3
gen double q9 = Q10
gen double q10 = Q11
gen double q13 = Q15
gen double q17 = Q19
gen double q18 = Q20
gen double q20 = Q22
gen double q21 = Q23
gen double q22 = Q28
gen double q23 = Q29
gen double q24 = Q30
gen double q25 = Q31
gen double q26 = Q32
gen double q29 = Q35
gen double q34 = Q40
gen double q35 = Q41
gen double q36 = Q42
gen double q37 = Q43
gen double q39 = Q45
gen double q42 = Q48
gen double q43 = Q49
gen double q46 = Q51
gen double q47 = Q52
gen double q48 = Q53
gen double q49 = Q54
gen double q31a = Q37_1
gen double q31b = Q37_2
gen double q12_a = Q14_1
gen double q12_b = Q14_2
gen double q27_a = Q33_1
gen double q27_b = Q33_2
gen double q27_c = Q33_3
gen double q27_d = Q33_4
gen double q27_e = Q33_5
gen double q27_f = Q33_6
gen double q27_g = Q33_7
gen double q27_h = Q33_8
gen double q28_a = Q34_1
gen double q28_b = Q34_2
gen double q38_a = Q44_1
gen double q38_b = Q44_2
gen double q38_c = Q44_3
gen double q38_d = Q44_4
gen double q38_e = Q44_5
gen double q38_f = Q44_6
gen double q38_g = Q44_7
gen double q38_h = Q44_8
gen double q38_i = Q44_9
gen double q38_j = Q44_10
gen double q38_k = Q44_11
gen double q40_a = Q46_1
gen double q40_b = Q46_2
gen double q40_c = Q46_3
gen double q40_d = Q46_4
gen double q41_a = Q47_1
gen double q41_b = Q47_2
gen double q41_c = Q47_3
gen double q14_jp = Q16
gen double q32_jp = Q38
gen double q12c_jp = Q14_3
gen double q12d_jp = Q14_4
gen double q12e_jp = Q14_5
gen double q27i_jp = Q33_9
gen double q27j_jp = Q33_10
gen double q27k_jp = Q33_11
gen double q27l_jp = Q33_12
gen double q28c_jp = Q34_3
gen double q28d_jp = Q34_4
gen double q31c_jp = Q37_3
gen double q31d_jp = Q37_4
gen double q40e_jp = Q46_5
gen double q40f_jp = Q46_6
gen double q41d_jp = Q47_4
gen double q41e_jp = Q47_5
gen double q41f_jp = Q47_6
gen double q52a_jp = Q57
gen double q53a_jp = Q58

* ---- 4c. JP region-coded categoricals: final = raw + 8000 ---------------
gen double q4 = Q6 + 8000
gen double q5 = Q7 + 8000
gen double q7 = Q8 + 8000
gen double q8 = Q9 + 8000
gen double q15 = Q17 + 8000
gen double q33 = Q39 + 8000
gen double q50 = Q55 + 8000
gen double q51 = Q56 + 8000

* ---- 4d. Derived / recoded variables ------------------------------------
* q6_jp: has additional private insurance == chose "Additional private insurance" (Q8==1)
gen double q6_jp = .
replace q6_jp = 1 if Q8==1
replace q6_jp = 0 if Q8==2

* q11: longstanding illness == reported >=1 condition in the Q13 checklist battery
egen byte _anycond = anymatch(Q13_1 Q13_2 Q13_3 Q13_4 Q13_5 Q13_6 Q13_7 Q13_8 Q13_9 Q13_10 Q13_11 Q13_12 Q13_13 Q13_14 Q13_15 Q13_16 Q13_17), values(1)
gen byte q11 = _anycond
drop _anycond

* q18_q19: number of visits (uses the exact count q18; range q19 left missing as in source)
gen double q18_q19 = q18

* q19: range of visits, raw Q21 is 1..4 -> 0..3
gen double q19 = Q21 - 1

* q16: main reason for choosing facility. Raw code 8 == JP online/social-media reviews (->21).
*      (A small number of raw "Other" responses were manually back-coded into substantive
*       categories in the released data from the open text; that manual step is not reproduced here.)
gen double q16 = Q18
replace q16 = 21 if Q18==8

* q30: main reason care not received. Raw Q36 1..12 -> PVS code scheme (incl. JP extras).
gen double q30 = .
replace q30 = 1 if Q36==1
replace q30 = 2 if Q36==2
replace q30 = 3 if Q36==3
replace q30 = 4 if Q36==4
replace q30 = 5 if Q36==5
replace q30 = 6 if Q36==6
replace q30 = 24 if Q36==7
replace q30 = 7 if Q36==8
replace q30 = 25 if Q36==9
replace q30 = 26 if Q36==10
replace q30 = 27 if Q36==11
replace q30 = 10 if Q36==12

* q45: health system getting better/same/worse. Raw Q50 (1,2,3) reversed -> (2,1,0).
gen double q45 = .
replace q45 = 2 if Q50==1
replace q45 = 1 if Q50==2
replace q45 = 0 if Q50==3

* ---- 4e. Open-ended "Other" text fields ---------------------------------
* (Imported verbatim from the raw export. Some were translated/curated in the
*  released dta; that editorial step is not reproducible programmatically.)
gen q14_other = Q16_oth
gen q15_other = Q17_oth
gen q16_other = Q18_oth
gen q24_other = Q30_oth
gen q30_other = Q36_oth
gen q32_other = Q38_oth
gen q33_other = Q39_oth
gen q34_other = Q40_oth
gen q37_other = Q43_oth
gen q50_other = Q55_oth
gen q53a_jp_other = Q58_oth

* =====================================================================
* 5. Missing-value coding (PVS convention)
*    raw 999 -> .r (Refused)   ;   raw 998 -> .d (Don't know)
*    Skipped/blank items remain .a (NA) by questionnaire routing.
*    (The released dta stores .a/.r/.d as Stata extended missing; the exact
*     per-cell .a vs .r split cannot be recovered from values alone.)
* =====================================================================
* Explicit list of every final numeric q-variable (raw 999/998 sentinels).
local qvars q1 q2 q3 q4 q5 q6_jp q7 q8 q9 q10 q11 ///
    q12_a q12_b q12c_jp q12d_jp q12e_jp q13 q14_jp q15 q16 q17 q18 q18_q19 q19 ///
    q20 q21 q22 q23 q24 q25 q26 ///
    q27_a q27_b q27_c q27_d q27_e q27_f q27_g q27_h q27i_jp q27j_jp q27k_jp q27l_jp ///
    q28_a q28_b q28c_jp q28d_jp q29 q30 q31a q31b q31c_jp q31d_jp q32_jp q33 q34 ///
    q35 q36 q37 q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k ///
    q39 q40_a q40_b q40_c q40_d q40e_jp q40f_jp ///
    q41_a q41_b q41_c q41d_jp q41e_jp q41f_jp q42 q43 q45 q46 q47 q48 q49 ///
    q50 q51 q52a_jp q53a_jp
foreach v of local qvars {
    quietly replace `v' = .r if `v'==999
    quietly replace `v' = .d if `v'==998
}
* region/place/edu/etc. were +8000 shifted *after* the raw sentinel, so guard 8999/8998
foreach v in q4 q5 q7 q8 q15 q33 q50 q51 {
    quietly replace `v' = .r if `v'==8999
    quietly replace `v' = .d if `v'==8998
}
* q19 = Q21-1, so a raw 999 became 998: restore as Refused
replace q19 = .r if Q21==999

* Open-numeric counts (q18,q21,q22,q23): the companion ".Codes" columns flag
* respondents who answered Don't know (998) or Refused (999) instead of a number.
replace q18 = .d if Q20_codes==998
replace q18 = .r if Q20_codes==999
replace q21 = .d if Q23_codes==998
replace q21 = .r if Q23_codes==999
replace q22 = .d if Q28_codes==998
replace q22 = .r if Q28_codes==999
replace q23 = .d if Q29_codes==998
replace q23 = .r if Q29_codes==999

* Quality-rating scales q17 and q40* offered an extra non-scale option (raw 5):
*   q17  : "have not received care" -> NA (.a)
*   q40* : "I am unable to judge"   -> Don't know (.d)
* (For q38* the codes 5 and 6 are valid substantive answers and are kept.)
replace q17 = .a if q17==5
foreach v in q40_a q40_b q40_c q40_d q40e_jp q40f_jp {
    quietly replace `v' = .d if `v'==5
}

* =====================================================================
* 6. Value labels
* =====================================================================
label define vl1 8 "Japan", replace
label define vl2 8001 "JP: Japanese", replace
label define vl3 3 "CAWI", replace
label define vl4 1 "18 to 29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70-79" 7 "80 or older", replace
label define vl5 0 "Man" 1 "Woman" 2 "Another gender", replace
label define vl6 1 "Hokkaido" 10 "Gunma" 11 "Saitama" 12 "Chiba" 13 "Tokyo" 14 "Kanagawa" 15 "Niigata" 16 "Toyama" 17 "Ishikawa" 18 "Fukui" 19 "Yamanashi" 2 "Aomori" 20 "Nagano" 21 "Gifu" 22 "Shizuoka" 23 "Aichi" 24 "Mie" 25 "Shiga" 26 "Kyoto" 27 "Osaka" 28 "Hyogo" 29 "Nara" 3 "Iwate" 30 "Wakayama" 31 "Tottori" 32 "Shimane" 33 "Okayama" 34 "Hiroshima" 35 "Yamaguchi" 36 "Tokushima" 37 "Kagawa" 38 "Ehime" 39 "Kochi" 4 "Miyagi" 40 "Fukuoka" 41 "Saga" 42 "Nagasaki" 43 "Kumamoto" 44 "Oita" 45 "Miyazaki" 46 "Kagoshima" 47 "Okinawa" 5 "Akita" 6 "Yamagata" 7 "Fukushima" 8 "Ibaraki" 8001 "JP: Hokkaido" 8002 "JP: Aomori" 8003 "JP: Iwate" 8004 "JP: Miyagi" 8005 "JP: Akita" 8006 "JP: Yamagata" 8007 "JP: Fukushima" 8008 "JP: Ibaraki" 8009 "JP: Tochigi" 8010 "JP: Gunma" 8011 "JP: Saitama" 8012 "JP: Chiba" 8013 "JP: Tokyo" 8014 "JP: Kanagawa" 8015 "JP: Niigata" 8016 "JP: Toyama" 8017 "JP: Ishikawa" 8018 "JP: Fukui" 8019 "JP: Yamanashi" 8020 "JP: Nagano" 8021 "JP: Gifu" 8022 "JP: Shizuoka" 8023 "JP: Aichi" 8024 "JP: Mie" 8025 "JP: Shiga" 8026 "JP: Kyoto" 8027 "JP: Osaka" 8028 "JP: Hyogo" 8029 "JP: Nara" 8030 "JP: Wakayama" 8031 "JP: Tottori" 8032 "JP: Shimane" 8033 "JP: Okayama" 8034 "JP: Hiroshima" 8035 "JP: Yamaguchi" 8036 "JP: Tokushima" 8037 "JP: Kagawa" 8038 "JP: Ehime" 8039 "JP: Kochi" 8040 "JP: Fukuoka" 8041 "JP: Saga" 8042 "JP: Nagasaki" 8043 "JP: Kumamoto" 8044 "JP: Oita" 8045 "JP: Miyazaki" 8046 "JP: Kagoshima" 8047 "JP: Okinawa" 9 "Tochigi", replace
label define vl7 1 "City" 2 "Suburb of city" 3 "Small town" 4 "Rural area" 8001 "JP: City" 8002 "JP: Suburb of city" 8003 "JP: Small town" 8004 "JP: Rural area" .a "NA" .r "Refused", replace
label define vl8 0 " No, do not have private insurance" 1 "Yes, have private insurance" .a "NA" .r "Refused", replace
label define vl9 1 "Additional private insurance" 2 "Only public insurance" 8001 "JP: Additional private insurance" 8002 "JP: Only public insurance" .a "NA" .r "Refused", replace
label define vl10 1 "Junior high school" 2 "High school" 3 "Vocational school, junior college, technical college" 4 "Four-year university" 5 "Postgraduate school or higher" 8001 "JP: Junior high school" 8002 "JP: High school" 8003 "JP: Vocational school, junior college, technical college" 8004 "JP: Four-year university" 8005 "JP: Postgraduate school or higher", replace
label define vl11 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .r "Refused", replace
label define vl12 0 "No" 1 "Yes", replace
label define vl13 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA" .r "Refused", replace
label define vl14 0 "No" 1 "Yes" .a "NA" .r "Refused", replace
label define vl15 1 "Public" 2 "Private" 3 "Other" .a "NA", replace
label define vl16 1 "Doctor's office or clinic" 2 "Hospital where referrals are not required" 3 "Hospital where referrals are required" 4 "Other" 8001 "JP: Doctor's office or clinic" 8002 "JP: Hospital where referrals are not required" 8003 "JP: Hospital where referrals are required" 8004 "JP: Other" .a "NA", replace
label define vl17 1 "Low cost" 2 "Short distance" 21 "JP: Positive online or social media reviews" 3 "Short waiting time" 4 "Good healthcare provider skills" 5 "Staff shows respect" 6 "Medicines and equipment are available" 7 "Only facility available" 8 "Covered by insurance" 9 "Other" .a "NA", replace
label define vl18 .a "NA" .d "Don't know" .r "Refused", replace
label define vl19 0 "0" 1 "1-4" 2 "5-9" 3 "10 or more" .a "NA" .r "Refused", replace
label define vl20 1 "Care for an urgent or new health problem such as an accident or injury or a new" 2 "Follow-up care for a longstanding illness or chronic disease such as hypertension or diabetes. This may include mental health conditions." 3 "Preventive care or a visit to check on your health, such as an annual check-up, antenatal care, or vaccination." 4 "Other" .a "NA", replace
label define vl21 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA", replace
label define vl22 0 "No" 1 "Yes" .a "NA" .d "Don't know" .r "Refused", replace
label define vl23 1 "High cost (e.g., high out of pocket payment, not covered by insurance)" 10 "Other" 2 "Far distance (e.g., too far to walk or drive, transport not readily available)" 24 "JP: Equipment like X-ray machines are broken or unavailable" 25 "JP: Do not want health care providers to know of the disease or to show the symptomatic part of the body" 26 "JP: Busyness" 27 "JP: Did not want to hear about unfavorable diagnoses" 3 "Long waiting time (e.g., long line to access facility, long wait for the provider)" 4 "Poor healthcare provider skills (e.g., spent too little time with patient, did n" 5 "Staff don't show respect (e.g., staff is rude, impolite, dismissive)" 6 "Medicines and equipment are not available (e.g., medicines regularly out of stock, equipment like X-ray machines broken or unavailable)" 7 "Illness not serious enough" .a "NA", replace
label define vl24 1 "Public" 2 "Private" 3 "Other" .a "NA" .r "Refused", replace
label define vl25 1 "Doctor's office or clinic" 2 "Hospital where referrals are not required" 3 "Hospital where referrals are required" 4 "Other" 8001 "Doctor's office or clinic" 8002 "JP: Hospital where referrals are not required" 8003 "Hospital where referrals are required" 8004 "JP: Other" .a "NA" .r "Refused", replace
label define vl26 1 "Care for an urgent or new health problem (an accident or a new symptom like feve" 2 "Follow-up care for a longstanding illness or chronic disease (hypertension or di" 3 "Preventive care or a visit to check on your health (for example, antenatal care," 4 "Other" .a "NA", replace
label define vl27 0 "No, I did not have an appointment" 1 "Yes, the visit was scheduled, and I had an appointment" .a "NA", replace
label define vl28 1 "Same or next day" 2 "2 days to less than one week" 3 "1 week to less than 2 weeks" 4 "2 weeks to less than 1 month" 5 "1 month to less than 2 months" 6 "2 months to less than 3 months" 7 "3 months to less than 6 months" 8 "6 months or more" .a "NA", replace
label define vl29 1 "Less than 15 minutes" 2 "15 minutes to less than 30 minutes" 3 "30 minutes to less than 1 hour" 4 "1 hour to less than 2 hours" 5 "2 hours to less than 3 hours" 6 "3 hours to less than 4 hours" 7 "More than 4 hours" .a "NA" .r "Refused", replace
label define vl30 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff" .a "NA" .r "Refused", replace
label define vl31 .a "NA" .r "Refused", replace
label define vl32 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .d "I am unable to judge" .r "Refused", replace
label define vl33 0 "Getting worse" 1 "Staying the same" 2 "Getting better" .a "NA" .r "Refused", replace
label define vl34 1 "Our healthcare system has so much wrong with it that we need to completely rebuild it." 2 "There are some good things in our healthcare system, but major changes are needed to make it work better." 3 "On the whole, the system works pretty well and only minor changes are necessary to make it work better." .a "NA" .r "Refused", replace
label define vl35 1 "Japanese" 2 "Chinese" 3 "Korean" 4 "Vietnamese" 5 "Tagalog" 6 "Spanish" 7 "English" 8 "Other" 8001 "JP: Japanese" 8002 "JP: Chinese" 8003 "JP: Korean" 8004 "JP: Vietnamese" 8005 "JP: Tagalog" 8006 "JP: Spanish" 8007 "JP: English" 8008 "JP: Other" .a "NA" .r "Refused", replace
label define vl36 1 "Less than 3 million yen" 2 "3 million-less than 4.8 million yen" 3 "4.8 million-less than 6.5 million yen" 4 "6.5 million-less than 8.5 million yen" 5 "8.5 million yen or over" 8001 "JP: Less than 3 million yen" 8002 "JP: 3 million-less than 4.8 million yen" 8003 "JP: 4.8 million-less than 6.5 million yen" 8004 "JP: 6.5 million-less than 8.5 million yen" 8005 "JP: 8.5 million yen or over" .a "NA" .r "Refused", replace
label define vl37 1 "Liberal Democratic Party" 10 "Other" 11 "Did not vote" 2 "Constitutional Democratic Party" 3 "Komeito" 4 "Japan Innovation Party" 5 "Japanese Communist Party" 6 "Reiwa Shinsengumi" 7 "Social Democratic Party" 8 "Democratic Party for the People" 9 "Sanseito" .d "Don't know", replace
label define vl38 1 "Healthcare system" 10 "Transportation and infrastructure policy" 11 "Other" 2 "Economic policy" 3 "Education" 4 "Welfare" 5 "Foreign affairs" 6 "Defense" 7 "Environmental and energy policy" 8 "Employment and labor policy" 9 "Taxation and fiscal policy" .a "NA" .d "Don't know" .r "Refused", replace

label values country vl1
label values language vl2
label values mode vl3
label values q2 vl4
label values q3 vl5
label values q4 vl6
label values q5 vl7
label values q6_jp vl8
label values q7 vl9
label values q8 vl10
label values q9 vl11
label values q10 vl11
label values q17 vl11
label values q42 vl11
label values q43 vl11
label values q47 vl11
label values q48 vl11
label values q49 vl11
label values q11 vl12
label values q26 vl12
label values q12_a vl13
label values q12_b vl13
label values q12c_jp vl13
label values q12d_jp vl13
label values q12e_jp vl13
label values q41_a vl13
label values q41_b vl13
label values q41_c vl13
label values q41d_jp vl13
label values q41e_jp vl13
label values q41f_jp vl13
label values q13 vl14
label values q20 vl14
label values q28_a vl14
label values q28_b vl14
label values q28c_jp vl14
label values q28d_jp vl14
label values q29 vl14
label values q31a vl14
label values q31b vl14
label values q31c_jp vl14
label values q31d_jp vl14
label values q14_jp vl15
label values q15 vl16
label values q16 vl17
label values q18 vl18
label values q21 vl18
label values q22 vl18
label values q23 vl18
label values q19 vl19
label values q24 vl20
label values q25 vl21
label values q27_a vl22
label values q27_b vl22
label values q27_c vl22
label values q27_d vl22
label values q27_e vl22
label values q27_f vl22
label values q27_g vl22
label values q27_h vl22
label values q27i_jp vl22
label values q27j_jp vl22
label values q27k_jp vl22
label values q27l_jp vl22
label values q30 vl23
label values q32_jp vl24
label values q33 vl25
label values q34 vl26
label values q35 vl27
label values q36 vl28
label values q37 vl29
label values q38_a vl30
label values q38_b vl30
label values q38_c vl30
label values q38_d vl30
label values q38_e vl30
label values q38_f vl30
label values q38_g vl30
label values q38_h vl30
label values q38_i vl30
label values q38_j vl30
label values q38_k vl30
label values q39 vl31
label values q40_a vl32
label values q40_b vl32
label values q40_c vl32
label values q40_d vl32
label values q40e_jp vl32
label values q40f_jp vl32
label values q45 vl33
label values q46 vl34
label values q50 vl35
label values q51 vl36
label values q52a_jp vl37
label values q53a_jp vl38

label define cl_country 8 "Japan", replace
label values country cl_country
label define cl_lang 8001 "JP: Japanese", replace
label values language cl_lang
label define cl_mode 3 "CAWI", replace
label values mode cl_mode

* =====================================================================
* 7. Variable labels
* =====================================================================
label variable country "Country"
label variable wave "Wave"
label variable language "Language"
label variable int_length "time difference (minutes)"
label variable mode "mode"
label variable q1 "Q1. Respondent's еxact age"
label variable q2 "Q2. Respondent's age group"
label variable q3 "Q3. Respondent's gender"
label variable q4 "Q4. What region do you live in?"
label variable q5 "Q5. Which of these options best describes the place where you live?"
label variable q6_jp "Q6. JP only: In addition to the Statutory Health Insurance System (SHIS), are yo"
label variable q7 "Q7. What type of health insurance do you most frequently use?"
label variable q8 "Q8. What is the highest level of education that you have completed?"
label variable q9 "Q9. In general, would you say your health is:"
label variable q10 "Q10. In general, would you say your mental health, including your mood and your"
label variable q11 "Q11. Do you have any longstanding illness or health problem?"
label variable q12_a "Q12a. How confident are you that you are responsible for managing your health?"
label variable q12_b "Q12b. Can tell a healthcare provider your concerns even when not asked?"
label variable q12c_jp "Q12c_jp. JP only: How confident are you that you can figure out the best treatme"
label variable q12d_jp "Q12d_jp. JP only: How confident are you that you can understand what healthcare"
label variable q12e_jp "Q12e_jp. JP only: How confident are you that you can find the right information"
label variable q13 "Q13. Is there one healthcare facility or healthcare provider's group you usually"
label variable q14_jp "Q14. JP only: Is this a public, private, social security, NGO, or faith-based fa"
label variable q14_other "Q14. Other"
label variable q15 "Q15. What type of healthcare facility is this?"
label variable q15_other "Q15. Other"
label variable q16 "Q16. Why did you choose this healthcare facility? Please tell us the main reason"
label variable q16_other "Q16. Other"
label variable q17 "Q17. Overall, how would you rate the quality of healthcare you received in the p"
label variable q18 "Q18. How many healthcare visits in total have you made in the past 12 months?"
label variable q18_q19 "Q18/Q19. Total mumber of visits made in past 12 months (q18, q19 mid-point)"
label variable q19 "Q19. Total number of healthcare visits in the past 12 months choice(range)"
label variable q20 "Q20. Were all of the visits you made to the same healthcare facility?"
label variable q21 "Q21. How many different healthcare facilities did you go to in total?"
label variable q22 "Q22. How many visits did you have with a healthcare provider at your home?"
label variable q23 "Q23. How many virtual or telemedicine visits did you have in the past 12 months?"
label variable q24 "Q24. What was the main reason for the virtual or telemedicine visit?"
label variable q24_other "Q24. Other"
label variable q25 "Q25. How would you rate the overall quality of your last telemedicine visit?"
label variable q26 "Q26. Stayed overnight at a facility in past 12 months (inpatient care)"
label variable q27_a "Q27a. Blood pressure tested in the past 12 months"
label variable q27_b "Q27b. Breast examination"
label variable q27_c "Q27c. Received cervical cancer screening, like a pap test or visual inspection"
label variable q27_d "Q27d. Had your eyes or vision checked in the past 12 months"
label variable q27_e "Q27e. Had your teeth checked in the past 12 months"
label variable q27_f "Q27f. Had a blood sugar test in the past 12 months"
label variable q27_g "Q27g. Had a blood cholesterol test in the past 12 months"
label variable q27_h "Q27h. Received care for depression, anxiety, or another mental health condition"
label variable q27i_jp "Q27i_jp. JP only: Received an endoscope"
label variable q27j_jp "Q27j_jp. JP only: Received a barium swallow test"
label variable q27k_jp "Q27k_jp. JP only: Received a fecal occult blood test"
label variable q27l_jp "Q27l_jp. JP only: Received an electrocardiogram"
label variable q28_a "Q28a. A medical mistake was made in your treatment or care in the past 12 months"
label variable q28_b "Q28b. been treated unfairly or discriminated against by a doctor, nurse, or..."
label variable q28c_jp "Q28c_jp. JP only: did not get enough explanation on the disease"
label variable q28d_jp "Q28d_jp. JP only: had to wait a long time"
label variable q29 "Q29. Have you needed medical attention but you did not get it in past 12 months?"
label variable q30 "Q30. The last time this happened, what was the main reason you did not receive h"
label variable q30_other "Q30. Other"
label variable q31a "Q31a. Have you ever needed to borrow money to pay for healthcare"
label variable q31b "Q31b. Sell items to pay for healthcare"
label variable q31c_jp "Q31c_jp. JP only: Difficulty paying medical expenses; consulted with the governm"
label variable q31d_jp "Q31d_jp. JP only: was worried about whether I can pay medical or treatment fees"
label variable q32_jp "Q32_jp. JP only: Was the facility public or private?"
label variable q32_other "Q32. Other"
label variable q33 "Q33. What type of healthcare facility is this?"
label variable q33_other "Q33. Other"
label variable q34 "Q34. What was the main reason you went?"
label variable q34_other "Q34. Other"
label variable q35 "Q35. Was this a scheduled visit or did you go to the facility without an appt?"
label variable q36 "Q36. How long did you wait between making the appointment and seeing the health"
label variable q37 "Q37. Approximately how long did you wait before seeing the provider?"
label variable q37_other "Q37. Other"
label variable q38_a "Q38a. How would you rate the overall quality of care you received?"
label variable q38_b "Q38b. How would you rate the knowledge and skills of your provider?"
label variable q38_c "Q38c. How would you rate the equipment and supplies that the provider had?"
label variable q38_d "Q38d. How would you rate the level of respect your provider showed you?"
label variable q38_e "Q38e. How would you rate your provider knowledge about your prior visits and tes"
label variable q38_f "Q38f. How would you rate whether your provider explained things clearly?"
label variable q38_g "Q38g. How would you rate whether you were involved in your care decisions?"
label variable q38_h "Q38h. How would you rate the amount of time your provider spent with you?"
label variable q38_i "Q38i. How would you rate the amount of time you waited before being seen?"
label variable q38_j "Q38j. How would you rate the courtesy and helpfulness at the facility?"
label variable q38_k "Q38k. How would you rate how long it took for you to get this appointment?"
label variable q39 "Q39. How likely would recommend this facility to a friend or family member?"
label variable q40_a "Q40a. How would you rate the quality of care during pregnancy and childbirth lik"
label variable q40_b "Q40b. How would you rate the quality of childcare such as care of healthy childr"
label variable q40_c "Q40c. How would you rate the quality of care provided for chronic conditions?"
label variable q40_d "Q40d. How would you rate the quality of care provided for the mental health?"
label variable q40e_jp "Q40e_jp. How would you rate the quality of health checkup?"
label variable q40f_jp "Q40f_jp. How would you rate the quality of infertility treatment (e.g. artificia"
label variable q41_a "Q41a. How confident are you that you'd get good healthcare if you were very sick"
label variable q41_b "Q41b. How confident are you that you'd be able to afford the care you required?"
label variable q41_c "Q41c. How confident are you that the government considers the public's opinion?"
label variable q41d_jp "Q41d_jp. How confident are you that you would be able to afford the healthcare y"
label variable q41e_jp "Q41e_jp. How confident are you that you would be able to get the healthcare you"
label variable q41f_jp "Q41f_jp. How confident are you that you would receive good quality healthcare ev"
label variable q42 "Q42. How would you rate the quality of government or public healthcare system in"
label variable q43 "Q43. How would you rate the quality of the private for-profit healthcare system"
label variable q45 "Q45. Is your country's health system is getting better, staying the same or gett"
label variable q46 "Q46. Which of these statements do you agree with the most?"
label variable q47 "Q47. How would you rate the government's management of the COVID-19 pandemic ove"
label variable q48 "Q48. How would you rate the quality of care provided? (Vignette, option 1)"
label variable q49 "Q49. How would you rate the quality of care provided? (Vignette, option 2)"
label variable q50 "Q50. What is your native language or mother tongue?"
label variable q50_other "Q50. Other"
label variable q51 "Q51. Total monthly household income"
label variable q52a_jp "Q52a_jp. JP only: Which political party did you vote for in the last election?"
label variable q53a_jp "Q53a_jp. JP only: What would be your top priority if you were to vote in the nex"
label variable q53a_jp_other "Q53a. Other"
label variable respondent_serial "Respondent Serial #"
label variable respondent_id "Respondent ID"
label variable weight "Survey weight (merge from vendor file)"
label variable date "Fieldwork date (merge from vendor file)"

* =====================================================================
* 8. Order, clean up and save
* =====================================================================
* keep & order to match the released pvs_jp.dta layout
keep respondent_id country wave language date int_length mode weight ///
     respondent_serial q1-q53a_jp_other
order respondent_id country wave language date int_length mode weight q1 q2 q3 q4 q5 q6_jp q7 q8 q9 q10 q11 q12_a q12_b q12c_jp q12d_jp q12e_jp q13 q14_jp q14_other q15 q15_other q16 q16_other q17 q18 q18_q19 q19 q20 q21 q22 q23 q24 q24_other q25 q26 q27_a q27_b q27_c q27_d q27_e q27_f q27_g q27_h q27i_jp q27j_jp q27k_jp q27l_jp q28_a q28_b q28c_jp q28d_jp q29 q30 q30_other q31a q31b q31c_jp q31d_jp q32_jp q32_other q33 q33_other q34 q34_other q35 q36 q37 q37_other q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k q39 q40_a q40_b q40_c q40_d q40e_jp q40f_jp q41_a q41_b q41_c q41d_jp q41e_jp q41f_jp q42 q43 q45 q46 q47 q48 q49 q50 q50_other q51 q52a_jp q53a_jp q53a_jp_other respondent_serial
compress
save "pvs_jp_cleaned.dta", replace

di as result "Done. Wrote pvs_jp_cleaned.dta (" _N " obs)."
* (date, int_length, weight must be merged from the survey vendor file as noted above.)
