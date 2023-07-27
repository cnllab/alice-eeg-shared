## Preprocessing for Alice EEG datasets

Several published analyses use the same preprocessed data files. The pipeline is described in detail in: 

> Brennan, J. R., & Hale, J. T. (2019). Hierarchical structure guides rapid linguistic predictions during naturalistic listening. PLoS ONE, 14(1), e0207741. <https://doi.org/10.1371/journal.pone.0207741>

and

> Bhattasali, S., Brennan, J., Luh, W.-M., Franzluebber, B., & Hale, J. (2020). The Alice datasets: FMRI  & EEG observations of natural language comprehension. Proceedings of the 12th International Language Resources and Evaluation Conference (LREC 2020). <https://www.aclweb.org/anthology/2020.lrec-1.15/>

To run:

1. Follow the "getting started" steps [here](../README.md)
2. Run `run_single_subject_preprocessing.m` script in MATLAB

**Requirements** Data processing was was originally conducted with MATLAB 2017a and Fieldtrip mid-2017. The analysis was last tested with MATLAB 2022a and [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03)
