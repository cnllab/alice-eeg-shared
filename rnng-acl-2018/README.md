## Testing for syntax in EEG singals using RNNG

Analysis testing the effect of syntactic representations on EEG signals using Recurrent Neural Network Grammars

> Hale, J., Dyer, C., Kuncoro, A., & Brennan, J. (2018). Finding syntax in human encephalography with beam search. Proceedings of the 56th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers), 2727–2736. <https://doi.org/10/ggbzgt>

To run:

1. Download and prepare the data with the [preprocessing pipeline](../preprocessing/README.md)
2. Run the MATLAB script `run-group-analysis.m`
3. Run the R script `roi-model-comparison.R` 

**Requirements** Data processing was was originally conducted in February 2018. The analysis was last tested with MATLAB 2022a, [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03), R 4.2.0, tidyverse 1.1.0, and lme4 1.1-29
