## ROI Analysis for Alice in Wonderland Surprisal 
# (Summarized in Fig. 4)

# originally run on
#   R 3.4.4
#   brms 2.1.0
#   rstan 2.17.3
# last tested on
#   R 4.2.0
#   brms_2.17.0
#   rstan_2.21.7

# Data exported with run_roi_export_to_R.m as "roi-output.csv"

working_dir <- 'path/to/directory/with/roi-output.csv'

setwd(working_dir)

# load data - slow: ~89 MB!
d <- read.csv('roi-output.csv', 
              na.strings = 'NaN', 
              stringsAsFactors=FALSE) 

head(d)
str(d)
summary(d)

#############################
# Center & scale predictors #
#############################

d[,'iscontent'] <- d[,'iscontent'] - 0.5 # contrast code: [-0.5 0.5]
for (i in 7:15) {
  d[,i] = d[,i] - mean(d[,i], na.rm=TRUE)
}

# Rescale vars to get them generally on a +/- 10 scale
#   scale sndpwr up by x 100
d$sndpwr <- d$sndpwr * 100
#   scale sentence by / 10
d$sentence <- d$sentence / 10
#   scale position by / 10
d$position <- d$position / 10


######################
# Correlation Matrix #
######################

dsub <- subset(d, subject == unique(d$subject)[1])

round(cor(dsub[7:15]), 3)


#################
# Modeling Plan #
#################
# 6 ROIs 
# - bonferroni across ROIs: /6
#
# 1. cfg-lex-2     left anterior  216-445 ms
# 2. cfg-lex-3     right anterior 216-554 ms
# 3. ngram-func-1  right anterior 174-420 ms
# 4. ngram-func-2  mid anterior   102-158 ms
# 5. rnn-func-1    right anterior 174-252 ms
# 6. cfg-func-1    right anterior 210-310 ms
#
# Four questions = two model comparison's-per-question
# -> bonferroni correction / 2
# -> no bonferroni correction across questions; these test diff hypotheses
#
# (Q1) CFG > Ngram or RNN?
#       C. Null + Ngram + Ngram:WC + RNN + RNN:WC + CFG + CFG:WC
#       B. Null + Ngram + Ngram:WC + RNN + RNN:WC + CFG 
#       A. Null + Ngram + Ngram:WC + RNN + RNN:WC 
#
# (Q2) Ngram > CFG?
#       C. Null + CFG + CFG:WC + NGram + NGram:WC
#       B. Null + CFG + CFG:WC + Ngram
#       A. Null + CFG + CFG:WC 
#
# (Q3) RNN > CFG?
#       C. Null + CFG + CFG:WC + RNN + RNN:WC
#       B. Null + CFG + CFG:WC + RNN 
#       A. Null + CFG + CFG:WC 
#
# (Q4) RNN > Ngram?
#       C. Null + Ngram + Ngram:WC + RNN + RNN:WC
#       B. Null + Ngram + Ngram:WC + RNN 
#       A. Null + Ngram + Ngram:WC 
#
# Final bonferroni-corrected Cred Interval = 0.05/6/2 = +/- 99.58%

###########################
# Create models with BRMS #
###########################
# use stanplot() for traditional forest plot
# ?bayesplot for many other options or 
# ?launch_shinystan for interactive exploring
# On priors: https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations

library(ggplot)
library(brms)
library(gridExtra)
options(mc.cores=4) # adjust for your compute environment

# adjust CrIs for multiple comparisons
outer <- 1 - 0.05 / 6 / 2 # 0.9958333

# Prepare to loop over ROIs and comparisons
rois = unique(d$roi) 
formulas = list(
  list( # Q1 formulas
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + ngram + ngram:iscontent + rnn + rnn:iscontent + cfg + 
              iscontent:cfg + (1+iscontent+sentence|subject)), # Q1 C model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + ngram + ngram:iscontent + rnn + rnn:iscontent + cfg + 
              (1+iscontent+sentence|subject)), # Q1 B
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + ngram + ngram:iscontent + rnn + rnn:iscontent + 
              (1+iscontent+sentence|subject)) # Q1 A     
    ),
  list( # Q2 formulas
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + cfg + iscontent:cfg + ngram + ngram:iscontent + 
              (1+iscontent+sentence|subject)), # Q2 C model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + cfg + iscontent:cfg + ngram + 
              (1+iscontent+sentence|subject)), # Q2 B model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + cfg + iscontent:cfg + 
              (1+iscontent+sentence|subject)) # Q2 A model
  ),
  list( # Q3 formulas
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + cfg + iscontent:cfg + rnn + rnn:iscontent + 
              (1+iscontent+sentence|subject)), # Q3 C model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + cfg + iscontent:cfg + rnn + 
              (1+iscontent+sentence|subject)) # Q3 B model
   # Q3 A == Q2 A
  ),
  list( # Q4 formulas
     # Q4 C model == Q1 A model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + ngram + ngram:iscontent + rnn  + 
              (1+iscontent+sentence|subject)), # Q4 B model
    formula(amp ~ iscontent + sentence + position + frq + wm_frq + wp_frq + 
              sndpwr + ngram + ngram:iscontent  + 
              (1+iscontent+sentence|subject)) # Q4 C model
              )
)

load.R.object <- function(filename, objectname) {
  # loads a single object from a .Rdata file
  # and assigns it to the named output variable
  load(filename)
  return(eval(parse(text=objectname)))
  }

for (r in rois[1:6]) { # edit this to avoid rerunning finished ROIs
#for (r in rois) {
  roidata = subset(d, roi == r & performance == 1)
  for (q in 1:4) {
    message('Fitting roi ', r, ' and question ', q, '...')
    filename = paste(r, '_Q', q, sep='')
    
    # bmX depends on which Question is being asked...
    if (q %in% c(1,2)) {
      bmC <- brm(formulas[[q]][[1]], data=roidata)
      bmB <- update(bmC, formulas[[q]][[2]], newdata=roidata)
      bmA <- update(bmB, formulas[[q]][[3]], newdata=roidata)
    }
    if (q == 3) {
      bmC <- brm(formulas[[q]][[1]], data=roidata)
      bmB <- update(bmC, formulas[[q]][[2]], newdata=roidata)
      # Copy Q2 model A for Q3 model A 
      bmAfile <- paste('stan_models/', r, '_Q2.rData', sep='')
      bmA <- load.R.object(bmAfile, 'bmA')
    }
    if (q == 4) {
      # Copy Q1 model A as Q4 model C
      bmCfile <- paste('stan_models/', r, '_Q1.rData', sep='')
      bmC <- load.R.object(bmCfile, 'bmA')
      bmB <- update(bmC, formulas[[q]][[1]], newdata=roidata)
      bmA <- update(bmB, formulas[[q]][[2]], newdata=roidata)
    }
    

    bm_waic <- waic(bmA, bmB, bmC) 
    
    message('Saving results for roi ', r, ' and question ', q, '...')
    
    # dump model comparison data to file
    sink(file=paste('stan_models/', filename, '_waic.txt', sep='')) 
    paste('bmA: ', formula(bmA)$formula)
    paste('bmB: ', formula(bmB)$formula)
    paste('bmC: ', formula(bmC)$formula)
    print(bm_waic) 
    sink()
    
    p1 <- stanplot(bmC, par="^b", prob_outer = outer) # 
    p2 <- stanplot(bmB, par="^b", prob_outer = outer) # 
    p3 <- stanplot(bmA, par="^b", prob_outer = outer) # 
    
    p <- arrangeGrob(p1, p2, p3, ncol=3)  # for saving
    ggsave(file=paste('figs/', filename, '.png', sep=''), p, height=2, width=8)

    save(file=paste('stan_models/', filename, '.rData', sep=''), 'bmC', 'bmB', 'bmA', 'bm_waic')
    rm('bmC', 'bmB', 'bmA', 'bm_waic', 'filename')
  }
  rm('roidata')
}

## Write out targeted-comparisons per ROI/Question a-la Fig 4

sink(file=paste('stan_models/final_comparisons_waic.txt', sep='')) 
for (r in rois) { # 6 rois
  cat(r, ':\n')
  for (q in 1:4) { # 4 questions per roi
    cat('Q', q, ':\n')
    filename = paste(r, '_Q', q, sep='')
    load(file=paste('stan_models/', filename, '.rData', sep=''))
    wC = waic(bmC)
    wB = waic(bmB)
    wA = waic(bmA)
    print(loo_compare(wC, wA))
    print(loo_compare(wC, wB))
    print(loo_compare(wB, wA))
    rm('bmC', 'bmB', 'bmA', 'wC', 'wB', 'wA')
  }
}
sink()

## REPEAT, BUT NOW FOR N=41

for (r in rois[1:6]) { # edit this to avoid rerunning finished ROIs
  roidata = subset(d, roi == r & performance == 1)
  for (q in 1:4) {
    message('Fitting roi ', r, ' and question ', q, '...')
    filename = paste(r, '_Q', q, '_n41', sep='')
    
    # bmX depends on which Question is being asked...
    if (q %in% c(1,2)) {
      bmC <- brm(formulas[[q]][[1]], data=roidata)
      bmB <- update(bmC, formulas[[q]][[2]], newdata=roidata)
      bmA <- update(bmB, formulas[[q]][[3]], newdata=roidata)
    }
    if (q == 3) {
      bmC <- brm(formulas[[q]][[1]], data=roidata)
      bmB <- update(bmC, formulas[[q]][[2]], newdata=roidata)
      # Copy Q2 model A for Q3 model A 
      bmAfile <- paste('stan_models_n41/', r, '_Q2_n41.rData', sep='')
      bmA <- load.R.object(bmAfile, 'bmA')
    }
    if (q == 4) {
      # Copy Q1 model A as Q4 model C
      bmCfile <- paste('stan_models_n41/', r, '_Q1_n41.rData', sep='')
      bmC <- load.R.object(bmCfile, 'bmA')
      bmB <- update(bmC, formulas[[q]][[1]], newdata=roidata)
      bmA <- update(bmB, formulas[[q]][[2]], newdata=roidata)
    }
    
    
    bm_waic <- waic(bmA, bmB, bmC) # loo is preferred; but so much faster!
    
    message('Saving results for roi ', r, ' and question ', q, '...')
    
    # dump model comparison data to file
    sink(file=paste('stan_models_n41/', filename, '_waic.txt', sep='')) 
    paste('bmA: ', formula(bmA)$formula)
    paste('bmB: ', formula(bmB)$formula)
    paste('bmC: ', formula(bmC)$formula)
    print(bm_waic) 
    sink()
    
    p1 <- stanplot(bmC, par="^b", prob_outer = outer) # 
    p2 <- stanplot(bmB, par="^b", prob_outer = outer) # 
    p3 <- stanplot(bmA, par="^b", prob_outer = outer) # 
    
    p <- arrangeGrob(p1, p2, p3, ncol=3)  # for saving
    ggsave(file=paste('stan_models_n41/', filename, '.png', sep=''), p, height=2, width=8)
    
    save(file=paste('stan_models_n41/', filename, '.rData', sep=''), 'bmC', 'bmB', 'bmA', 'bm_waic')
    rm('bmC', 'bmB', 'bmA', 'bm_waic', 'filename')
  }
  rm('roidata')
}

## Targeted-comparisons per ROI/Question a-la Fig 4 for N=41

sink(file=paste('stan_models_n41/final_comparisons_waic.txt', sep='')) 
for (r in rois) { # 6 rois
  cat(r, ':\n')
  for (q in 1:4) { # 4 questions per roi
    cat('Q', q, ':\n')
    filename = paste(r, '_Q', q, sep='')
    load(file=paste('stan_models_n41/', filename, '.rData', sep=''))
    print(waic(bmC, bmA))
    print(waic(bmC, bmB))
    print(waic(bmB, bmA))
    rm('bmC', 'bmB', 'bmA', 'bm_waic')
  } 
}
sink()


###############
# Diagnostics #
###############

# R-Hat
# Residual plots
# AR(1)

library(rstantools) # for Bayes_R2()

files <- list.files(path = 'stan_models', pattern='*.rData')
# files = files[14:length(files)]
sink(file = 'diagnostic_information.txt', append=TRUE)
for (f in files) {
  the_file <- paste('stan_models/', f, sep='')
  cat('\n\n', the_file)
  load(the_file)
  fileparts <- strsplit(the_file, "\\.")[[1]]
  resA <- residuals(bmA, summary=TRUE, type='ordinary')[,1]
  resB <- residuals(bmB, summary=TRUE, type='ordinary')[,1]
  resC <- residuals(bmC, summary=TRUE, type='ordinary')[,1]
  cat('\nAR(1): A, B, C\n')
  cat(acf(resA, plot=FALSE)[[1]][2])
  cat(acf(resB, plot=FALSE)[[1]][2])
  cat(acf(resC, plot=FALSE)[[1]][2])
  
  cat('\nMax RHat: A, B, C\n')
  cat(summary(bmA)$fixed[,6])
  cat(max(summary(bmB)$fixed[,6]))
  cat(max(summary(bmC)$fixed[,6]))
  
  r2A <- bayes_R2(bmA)
  r2B <- bayes_R2(bmB)
  r2C <- bayes_R2(bmC)
  cat('\nBayes R2: A min med max, B min med max, C min med max\n')
  cat(min(r2A), median(r2A), max(r2A), ' ')
  cat(min(r2B), median(r2B), max(r2B), ' ')
  cat(min(r2B), median(r2B), max(r2B), ' ')
  
  out_name = paste(fileparts[[1]], '_qqnorm.png', sep='')
  png(file=out_name, width=1080)
  par(mfrow=c(1,3))
  qqnorm(resA); qqline(resA);
  qqnorm(resB); qqline(resA);
  qqnorm(resC); qqline(resA);
  dev.off()
  
}
sink()


