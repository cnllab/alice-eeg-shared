## Bracket closure and oscillations

Analysis testing for relationship between syntactic composition and power/phase in delta (1-4 Hz), theta (4-8) and gamma (30-40) bands.

> Brennan, J. R., & Martin, A. E. (2019). Phase synchronization varies systematically with linguistic structure composition. Philosophical Transactions of the Royal Society B, 375. https://doi.org/10.1098/rstb.2019.0305

To run:

1. Download and prepare the data with the [preprocessing pipeline](../preprocessing/README.md) (be sure to hold on to the raw data files)
2. Run the MATLAB script `run-phase-power-export-to-R.m` (exports per-trial power and phase values)
3. Run the R Markdown notebook `run-power-phase-analysis.Rmd` 
4. Run the MATLAB script `run-whole-head-regressions.m` 
5. Run the MATLAB script `run-whole-head-group-stats.m`

**Requirements** Data processing was was originally conducted in June 2019. The analysis was last tested with MATLAB 2022a, [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03), R 4.2.0, tidyverse 1.1.0, brms 2.17.0, emmeans 1.7.4, bayestestR 0.13.1, rstan 2.21.7

**Important Note** Statistical output when the full pipeline is run is not numerically identical to published results. Differences appear to reflect noise in how word word onset time-stamps were aligned to EEG samples (e.g. rounding differences) and API changes in some key functions (e.g. `bayestestR`). These differences do not appear to be consequential: Data values correlate with original values at $r > 0.99$ and statistical outputs are the same as original in terms of effect size and direction


