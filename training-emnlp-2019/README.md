# Testing for training data genre/size on capturing EEG signal with RNNG

Analysis testing the effect of training data genre and amount on the fit between Recurrent Neural Network Grammar (RNNG) estimates of predictability and EEG signals.

> Hale, J. T., Kuncoro, A., Hall, K. B., Dyer, C., & Brennan, J. R. (2019). Text genre and training data size in human-like parsing. Proceedings of EMNLP 2019. <https://doi.org/10/gmcgn3>

To run:

1. Prepare the data with the [preprocessing pipeline](../preprocessing/README.md)
2. Run the MATLAB script `run-eeg-export.m`
3. Run the R markdown notebook `run-training-analysis.Rmd` (R/RStudio)

**Requirements** The analysis was last tested with MATLAB 2022a, [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03), R 4.2.0, brms 2.17.0, loo 2.5.1. Rstudio is optional.


