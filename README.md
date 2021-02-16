# ECON 499 - Honours Thesis
Work in Progress

## Contents
- /code
  - cleaning:
    - do_clean_nber_morg.do (in: morgXX.dta ; out: cleaned_nber_morg.dta)
      - `do` clean_nber_morg.do 
    - pareto_topcoding.do (in: cleaned_nber_morg.dta)
    - restructure_mwage.do (in: mw_state_quarterly.dta ; out: qmwage7919.dta)
  - pre-cleaning:
    - gen_cpi.ipynb
    - dind_nind_crosswalk.xlsx
  - tables:
    - sumstats.do (in: cleaned_nber_morg.dta)
  - figures:
    - ucov_race_sex_time.do (in: cleaned_nber_morg.dta)
    - kde1.do (in: cleaned_nber_morg.dta)
    - med_wage_time.do (in: cleaned_nber_morg.dta)
  - distribution regression stuff:
    - dist_dataprep.do (in: cleaned_nber_morg.dta)
- lab_var_wage.txt
  - wage and related variable labels outline
