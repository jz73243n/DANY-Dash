
# query arrests dataset and save to object
arc <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashArc')

# merge base data with dataframe
arc <- merge(arc, base, by = 'defendantId', all.x = T)

# update data set
arc <- arc %>% 
  mutate(arcYear = factor(arcYear),
         scrTopCat = factor(scrTopCat, levels = c('Felony', 
                                                  'Misdemeanor', 
                                                  'Violation/Infraction', 
                                                  'Unknown')),
         arcTopCat = factor(arcTopCat, levels = c('Felony', 
                                                  'Misdemeanor', 
                                                  'Violation/Infraction', 
                                                  'Unknown'))
  )


# arc release status options
relStatOpt <- unique(arc$releaseStatusCond)

# save to data file
saveRDS(arc, paste0(DATA_DIRECTORY, 'arraignments.RDS'))
saveRDS(relStatOpt, paste0(DATA_DIRECTORY, 'relStatOpt.RDS'))

