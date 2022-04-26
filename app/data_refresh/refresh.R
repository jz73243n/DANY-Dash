# refresh.R is a stand-alone file which refreshes the RDS files feeding into 
# the DANY dashboard, which are saved in dany_dashboard/app/website/data. 
#
# Run this code from beginning to end, and it will automatically set the working
# directory to dany_dashboard/app/data, connect to PLANINTDB, and then 
# run each dataprep file.
#
# The first dataprep file sourced, dataprep_base.R, pulls the "base" data, which 
# includes various demographic data that is used in every dashboard, mostly for 
# filters. 
#
# Each consequent dataprep file (e.g. dataprep_arr.R) pulls the data corresponding
# a dashboard, and the base data gets left joined into the dashboard-specific data
# by defendantId. These RDS files are saved in the dany_dashboard/app/website/data 
# folder. 
# 
# Because the dataprep_{DASHBOARD NAME ABBREV}.R are being source'd into this file, 
# they have access to the base variable and planintdb data connection. 

# remove objects in environment
rm(list=ls())

library(dplyr);
library(RODBC);
library(forcats)


# set working directory to this file location
# https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# data directory relative to this location
DATA_DIRECTORY <- "../website/data/"

options(scipen = 999,stringsAsFactors = F)

# set database channel to pull data 
# danyDash tables are in the daily refresh and saved in PLANINTDB under 
# danyDash{DASHBOARD NAME}
planintdb <- odbcConnect("PLANINTDB","BIAppUser","BIAppsLinux")


# run what is in the dataprep files
source('dataprep_base.R')

source('dataprep_arr.R')

source('dataprep_arc.R')

source('dataprep_dispo.R')

source('dataprep_sen.R')

source('dataprep_cohort.R')

#close database channel
odbcClose(planintdb)

# test to see if filter'd data has NULLs
 source('test.R')
