# erp.easy v0.6.4
# January 29th, 2016

## New Functions
1. erp.filter
Uses the "signal" package to allow low and high pass 
	filterting of erp.easy data objects


## Updates and Fixes to Previously Existing Functions
All plotting functions:
1. There is now a solid background for all plot legends

# dif.wave:
1. Can now specify Stimulus name for difference wave
2. More descriptive default for Stimulus name for 
	difference wave, if none is specified
3. Can now specify which data frame to keep with the 
	difference wave (if any)

# grandaverage:
1. Raw amplitude data for the grand average is returned

# load.data:
1. Change in acceptable file name format means files no longer 
	need to be numbered.  Now all text preceding an "_" will be
	ignored, and all text following an "_" will be read as
	the specified condition.  This allows removing or adding
	subject files without having to renumber existing files.  

# m.measures: 
1. Mean erp measures are automatically returned with a plot 
	of the grand average and time window

# p.measures:
1. Peak erp measures are automatically returned with: a plot 
	of the grand average, the time window, a vertical line 
	indicating the peak latency
2. Fixed a bug that produced inaccurate local peak measures for 
	individual data (grand average peak data were accurate)