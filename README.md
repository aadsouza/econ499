# ECON 499: Labor Unions and Racial Wage Inequality
Pending revisions requested by defense committee.
## Contents
- /code
  - cleaning:
    - clean_nber_morg.do 
      - cleans nber extracts of cps morg.
    - do_clean_nber_morg.do (in: morgXX.dta ; out: cleaned_nber_morg.dta)
      - `do` clean_nber_morg.do 
    - pareto_topcoding.do (in: cleaned_nber_morg.dta)
      - gen top-code adjusted wage distribution using pareto parameters following fll2021.
  - pre-cleaning:
    - gen_cpi.ipynb
      - generates cpi using cpiaucsl from fred + other stuff from fred.
    - dind_nind_crosswalk.xlsx
      - crosswalk between cps industry and fll2021 industry categories.
    - state_cps_fips_abb_name.csv
      - adapt crosswalk from dm2020 for state, statefips, stateabb, state.
  - analysis (either in paper/appendix or referenced existence in replication package):
    - dfl1.do
      - heywood parent extended dfl decomposition.
    - linreg.do
      - state-ind unionization rate ols regressions.
    - linreg2.do
      - naive ols wage on union coverage.
    - med_wage_time.do
      - gen median lwage3 time trends by race and sex.
    - nindnocctab.do
      - percentage and union coverage in each ind table.
    - rifdid-plots.ipynb
      - rifdid plots w/o sltt (state linear time trends).
    - rifdid-sltt-bw-plots.ipynb
      - rifdid plots w/ sltt separately by race and sex.
    - rifdid-sltt-bw.do
      - run rifdid separately for B/w w/ state linear time trends
    - rifdid-sltt-plots-wo-ar2w.ipynb
      - rifdid plots w/ sltt w/o always rtw states.
    - rifdid-sltt-plots.ipynb
      - rifdid plots w/ sltt.
    - rifdid-sltt-wo-ar2w.do
      - run rifdid w/ sltt w/o always rtw states.
    - rifdid-sltt.do
      - run rifdid w/ sltt.
    - rifdid.do
      - run rifdid w/o sltt.
    - rifdiddiagnostics.do
      - run rifdid separately for B/w w/o sltt.
    - rifreg2.do
      - run naive rifols wage on union coverage.
    - rifreg2bw.do
      - run naive rifols wage on union coverage separately by race and sex.
    - rifreg2plots-bw.ipynb
      - rifols wage on union coverage plots separately by race and sex.
    - rifreg2plots.ipynb
      - rifols wage on union coverage plots.
    - stag_event.do
      - run event study that doesnt work.
    - stagdid-ptaplot.do
      - gen plots for predicted real log wage trends.
    - stagdid-wo-ar2w.do
      - run did - effect of rtw on B/w wage inequality - w/o always rtw states.
    - stagdid.do
      - run did - effect of rtw on B/w wage inequality.
    - stagsynthblack.do
      - synth - effect of rtw on wages for Black people.
    - stagsynthwhite.do
      - synth - effect of rtw on wages for white people.
    - stagsynthwhitewone.do
      - synth - effect of rtw on wages for white people. - dropped states for lack of common support.
    - sumstats.do
      - gen sumstats table.
    - ucov_race_sex_time.do
      - gen coverage rate time trends by race and sex >= 1983.
  - miscellaneous stuff + graveyard (attempts and analyses that may not have made it into the paper)
    - restructure_mwage.do (in: mw_state_quarterly.dta ; out: qmwage7919.dta)
      - restructure Zipperer's quarterly state minimum wages. 
    - dist_dataprep.do (in: cleaned_nber_morg.dta)
      - prepare data for distribution regressions following fll2021.
    - distreg1.do
      - first (only?) attempt at distribution regression following fll2021.
    - marg_crate.do
      - marginal effects of unionization rates consistent with fll2021.
    - bacondecomp.do
      - intended to run bacondecomp i.e. Goodman-Bacon decomp of stagdid (need to manipulate goodman-bacon ado to accomodate interaction).
    - cit_hisp_linreg.do
      - state-ind unionization rate ols for Hispanic people with citizen variable.
    - kde1.do
      - yearly kernel density estimates for white people, Black people, and Hispanic people.
    - morediagnostics.do
      - "more diagnostics"? for the RIF-DiD analysis of RTW laws (not sure what this ended up being).
    - rifdistributionplots-revised.ipynb
      - draft?
    - rifdistributionplots8919-bootstrap-w-errors.ipynb
      - i guess there are errors here?
    - riffig7.ipynb
      - more rifs.
    - rifreg1.do
      - rif on dfl attempt.
    - rifreg3.do
      - rifols state-ind unionization rate regressions.
    - stagarnr
      - compare alwaysr2w to neverr2w - so treat_st = treat_s (not DiD, post treat and post cont comparison)?
    - staghisp.do
      - run did - effect of rtw on Hispanic-white inequality.
    - dfl-3per.do
      - heywood parent extended dfl decomposition, only 8388 period.
- /dfl1
  - dfl1.log
- /distreg
  - note: distribution regression log files.
- /figures
  - note: figures and plots for analysis and graveyard.
- /linreg
  - note: log files for most analysis and graveyard.
- /tabs
  - note: tables for analysis and graveyard.
- lab_var_wage.txt
  - wage and related variable labels outline
- 495preliminaryprospectus.bib
  - bibtex file for most/all literature cited in proposal.
- 499data.bib
  - bibtex file for literature cited in thesis.
## NBER extracts of CPS MORG
- [`econ499data` directory with cleaned data etc.](https://www.dropbox.com/sh/fveewbp3c82h6fw/AAA8vwEASsThsv_Ww3HxKzrja?dl=0) - used in `.do` files.
- [NBER extracts of CPS MORG found here](https://data.nber.org/morg/annual/).
- [NBER CPS MORG Documentation found here](https://data.nber.org/morg//docs/cpsx.pdf).
## Acknowledgements
I am extremely grateful to Professor Nicole Fortin and Professor Marit Rehavi for their continued guidance and support. I thank Professor Thomas Lemieux for extensive feedback and insights. I am indebted to Professor Nicole Fortin and Neil Lloyd for generously providing Stata codes that expedited the data cleaning process. I also thank Sheldon Birkett, Felipe Grosso, Elisabeth Hatting, Wenxin Ma, Evan Mauro, Javier Cort&eacute;s Orihuela, and Sarah Kirker Wappel for helpful discussions and comments. All errors are my own.
