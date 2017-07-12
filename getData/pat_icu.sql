CREATE OR REPLACE VIEW mimiciii.pat_icu AS 
 SELECT ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    ie.first_careunit,
    pat.gender,
    ie.intime,
    ie.outtime,
    adm.deathtime,
    round((ie.intime::date - pat.dob::date)::numeric / 365.242, 2) AS age,
    round((ie.intime::date - adm.admittime::date)::numeric / 365.242, 2) AS preiculos,
        CASE
            WHEN round((ie.intime::date - pat.dob::date)::numeric / 365.242, 2) <= 1::numeric THEN 'neonate'::text
            WHEN round((ie.intime::date - pat.dob::date)::numeric / 365.242, 2) <= 14::numeric THEN 'middle'::text
            WHEN round((ie.intime::date - pat.dob::date)::numeric / 365.242, 2) > 100::numeric THEN '>89'::text
            ELSE 'adult'::text
        END AS icustay_age_group,
        CASE
            WHEN adm.hospital_expire_flag = 1 THEN 'Y'::text
            ELSE 'N'::text
        END AS hospital_expire_flag
   FROM mimiciii.icustays ie
     JOIN mimiciii.patients pat ON ie.subject_id = pat.subject_id
     JOIN mimiciii.admissions adm ON ie.hadm_id = adm.hadm_id;

ALTER TABLE mimiciii.pat_icu
  OWNER TO postgres;