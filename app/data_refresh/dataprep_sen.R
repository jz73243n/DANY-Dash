
#query sentences dataset and save to object
sentences <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashSenMain')
fines <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashSenFine')

#merge base data with dataframe
sentences <- merge(sentences, base, by = 'defendantId', all.x = T)
fines <- merge(fines, base, by = 'defendantId', all.x = T)

# update data set
sentences <- sentences %>% 
              mutate(sentenceYear = factor(sentenceYear),
                     senTopCat = ifelse(!senTopCat %in% c('Felony', 'Misdemeanor', 'Violation/Infraction'),
                                        'Unknown',
                                        as.character(senTopCat)),
                     senTypeCond = case_when(sentenceClean %in% c('Conditional Discharge', 
                                                                  'Community Service') ~ 'Conditional Discharge',
                                             sentenceClean %in% c('Prison', 
                                                                  'Jail',
                                                                  'Jail/Prison') ~ 'Incarceration', 
                                       sentenceClean %in% c('Fine', 
                                                            'Restitution',
                                                            'Asset Forfeiture') ~ 'Monetary Payment',
                                       TRUE ~ as.character(sentenceClean)),
                     confineJailTime = factor(confineJailTime, levels = c('Less than One Month', '1-3 Months', '3-6 Months',
                                                                          '6-9 Months', '9-12 Months', 'Unknown')),
                     confinePrisTime = factor(confinePrisTime, levels = c('1-3 Years', '3-5 Years', '5-7 Years', '7-10 Years',
                                                                          '10-15 Years', '15-20 Years', '20-25 Years',
                                                                          'Over 25 Years', 'Life in Prison', 'Unknown'))
                     )

# update data set
fines <- fines %>% 
          mutate(sentenceYear = factor(sentenceYear),
                 senFineCat = ifelse(!senFineCat %in% c('Felony', 'Misdemeanor', 'Violation/Infraction'),
                                    'Unknown',
                                    as.character(senFineCat)),
                 fineCatAmt = factor(fineCatAmt, levels = c('Under $50', '$50-$100', '$100-$500',
                                                            '$500-$1,000', '$1,000-$5,000', '$5,000-$10,000',
                                                            'Over $10,000', 'Unknown'))
                ) %>% 
         filter(sentenceClean!='Asset Forfeiture')

# sentence type options
sentenceTypeOptions <- unique(sentences$sentenceClean)

#save to data file
saveRDS(sentences, paste0(DATA_DIRECTORY, 'sentences.RDS'))
saveRDS(fines, paste0(DATA_DIRECTORY, 'fines.RDS'))
saveRDS(sentenceTypeOptions, paste0(DATA_DIRECTORY, 'sentenceTypeOptions.RDS'))


