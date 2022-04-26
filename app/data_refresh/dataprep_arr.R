
#query arrests dataset and save to object
arr <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashArr')

#merge base data with dataframe
arr <- merge(arr, base, by = 'defendantId', all.x = T)

# update data set
arr <- arr %>% 
  mutate(firstEvtYear = factor(firstEvtYear),
         arrestTopCat = factor(arrestTopCat, levels = c('Felony', 
                                                        'Misdemeanor', 
                                                        'Violation/Infraction', 
                                                        'Unknown')),
         scrTopCat = factor(scrTopCat, levels = c('Felony', 
                                                  'Misdemeanor', 
                                                  'Violation/Infraction', 
                                                  'Unknown'))
  )


#save arrest type options
arrestTypeOpt <- unique(arr$arrestType)

#save screen outcome options
screenOutcomeOpt <- unique(arr$screenOutcome)

#save to data file
saveRDS(arr, paste0(DATA_DIRECTORY, 'arrests.RDS'))
saveRDS(arrestTypeOpt, paste0(DATA_DIRECTORY, 'arrestTypeOpt.RDS'))
saveRDS(screenOutcomeOpt, paste0(DATA_DIRECTORY, 'screenOutcomeOpt.RDS'))

