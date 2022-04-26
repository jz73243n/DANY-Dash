library(shiny);


siteDir <- file.path(getwd(), "website")
setwd(siteDir)

source('global.R')
source('globalParts.R')
source('modules/pageIntroIcon.R')
source('modules/pageTabs.R')

source('ui.R')
source('server.R')

shinyApp(ui, server)
