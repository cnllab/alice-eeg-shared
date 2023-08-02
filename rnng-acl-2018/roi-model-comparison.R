##
## RNNG model comparison
## 
## J Brennan
## originally run: 2/13/2018 
## last tested: 7/27/2023 with
## - R 4.2.0
## - tidyverse_1.3.1
## - lme4_1.1-29

#######################
# IMPORTANT NOTE:
# The whole-head analysis has two stochastic components (single-subject 
# control regressions are based on a random shuffle and group-analysis
# uses a permutation test). The random seeds for these tests were not saved
# so quantitatively exact replication is not possible.
# 
# The original ROI analysis was constrained to just whole-head "significant"
# predictors which may be slightly different under alternative randomizations.
#######################

setwd('path/to/this/analysis/')
library(ggplot2) 
library(tidyverse)
library(lme4)

##
## load data
##
# NOCOMP predictors are suffixed with '2'

d <- read.csv('../forR-rnng-roi.csv', stringsAsFactors = FALSE)

##
## Data Analysis Plan
##
# Look at 8 effects that were captured by the full RNNG
# and examine if they are better captured by the NOCOMP RNNG:
#
# 8 target predictors x 3 ROIs = 24 comparisons 

(alpha = 0.05 / 24) # bonferroni-correction = 0.002

summary <- read.csv('../regressions-rnng/results-summary0.txt', stringsAsFactors=FALSE)
summary[summary$isSig == 1,]
# Note that "significant" whole-head effects in the summary may differ from
# published results!! see NOTE at the top of the file


##
## Subset data and center
##

# subset IsLexical = 1

d %>% select(c(	'subject', 'IsLexical',
				'N400','P600', 'ANT', # dep measures
				'Sentence','Position','LogFreq', # control vars
				'LogFreq_Prev','LogFreq_Next','SndPower', 
				'lstm256Surprisal', 
				'k_10surprisal2', 'k_10surprisal', # target vars
				'k_20distance2', 'k_20distance',
				'k_20surprisal2', 'k_20surprisal',
				'k_40distance2', 'k_40distance',
				'k_40surprisal2', 'k_40surprisal',
				'k_40Hdelta2', 'k_40Hdelta',
				'k_60distance2', 'k_60distance',
				'k_60entropy2', 'k_60entropy'
				)) %>%
	 filter(IsLexical == 1) %>% # Just Lexical Items
	 filter_all(all_vars(!is.na(.))) %>% # No NAs
	 mutate_at(	vars(-subject, -N400, -P600, -ANT, -IsLexical), # Centered 
	 			funs(scale), 
	 			scale=FALSE) -> d2
	 			
# sndpwr * 1000 to bring it onto the same scale as other vars
d2$SndPower = d2$SndPower * 1000

##	
## VALIDATION CHECKS: 
###

# k40distance model on it's own against P600
# - this should be roughly the same as the whole-head cluster test we already ran

validation1 <- lmer(P600 ~ Sentence + Position + 
					LogFreq + LogFreq_Prev + LogFreq_Next + 
					SndPower + k_40distance + (1 | subject), 
					data=d2) 
summary(validation1) # t(k40distance) > 4 ... SUCCESS

# word frequency against N400
validation2 <- lmer(N400 ~ Sentence + Position + 
          LogFreq + LogFreq_Prev + LogFreq_Next + 
          SndPower + (1 | subject), 
					data=d2) 
summary(validation2) # t(LogFrqHAL) > 4 ... SUCCESS

###
### MAIN ANALYSIS
### (basis for Table 4)

mANT <- lmer(ANT ~ Sentence + Position + 
               LogFreq + LogFreq_Prev + LogFreq_Next + 
               SndPower + 
               lstm256Surprisal + 
               (1 | subject), 
             data=d2)
mP600 <- lmer(P600 ~ Sentence + Position + 
                LogFreq + LogFreq_Prev + LogFreq_Next + 
                SndPower +
                lstm256Surprisal + 
                (1 | subject), 
              data=d2)
mN400 <- lmer(N400 ~ Sentence + Position + 
                LogFreq + LogFreq_Prev + LogFreq_Next + 
                SndPower + 
                lstm256Surprisal + 
                (1 | subject), 
              data=d2)

## All of the following model comparisons have the same format:
# line 1: baseline model + RNNG-NOCOMP
# line 2: baseline model + RNNG-NOCOMP + Full RNNG
# line 3: likelihood ratio test (LRT)

# July 2023: The LRT p-values below are *close* but not precisely
# what was originally reported (shown as comments) 
# suspect changes in the LME4 optimizer

## ANT
ant01a <- update(mANT, . ~ . + k_10surprisal2) # p = 0.0553700
ant01b <- update(mANT, . ~ . + k_10surprisal2 + k_10surprisal) # p = 0.0002849 ***
anova(mANT, ant01a, ant01b) # 

ant02a <- update(mANT, . ~ . + k_20distance2) # p = 0.02694
ant02b <- update(mANT, . ~ . + k_20distance2 + k_20distance) # p = 0.13390
anova(mANT, ant02a, ant02b) # 

ant03a <- update(mANT, . ~ . + k_20surprisal2) # p = 0.0456955
ant03b <- update(mANT, . ~ . + k_20surprisal2 + k_20surprisal) # p = 0.0009826 ***
anova(mANT, ant03a, ant03b) # 

ant04a <- update(mANT, . ~ . + k_40distance2) # p = 0.01631
ant04b <- update(mANT, . ~ . + k_40distance2 + k_40distance) # p = 0.13809
anova(mANT, ant04a, ant04b) # 

ant05a <- update(mANT, . ~ . + k_40surprisal2) # p = 0.048236
ant05b <- update(mANT, . ~ . + k_40surprisal2 + k_40surprisal) # p = 0.001413 ***
anova(mANT, ant05a, ant05b) # 

ant06a <- update(mANT, . ~ . + k_40Hdelta2) # p = 0.00145 *** 
ant06b <- update(mANT, . ~ . + k_40Hdelta2 + k_40Hdelta) # p = 0.02165
anova(mANT, ant06a, ant06b) # 

ant07a <- update(mANT, . ~ . + k_60distance2) # p = 0.1042
ant07b <- update(mANT, . ~ . + k_60distance2 + k_60distance) # p = 0.2327
anova(mANT, ant07a, ant07b) # 

ant08a <- update(mANT, . ~ . + k_60entropy2) # p = 0.04555
ant08b <- update(mANT, . ~ . + k_60entropy2 + k_60entropy) # p < 0.01135
anova(mANT, ant08a, ant08b) # 

## P600
p60001a <- update(mP600, . ~ . + k_10surprisal2) # p = 0.6712
p60001b <- update(mP600, . ~ . + k_10surprisal2 + k_10surprisal) # p = 0.9356
anova(mP600, p60001a, p60001b) # 

p60002a <- update(mP600, . ~ . + k_20distance2) # p = 0.0002504 ***
p60002b <- update(mP600, . ~ . + k_20distance2 + k_20distance) # p =  0.0404683
anova(mP600, p60002a, p60002b) # 

p60003a <- update(mP600, . ~ . + k_20surprisal2) # p = 0.7748
p60003b <- update(mP600, . ~ . + k_20surprisal2 + k_20surprisal) # p =  0.8652
anova(mP600, p60003a, p60003b) # 

p60004a <- update(mP600, . ~ . + k_40distance2) # p = 6.886e-05
p60004b <- update(mP600, . ~ . + k_40distance2 + k_40distance) # p = 0.04966
anova(mP600, p60004a, p60004b) # 

p60005a <- update(mP600, . ~ . + k_40surprisal2) # p = 0.7498
p60005b <- update(mP600, . ~ . + k_40surprisal2 + k_40surprisal) # p = 0.7442
anova(mP600, p60005a, p60005b) # 

p60006a <- update(mP600, . ~ . + k_40Hdelta2) # p = 0.06784
p60006b <- update(mP600, . ~ . + k_40Hdelta2 + k_40Hdelta) # p = 0.83389
anova(mP600, p60006a, p60006b) # 

p60007a <- update(mP600, . ~ . + k_60distance2) # p = 0.0001873 ***
p60007b <- update(mP600, . ~ . + k_60distance2 + k_60distance) # p = 0.0663504
anova(mP600, p60007a, p60007b) # 

p60008a <- update(mP600, . ~ . + k_60entropy2) # p = 0.9831
p60008b <- update(mP600, . ~ . + k_60entropy2 + k_60entropy) # p = 0.7151
anova(mP600, p60008a, p60008b) # 


## N400
n40001a <- update(mN400, . ~ . + k_10surprisal2) # p = 0.72014
n40001b <- update(mN400, . ~ . + k_10surprisal2 + k_10surprisal) # p = 0.09483
anova(mN400, n40001a, n40001b) # 

n40002a <- update(mN400, . ~ . + k_20distance2) # p = 0.50695
n40002b <- update(mN400, . ~ . + k_20distance2 + k_20distance) # p = 0.03112
anova(mN400, n40002a, n40002b) # 

n40003a <- update(mN400, . ~ . + k_20surprisal2) # p = 0.75644
n40003b <- update(mN400, . ~ . + k_20surprisal2 + k_20surprisal) # p = 0.07676
anova(mN400, n40003a, n40003b) # 

n40004a <- update(mN400, . ~ . + k_40distance2) # p = 0.37963
n40004b <- update(mN400, . ~ . + k_40distance2 + k_40distance) # p = 0.08408
anova(mN400, n40004a, n40004b) # 

n40005a <- update(mN400, . ~ . + k_40surprisal2) # p = 0.76
n40005b <- update(mN400, . ~ . + k_40surprisal2 + k_40surprisal) # p = 0.0768 
anova(mN400, n40005a, n40005b) # 

n40006a <- update(mN400, . ~ . + k_40Hdelta2) # p = 0.72947
n40006b <- update(mN400, . ~ . + k_40Hdelta2 + k_40Hdelta) # p = 0.03537
anova(mN400, n40006a, n40006b) # 

n40007a <- update(mN400, . ~ . + k_60distance2) # p = 0.3365
n40007b <- update(mN400, . ~ . + k_60distance2 + k_60distance) # p = 0.3343
anova(mN400, n40007a, n40007b) # 

n40008a <- update(mN400, . ~ . + k_60entropy2) # p = 0.8908
n40008b <- update(mN400, . ~ . + k_60entropy2 + k_60entropy) # p = 0.4699 
anova(mN400, n40008a, n40008b) # 



