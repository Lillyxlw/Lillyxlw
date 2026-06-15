* People's Voice Survey (PVS) data cleaning for Japan - Wave 1
* Produces: pvs_jp.dta
* Last updated by: Liwei Xiang
*
* This is a corrected, runnable version of "JP clean.do". It imports the raw
* Ipsos Excel export and reproduces the cleaned pvs_jp.dta:
*       - Drops the extra JP-only questionnaire items
*       - Renames q* variables to the PVS standard
*       - Recodes outliers, skip patterns, refused (998), and don't know (999)
*       - Builds composite/derived variables, labels variables and values
*       - Recodes "other, specify" responses
*       - Reorders and saves
*
* Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing
*
* NOTE on date / int_length / weight:
*   These three variables appear in the final pvs_jp.dta but have NO source
*   column in this Excel export. They come from the Ipsos sample metadata
*   (interview date / interview length) and a separate post-stratification
*   weighting step. They cannot be regenerated from this Excel alone. The
*   blocks below are left as documented placeholders -- merge them in from the
*   sample/weight file before saving if you need an exact reproduction.

clear all
set more off

*********************** Japan ***********************

* ---- Configurable paths (edit these two lines only) ----------------------- *
* Folder that holds the raw Excel and where pvs_jp.dta will be written.
global jp_dir "."
global rawfile "$jp_dir/25-055861-01 Kyushu Univ Data_revised.xlsx"

* Import raw data
import excel using "$rawfile", firstrow clear case(lower)

*------------------------------------------------------------------------------*
* Drop extra questions (JP questionnaire extras: q4,5,13,24,25,26,27,58 etc.)
drop q0 q4 q5 q5codes q13*scale ///
        q24 q25 q25other1 q2616 q2626 q2636 q2646 q2656 q2666 q26other1 q27 q437confirm ///
        trp1 trp214 trp224 trp234 trp244

*------------------------------------------------------------------------------*
* Generate / keep ID variables

* respondent_serial (kept in final data)  -- FIX: do NOT drop it
rename respondentserial respondent_serial

* respondent_id
gen respondent_id = "JP" + string(respondent_serial)

* country
gen country = 8
lab def country 8 "Japan"
lab values country country

*Label as wave 1 data:
gen wave = 1

* language
gen language = 8001
lab def Language 8001 "JP: Japanese"
lab val language Language

* mode  -- matches pvs_jp.dta (mode = 3)
gen mode = 3
lab def mode 3 "CAWI"
lab val mode mode

* date / int_length / weight  -- not in this Excel; merge from sample/weight file
* gen date       = .   // interview date (Stata daily date) from Ipsos metadata
* gen int_length = .   // interview length in minutes from Ipsos metadata
* gen weight     = .   // post-stratification survey weight

*------------------------------------------------------------------------------*
* Rename variables to PVS standard

rename (q6 q7 q8) (q4 q5 q7) // q6 is created later from q7
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
* Combine the separate "998/Codes" columns back into their parent variables
replace q18 = q18codes if !missing(q18codes)
replace q21 = q21codes if !missing(q21codes)
replace q22 = q22codes if !missing(q22codes)
replace q23 = q23codes if !missing(q23codes)
replace q39 = q39codes if !missing(q39codes)
drop q18codes q21codes q22codes q23codes q39codes

* q2 (age group)
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

* q6_jp (insured)
recode q7 (1 = 1) (2 = 0), gen(q6_jp)
lab def q6_label 0 " No, do not have private insurance" 1 "Yes, have private insurance"
lab val q6_jp q6_label

* q7 (insured_type)
recode q7 (999 = .a)
lab def q7_label 1 "JP: Additional private insurance" 2 "JP: Only public insurance" .a "NA"
lab val q7 q7_label

* q8 (education) - keep the raw JP categories (no collapse), matches pvs_jp.dta
lab def q8_label 1 "Junior high school" 2 "High school" ///
    3 "Vocational school, junior college, technical college" ///
    4 "Four-year university" 5 "Postgraduate school or higher"
lab val q8 q8_label

* q9 (general health)
recode q9 (999 = .a)
lab def q9_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q9 q9_label

* q10 (mental health)
recode q10 (999 = .a)
lab def q10_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q10 q10_label

* q11 (longstanding illness) - collapse the 16 condition items into a single yes/no
* CAVEAT: this composite does NOT bit-for-bit reproduce the q11 column in the
* current pvs_jp.dta (~167/2000 rows differ, in both directions). The stored q11
* is not a function of these Q12-matrix items in this Excel, so it appears to
* have been built from a standalone longstanding-illness question / source not
* present in this export. Confirm the intended q11 definition before relying on it.
foreach v of varlist q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp {
    replace `v' = .a if `v' == 999
}
egen total_q11 = rowtotal(q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp)
gen q11 = total_q11 > 0
label define q11_label 0 "No" 1 "Yes"
label values q11 q11_label
drop q11a_jp q11b_jp q11c_jp q11d_jp q11e_jp q11f_jp q11g_jp q11h_jp q11i_jp q11j_jp q11k_jp q11l_jp q11m_jp q11n_jp q11o_jp q11p_jp q11q_jp total_q11

* q12_a (confident managing health)
recode q12_a (999 = .a)
lab def q12_label 0 "Not at all confident" 1 "Not too confident" 2 "Somewhat confident" 3 "Very confident" .a "NA"
lab val q12_a q12_label

* q12_b (tell provider concerns)
recode q12_b (999 = .a)
lab val q12_b q12_label

* q12c_jp (best treatment)
recode q12c_jp (999 = .a)
lab val q12c_jp q12_label

* q12d_jp (understand)
recode q12d_jp (999 = .a)
lab val q12d_jp q12_label

* q12e_jp (find information)
recode q12e_jp (999 = .a)
lab val q12e_jp q12_label

* q13 (specific facility visit)
recode q13 (999 = .a)
lab def q13_label 0 "No" 1 "Yes" .a "NA"
lab val q13 q13_label

* q14_jp (pub/pri facility)
replace q14_jp = .a if q14_jp == .
lab def q14_jp_label 1 "Public" 2 "Private" 3 "Other(specify)" .a "NA"
lab val q14_jp q14_jp_label

* q15 (type of facility)
replace q15 = .a if q15 == .
lab def q15_label 1 "Doctor's office or clinic" 2 "Hospital where referrals are not required" 3 "Hospital where referrals are required" 4 "Other(specify)" .a "NA"
lab val q15 q15_label

* q16 (why this facility)
recode q16 (8 = 21)
replace q16 = .a if q16 == .
lab def q16_label 1 "Low cost" 2 "Short distance" 3 "Short waiting time" 4 "Good healthcare provider skills" ///
                  5 "Staff shows respect" 6 "Medicines and equipment are available" 7 "Only facility available" ///
                  8 "Covered by insurance" 9 "Other(specify)" 21 "JP: Positive online or social media reviews" .a "NA"
lab val q16 q16_label

* q17 (overall rating of received healthcare)
replace q17 = .a if q17 == .
recode q17 (5 = .a) (999 = .)
lab def q17_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA"
lab val q17 q17_label

* q18 (# of visits)
recode q18 (998 = .d) (999 = .a)
lab def q18_label .d "Don't know" .a "NA"
lab val q18 q18_label

* q19 (categorized # of visits) - shift codes down by 1 (1-4 -> 0-3) to match output
replace q19 = .a if q19 == .
recode q19 (999 = .)
recode q19 (1 = 0) (2 = 1) (3 = 2) (4 = 3)
lab def q19_label 0 "0" 1 "1-4" 2 "5-9" 3 "10 or more" .a "NA" .r "Refused"
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

* q27_a .. q27l_jp (screening/tests)
lab def q27_label 0 "No" 1 "Yes" .a "NA" .d "Don't know"
recode q27_a (999 = .a) (998 = .d)
lab val q27_a q27_label
foreach v in q27_b q27_c q27_d q27_e q27_f q27_g q27_h q27i_jp q27j_jp q27k_jp q27l_jp {
    replace `v' = .a if `v' == .
    recode `v' (999 = .a) (998 = .d)
    lab val `v' q27_label
}

* q28_a .. q28d_jp (negative experiences)
lab def q28_label 0 "No" 1 "Yes" .a "I did not get healthcare in past 12 months"
foreach v in q28_a q28_b q28c_jp q28d_jp {
    replace `v' = .a if `v' == .
    recode `v' (999 = .)
    lab val `v' q28_label
}

* q29 (not get healthcare)
recode q29 (999 = .a)
lab def q29_label 0 "No" 1 "Yes" .a "NA"
lab val q29 q29_label

* q30 (reason)
recode q30 (7 = 24) (9 = 25) (10 = 26) (11 = 27) (8 = 7) (12 = 10)
lab def q30_label 1 "High cost (e.g., high out of pocket payment, not covered by insurance)" ///
                  2 "Far distance (e.g., too far to walk or drive, transport not readily available)" ///
                  3 "Long waiting time (e.g., long line to access facility, long wait for the provider)" ///
                  4 "Poor healthcare provider skills (e.g., spent too little time with patient, did not conduct a thorough exam)" ///
                  5 "Staff don't show respect (e.g., staff is rude, impolite, dismissive)" ///
                  6 "Medicines and equipment are not available (e.g., medicines regularly out of stock, equipment like X-ray machines broken or unavailable)" ///
                  7 "Illness not serious enough" 10 "Other (specify)" 24 "JP: Equipment like X-ray machines are broken or unavailable" ///
                  25 "JP: Do not want health care providers to know of the disease or to show the symptomatic part of the body" ///
                  26 "JP: Busyness" 27 "JP: Did not want to hear about unfavorable diagnoses" .a "NA"
lab val q30 q30_label

* q31a .. q31d_jp (financial)
lab def q31_label 0 "No" 1 "Yes" .a "NA"
lab val q31a q31_label
foreach v in q31b q31c_jp q31d_jp {
    recode `v' (999 = .a)
    lab val `v' q31_label
}

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

* q36 (wait to appointment)
replace q36 = .a if q36 == .
lab def q36_label 1 "Same or next day" 2 "2 days to less than one week" 3 "1 week to less than 2 weeks" ///
                  4 "2 weeks to less than 1 month" 5 "1 month to less than 2 months" 6 "2 months to less than 3 months" ///
                  7 "3 months to less than 6 months" 8 "6 months or more" .a "NA"
lab val q36 q36_label

* q37 (wait at facility)
replace q37 = .a if q37 == .
recode q37 (999 = .)
lab def q37_label 1 "Less than 15 minutes" 2 "15 minutes to less than 30 minutes" 3 "30 minutes to less than 1 hour" ///
                  4 "1 hour to less than 2 hours" 5 "2 hours to less than 3 hours" 6 "3 hours to less than 4 hours" ///
                  7 "More than 4 hours (specify))" .a "NA" .r "Refused"
lab val q37 q37_label

* q38_a .. q38_k (quality ratings)
lab def q38_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor" .a "NA" 5 "I have not had prior visits or tests" 6 "The clinic had no other staff"
foreach v in q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k {
    replace `v' = .a if `v' == .
    recode `v' (999 = .)
    lab val `v' q38_label
}

* q39 (recommend)
replace q39 = .a if q39 == .
recode q39 (999 = .)
lab def q39_label .a "NA"
lab val q39 q39_label

* q40_a .. q40f_jp (system quality by service)
lab def q40_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor" .d "I am unable to judge" .a "NA"
foreach v in q40_a q40_b q40_c q40_d q40e_jp q40f_jp {
    recode `v' (999 = .a) (5 = .d)
    lab val `v' q40_label
}

* q41_a .. q41f_jp (confidence)
lab def q41_label 3 "Very confident" 2 "Somewhat confident" 1 "Not too confident" 0 "Not at all confident" .a "NA"
foreach v in q41_a q41_b q41_c q41d_jp q41e_jp q41f_jp {
    recode `v' (999 = .a)
    lab val `v' q41_label
}

* q42 (public system) / q43 (private system)
recode q42 (999 = .)
lab def q42_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor"
lab val q42 q42_label
recode q43 (999 = .)
lab val q43 q42_label

* q45 (better, same, worse)
recode q45 (999 = .) (1 = 2) (2 = 1) (3 = 0)
lab def q45_label 2 "Getting better" 1 "Staying the same" 0 "Getting worse"
lab val q45 q45_label

* q46 (rebuild, major, minor)
recode q46 (999 = .)
lab def q46_label 1 "Our healthcare system has so much wrong with it that we need to completely rebuild it." ///
                    2 "There are some good things in our healthcare system, but major changes are needed to make it work better." ///
                    3 "On the whole, the system works pretty well and only minor changes are necessary to make it work better."
lab val q46 q46_label

* q47 (covid management)
recode q47 (999 = .)
lab def q47_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor"
lab val q47 q47_label

* q48 / q49 (vignettes)
recode q48 (999 = .)
lab def q48_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor"
lab val q48 q48_label
recode q49 (999 = .)
lab def q49_label 4 "Excellent" 3 "Very good" 2 "Good" 1 "Fair" 0 "Poor"
lab val q49 q49_label

* q50 (mother tongue)
recode q50 (999 = .)
lab def q50_label 1 "Japanese" 2 "Chinese" 3 "Korean" 4 "Vietnamese" 5 "Tagalog" 6 "Spanish" 7 "English" 8 "Other (specify)"
lab val q50 q50_label

* q51 (income)
recode q51 (999 = .)
lab def q51_label 1 "Less than 3 million yen" 2 "3 million-less than 4.8 million yen" 3 "4.8 million-less than 6.5 million yen" ///
                    4 "6.5 million-less than 8.5 million yen" 5 "8.5 million yen or over"
lab val q51 q51_label

* q52a_jp (political party)
recode q52a_jp (998 = .d)
lab def q52_label 1 "Liberal Democratic Party" 2 "Constitutional Democratic Party" 3 "Komeito" ///
                    4 "Japan Innovation Party" 5 "Japanese Communist Party" 6 "Reiwa Shinsengumi" 7 "Social Democratic Party" 8 "Democratic Party for the People" ///
                    9 "Sanseito" 10 "Other" 11 "Did not vote" .d "Don't know"
lab val q52a_jp q52_label

* q53a_jp (priority of election)
recode q53a_jp (999 = .a) (998 = .d)
lab def q53_label 1 "Healthcare system" 2 "Economic policy" 3 "Education" ///
                    4 "Welfare" 5 "Foreign affairs" 6 "Defense" 7 "Environmental and energy policy" 8 "Employment and labor policy" ///
                    9 "Taxation and fiscal policy" 10 "Transportation and infrastructure policy" 11 "Other (specify)" .d "Don't know"
lab val q53a_jp q53_label

*------------------------------------------------------------------------------*
* Shift JP-specific category sets to 8000+ and re-label, keeping original text
local q4l  q4_label
local q5l  q5_label
local q7l  q7_label
local q8l  q8_label
local q15l q15_label
local q33l q33_label
local q50l q50_label
local q51l q51_label
* NOTE: q52a_jp and q53a_jp are intentionally NOT shifted to 8000+ (the stored
* pvs_jp.dta keeps them on their native 1-11 codes with q52_label / q53_label).

foreach q in q4 q5 q7 q8 q15 q33 q50 q51 {

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
        if (`v' < .) {
            local newcode = 8000 + `v'
            elabel define `q'_label `newcode' `"JP: `l'"', modify
        }
    }

    * 4) Apply the new labels
    label values `q' `q'_label
}

*------------------------------------------------------------------------------*
* Implausible-value checks (Q17-Q23 visit consistency)
gen q18_q19 = q18
recode q18_q19 (. = 0)   if q19 == 1
recode q18_q19 (. = 2.5) if q19 == 2
recode q18_q19 (. = 5)   if q19 == 3
recode q18_q19 (. = 10)  if q19 == 4

list q18_q19 q19 q21 if q21 > q18_q19 & q21 < .
list q20 q21 if q21 == 0 | q21 == 1
list q20 q21 if q20 == 1 & q21 > 0 & q21 < .

egen visits_total = rowtotal(q18_q19 q22 q23)
list visits_total q17 if q17 == 5 & visits_total > 0 & visits_total < .
drop visits_total

*------------------------------------------------------------------------------*
* "Other, specify" recode
* Requires the input spreadsheet specifyrecode_inputs_6.xlsx (sheet other_specify_recode).
* q11_other is NOT carried forward (q11 is collapsed to a yes/no composite),
* so drop it here to match pvs_jp.dta.
drop q11_other

* Preserve the original free-text before the recode overwrites it.
gen q14_other_original     = q14_other
label var q14_other_original "Q14. Other"
gen q15_other_original     = q15_other
label var q15_other_original "Q15. Other"
gen q16_other_original     = q16_other
label var q16_other_original "Q16. Other"
gen q24_other_original     = q24_other
label var q24_other_original "Q24. Other"
gen q30_other_original     = q30_other
label var q30_other_original "Q30. Other"
gen q32_other_original     = q32_other
label var q32_other_original "Q32. Other"
gen q33_other_original     = q33_other
label var q33_other_original "Q33. Other"
gen q34_other_original     = q34_other
label var q34_other_original "Q34. Other"
gen q37_other_original     = q37_other
label var q37_other_original "Q37. Other"
gen q50_other_original     = q50_other
label var q50_other_original "Q50. Other"
gen q53a_jp_other_original = q53a_jp_other
label var q53a_jp_other_original "Q53a. Other"

* NOTE: ipacheckspecifyrecode needs the input file below. It is skipped
* automatically if the file is not present.
capture ipacheckspecifyrecode using "$jp_dir/specifyrecode_inputs_6.xlsx", ///
    sheet(other_specify_recode) id(respondent_id)
if _rc {
    di as txt "Note: specifyrecode_inputs_6.xlsx not found; skipping other-specify recode."
}

drop q14_other q15_other q16_other q24_other q30_other q32_other q33_other q34_other q37_other q50_other q53a_jp_other
ren q14_other_original     q14_other
ren q15_other_original     q15_other
ren q16_other_original     q16_other
ren q24_other_original     q24_other
ren q30_other_original     q30_other
ren q32_other_original     q32_other
ren q33_other_original     q33_other
ren q34_other_original     q34_other
ren q37_other_original     q37_other
ren q50_other_original     q50_other
ren q53a_jp_other_original q53a_jp_other

*------------------------------------------------------------------------------*
* Reorder variables
order q*, sequential
* Lead with the survey-design variables that exist (date/int_length/weight are
* only present if you merged them in from the sample/weight file above).
foreach v in weight mode int_length date language wave country respondent_id {
    capture order `v', first
}

*------------------------------------------------------------------------------*
* Save data
save "$jp_dir/pvs_jp.dta", replace

*------------------------------------------------------------------------------*
