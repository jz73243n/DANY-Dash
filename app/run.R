renv::restore()
library(shiny)

port <- Sys.getenv('PORT', unset = 8001)

shiny::runApp(
              appDir = getwd(),
              host = '0.0.0.0',
              port = as.numeric(port)
)
