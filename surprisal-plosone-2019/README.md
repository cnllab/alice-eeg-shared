## PCFC Surprisal analysis for Alice EEG

Group analysis testing effects of structure on EEG signatures of predictabilty predictability published in 

> Brennan, J. R., & Hale, J. T. (2019). Hierarchical structure guides rapid linguistic predictions during naturalistic listening. PLoS ONE, 14(1), e0207741. <https://doi.org/10.1371/journal.pone.0207741>

To run:

1. Prepare the data with the [preprocessing pipeline](../preprocessing/README.md)
2. Run the script `run_single_subject_correlations.m` (MATLAB)
3. Run the script `run_group_analysis.m` (MATLAB)
4. Run the script `run_roi_export_to_R.m` (MATLAB)
5. Run the script `run_roi_analysis.R` (R)

**Requirements** Data processing was was originally conducted with MATLAB 2017a, Fieldtrip mid-2017, R 3.4.4, brms 2.1.0 and rstan 2.21.7. The analysis was last tested with MATLAB 2022a, [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03), R 4.2.0, brms 2.17.9, and rstan 2.21.7

