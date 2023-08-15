## Alice EEG 

Preprocessing and analyses for EEG data collected while participants listened to Chapter 1 of *Alice in Wonderland*

### Getting started

Raw data files are available at <https://doi.org/10.7302/Z29C6VNH>

1. Download the data (`S01.eeg` `S01.vhdr` `S01.vmrk` etc.) and place into a local directory
2. Download prePROCessing parameters (`proc.zip`) and unzip into a local directory
3. install fieldtrip for MATLAB (<https://www.fieldtriptoolbox.org>)

### Data Collection

EEG data were collected from March 2015 to December 2016 at the University of Michigan [Computational Neurolinguistics lab](http://sites.lsa.umich.edu/cnllab). Signals were recorded from 61 actively amplified electrodes in a equidistant layout (easycap M10), filtered  between 0.01 and 200 Hz and digitized at 500 Hz with a actiCHamp amplifier. A bipolar vertical EOG over the left eye (`VEOG`) was also collected along with a digitized copy of the acoustic input (`AUD`). 

Adult participants listened to a 12 m audiobook recording of *Alice in Wonderland*, chapter 1 over insert earphones (Etymotic EA-2) at a loudness of 45 dB above individually-determined hearing threshold. The audio file was divied into 12 segments and a digital trigger was sent at the onset of each segment. The audio stimulus is available with the raw data as `audio.zip`

Full details on the materials, participants, and data collection procedures can be found at:

> Brennan, J. R., & Hale, J. T. (2019). Hierarchical structure guides rapid linguistic predictions during naturalistic listening. PLoS ONE, 14(1), e0207741. <https://doi.org/10.1371/journal.pone.0207741>

and

> Bhattasali, S., Brennan, J., Luh, W.-M., Franzluebber, B., & Hale, J. (2020). The Alice datasets: FMRI  & EEG observations of natural language comprehension. Proceedings of the 12th International Language Resources and Evaluation Conference (LREC 2020). <https://www.aclweb.org/anthology/2020.lrec-1.15/>


### Data Analyses

#### `preprocessing`

Several published analyses use the same preprocessed data files. The pipeline is described in detail at <https://doi.org/10.1371/journal.pone.0207741> (citation above). 

[How to run](preprocessing/README.md)

#### `surprisal-plosone-2019`

Analysis testing effects of structure on EEG signatures of predictabilty predictability published in <https://doi.org/10.1371/journal.pone.0207741> (citation above)

[How to run](surprisal-plosone-2019/README.md)

#### Proc ACL (published 2018)

Analysis testing the effect of syntactic representations on EEG signals using Recurrent Neural Network Grammars

> Hale, J., Dyer, C., Kuncoro, A., & Brennan, J. (2018). Finding syntax in human encephalography with beam search. Proceedings of the 56th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers), 2727–2736. <https://doi.org/10/ggbzgt>

[How to run](rnng-acl-2018/README.md)

#### EMNLP 2019

Analysis testing the effect of training data genre and amount on the fit between RNNG estimates of predictability and EEG signals

> Hale, J. T., Kuncoro, A., Hall, K. B., Dyer, C., & Brennan, J. R. (2019). Text genre and training data size in human-like parsing. Proceedings of EMNLP 2019. <https://doi.org/10/gmcgn3>

[How to run](training-emnlp-2019/README.md)

#### Phil Trans Royal Soc B (2020)

Analysis testing for effects of syntactic composition on phase synchrony in the delta, theta, and gamma bands.

> Brennan, J. R., & Martin, A. E. (2019). Phase synchronization varies systematically with linguistic structure composition. Philosophical Transactions of the Royal Society B, 375. <https://doi.org/10.1098/rstb.2019.0305>

[How to run](oscillations-ptrsb-2019/README.md)

### Contact

Please direct questions and comments to Jonathan R. Brennan: <jobrenn@umich.edu>