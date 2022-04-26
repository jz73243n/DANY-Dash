
#query arrests dataset and save to object
base <- sqlQuery(planintdb, 'SELECT * FROM planintdb.dbo.danyDashBase')

#save to data file
saveRDS(base, paste0(DATA_DIRECTORY, 'base.RDS'))