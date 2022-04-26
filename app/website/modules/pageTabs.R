getClassBg <- function(currDashName, dashName) {
  classBack <- "dashboard-banner-tab"
  if (dashName == currDashName) {
    return(paste(classBack, "red-background"))
  }
  
  return(classBack)
}

getClassHeader <- function(currDashName, dashName) {
  classBack <- ""
  if (dashName == currDashName) {
    return("white")
  }
  
  return(classBack)
}

pageTabsUI <- function(id, currDashName) {
  ns <- NS(id)
  
  
  fluidRow( 
    div(
      class = "dashboard-banner-ctr",
      div(
        class = getClassBg(currDashName, ARREST_PAGE_TITLE),
        actionLink(
          inputId = ns(ARREST_PAGE_TITLE),
          h4(class = getClassHeader(currDashName, ARREST_PAGE_TITLE), 
             toupper(ARREST_PAGE_TITLE))
        )
      ),
      div(
        class = getClassBg(currDashName, ARRAIGNMENT_PAGE_TITLE),
        actionLink(
          inputId = ns(ARRAIGNMENT_PAGE_TITLE),
          h4(class = getClassHeader(currDashName, ARRAIGNMENT_PAGE_TITLE),
             toupper(ARRAIGNMENT_PAGE_TITLE))
        )
      ),
      div(
        class = getClassBg(currDashName, DISPOSITION_PAGE_TITLE),
        actionLink(
          inputId = ns(DISPOSITION_PAGE_TITLE),
          h4(class = getClassHeader(currDashName, DISPOSITION_PAGE_TITLE),
             toupper(DISPOSITION_PAGE_TITLE))
        )
      ),
      div(
        class = getClassBg(currDashName, SENTENCE_PAGE_TITLE),
        actionLink(
          inputId = ns(SENTENCE_PAGE_TITLE),
          h4(class = getClassHeader(currDashName, SENTENCE_PAGE_TITLE),
             toupper(SENTENCE_PAGE_TITLE))
        )
      ),
      div(
        class = getClassBg(currDashName, COHORT_PAGE_TITLE_SHORT),
        actionLink(
          inputId = ns('RaceEthnicity'),
          h4(class = getClassHeader(currDashName, COHORT_PAGE_TITLE_SHORT),
             toupper(COHORT_PAGE_TITLE_SHORT))
        )
      )
    )
  )
}


pageTabsServer <- function(id, parent_session) {
  
  moduleServer(id,
               function(input, output, session) {
                 
                 observeEvent(input$Arrests,
                              {
                                updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = ARREST_PAGE_ID)
                              })
                 
                 observeEvent(input$Arraignments,
                              {
                                updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = ARRAIGNMENT_PAGE_ID)
                              })
                 
                 observeEvent(input$Dispositions,
                              {
                                updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = DISPOSITION_PAGE_ID)
                              })
                 
                 observeEvent(input$Sentences,
                              {
                                updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = SENTENCE_PAGE_ID)
                              })
                 observeEvent(input$RaceEthnicity,
                              {
                                updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = COHORT_PAGE_ID)
                              })

               }
  )
}
               
