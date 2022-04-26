
#query cohort dataset and save to object
cohort <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashCohort')

#merge base data with dataframe
cohort <- merge(cohort, base %>% 
                         select(-c(caseStatus,
                                   screenDate)), by = 'defendantId', all.x = T)

cohort <- cohort %>% 
           mutate(cohort = factor(cohort),
                  raceCat = fct_rev(factor(raceCat, levels = c('White', 'Black', 
                                                 'Hispanic', 'Asian/Pacific Islander',
                                                 'American Indian/Alaskan Native', 'Other/Unknown'))),
      screenOutcome = factor(screenOutcome, levels = c('Prosecute', 
                                                       'Decline to Prosecute')),
      bailRequested = as.factor(ifelse(bailRequested==1, 
                                       'Bail Requested', 
                                       'No Bail Requested')),
      bailSet = as.factor(ifelse(bailSet == 1, 
                                 'Bail Set', 
                                 'No Bail Set')),
      ccArraignRelease = as.factor(ifelse(is.na(ccArraignRelease), ccArraignOutcome, ccArraignRelease)),
      isIndicted = as.factor(ifelse(isIndicted==1, 
                                    'Indicted', 
                                    'Not Indicted')),
      indType = as.factor(indType), 
      dispoType = as.factor(ifelse(disposition %in% c('ACD/M', 
                                                      'Conviction', 
                                                      'Acquittal',
                                                      'Dismissal'), disposition,
                                   dispoDetail)),
      instantCaseType = factor(instantCaseType, levels = c('Indicted Felony Case', 
                                                           'Unindicted Felony Case', 
                                                           'Misdemeanor Case', 
                                                           'Violation/Infraction Case', 
                                                           'Unknown Case')),
      dispoTopCat = ifelse(!dispoTopCat %in% c('Felony', 'Misdemeanor', 'Violation/Infraction'),
                           'Unknown',
                           as.character(dispoTopCat)),
      dispoCaseType = factor(dispoCaseType),
      sentenceType = as.factor(ifelse(sentence %in% c('Fine', 
                                                      'Restitution', 
                                                      'Asset Forfeiture'), 
                                      'Monetary Payment', 
                                      sentence)),
      instTopCat = ifelse(!instTopCat %in% c('Felony', 'Misdemeanor', 'Violation/Infraction'),
                          'Unknown',
                          as.character(instTopCat))
      ) %>% 
   filter(ifelse(screenOutcome=='Prosecute' & instTopCat=='Unknown', 0, 1)==1)


saveRDS(cohort, paste0(DATA_DIRECTORY, 'cohort.RDS'))
