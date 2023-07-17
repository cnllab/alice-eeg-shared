## Alice EEG 

Preprocessing and analyses for EEG data collected while participants listened to Chapter 1 of *Alice in Wonderland*

### Getting started

Raw data files available at <https://doi.org/10.7302/Z29C6VNH>

Data preprocessing requires MATLAB. 
Group statistical analyses require MATLAB, R, and STAN

1. Download the data (`S01.eeg` `S01.vhdr` `S01.vmrk` etc.) and place into a local directory
2. Download prePROCessing parameters (`proc.zip`) and unzip into a local directory
3. install fieldtrip for MATLAB (<https://www.fieldtriptoolbox.org>)

### Data Collection

EEG data were collected from March 2015 to December 2016 at the University of Michigan [Computational Neurolinguistics lab](http://sites.lsa.umich.edu/cnllab). Signals were recorded from 61 actively amplified electrodes in a equidistant layout (easycap M10), filtered  between 0.01 and 200 Hz and digitized at 500 Hz with a actiCHamp amplifier. A bipolar vertical EOG over the left eye (`VEOG`) was also collected along with a digitized copy of the acoustic input (`AUD`). 

Adult participants listened to 12 m audiobook recording of *Alice in Wonderland*, chapter 1 over insert earphones (Etymotic EA-2) at a loudness of 45 dB above individually-determined hearing threshold. The audio file was divied into 12 segments and a digital trigger was sent at the onset of each segment. The audio stimulus is available with the raw data as `audio.zip`

Full details of materials, participants, and data collection procedures can be found at:

> Brennan, J. R., & Hale, J. T. (2019). Hierarchical structure guides rapid linguistic predictions during naturalistic listening. PLoS ONE, 14(1), e0207741. <https://doi.org/10.1371/journal.pone.0207741>

and

> Bhattasali, S., Brennan, J., Luh, W.-M., Franzluebber, B., & Hale, J. (2020). The Alice datasets: FMRI  & EEG observations of natural language comprehension. Proceedings of the 12th International Language Resources and Evaluation Conference (LREC 2020). <https://www.aclweb.org/anthology/2020.lrec-1.15/>


### Data Analyses

#### Preprocessing

Several published analyses use the same preprocessed data files. The pipeline is described in detail at <https://doi.org/10.1371/journal.pone.0207741> (citation above). 

Data processing was was originally conducted with MATLAB 2017a and Fieldtrip mid-2017. The analysis was last tested with MATLAB 2022a and [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03)

#### PLoS One (published 2019)

Group analysis testing effects of structure on EEG signatures of predictabilty predictability presented in <https://doi.org/10.1371/journal.pone.0207741> (citation above)

Data processing was was originally conducted with MATLAB 2017a, Fieldtrip mid-2017, R 3.4.4, brms 2.1.0 and rstan 2.21.7. The analysis was last tested with MATLAB 2022am, [Fieldtrip 3be5222fc](https://github.com/fieldtrip/fieldtrip/commit/3be5222fc8d8ed28df9b1200fe2ebe22733c0c4b) (2023-05-03), R 4.2.0, brms 2.17.9, and rstan 2.21.7


#### Proc ACL (published 2018)

> Hale, J., Dyer, C., Kuncoro, A., & Brennan, J. (2018). Finding syntax in human encephalography with beam search. Proceedings of the 56th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers), 2727–2736. <https://doi.org/10/ggbzgt>

to be added

#### EMNLP 2019

> Hale, J. T., Kuncoro, A., Hall, K. B., Dyer, C., & Brennan, J. R. (2019). Text genre and training data size in human-like parsing. Proceedings of EMNLP 2019. <https://doi.org/10/gmcgn3>


to be added

### Phil Trans Royal Soc B (2020)

> Brennan, J. R., & Martin, A. E. (2019). Phase synchronization varies systematically with linguistic structure composition. Philosophical Transactions of the Royal Society B, 375. <https://doi.org/10.1098/rstb.2019.0305>

to be added

### Contact

Please direct questions and comments to Jonathan Brennan: <jobrenn@umich.edu>