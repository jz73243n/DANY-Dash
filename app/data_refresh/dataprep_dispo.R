
# query dispos dataset and save to object
dispos <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashDispo')

# merge base data with dataframe
dispos <- merge(dispos, base, by = 'defendantId', all.x = T)

# update data set
dispos <- dispos %>% 
  mutate(dispoYear = factor(dispoYear),
         dispoType = factor(dispoType, levels = c('Conviction', 
                                                  'ACD', 
                                                  'Dismissal', 
                                                  'Acquittal', 'Other')),
  )


# dispo type options
dispoTypeOptions <- unique(dispos$dispoType)

# save to data file
saveRDS(dispos, paste0(DATA_DIRECTORY, 'dispos.RDS'))
saveRDS(dispoTypeOptions, paste0(DATA_DIRECTORY, 'dispoTypeOptions.RDS'))

