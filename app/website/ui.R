library(shiny);
library(plotly);
library(shinydashboard);
library(shinyWidgets);
library(ggiraph);
library(packcircles);
library(viridis);

source('welcome/welcome.R')

source('dashboards/arrests/ui_arrests.R')
source('dashboards/arraignments/ui_arraignments.R')
source('dashboards/dispositions/ui_dispositions.R')
source('dashboards/sentences/ui_sentences.R')
source('dashboards/cohort/ui_cohort_by_race.R')
source('special_reports/reduce_criminal_footprint.R')
source('special_reports/sentencing_alternatives.R')
source('resources/glossary/glossary.R')
source('resources/prosecution_process/pros_proc.R')
source('resources/data_methodology/data_methodology.R')
source('resources/how_to/how_to.R')
source('resources/contact.R')


ui <- tagList(
  tags$head(
  # workaround: navBar only takes tabPanels as arguments
  # this was adding a ghost tab to the navbarPage when placed below 
  # https://github.com/rstudio/shiny/issues/827#issuecomment-103119861
    includeHTML(("google-analytics.html"))
  ),
  navbarPage(
    title = actionLink(
      inputId = 'link_welcome',
      label = div(img(src = "images/data_dashboard_logo.png",
                      width = "390px", height = "60px"),
                  div(style = "padding: 0px 19%; text-align: left; font-family:proxima; font-size:16px; opacity:0.9; color:#b3e6ff; line-height:25px;",
                      paste("Updated:", LAST_UPDATED))
      )
    ),
    windowTitle = "Manhattan DA Data Website",
    id = "navbar_page",
    welcomePanel,
    navbarMenu(title = span(span("Dashboards"), DOWN_ARROW_ICON),
               arrestUI(id = ARREST_PAGE_MODULE),
               arraignmentUI(id = ARRAIGNMENT_PAGE_MODULE),
               dispositionUI(id = DISPOSITION_PAGE_MODULE), 
               sentenceUI(id = SENTENCE_PAGE_MODULE),
               cohortUI(id = COHORT_PAGE_MODULE)
    ),
    navbarMenu(title = span(span("Special Reports"), DOWN_ARROW_ICON),
               reduceCriminalFootprintPanel,
               sentencingAlternativesPanel
    ),
    navbarMenu(title = span(span("Resources"), DOWN_ARROW_ICON),
               prosProcPanel,
               glossaryPanel,
               dataMethodologyPanel,
               howToPanel,
               contactPanel
    ),
    footer = FOOTER_ROW,
    theme = "styles.css"
  )
)