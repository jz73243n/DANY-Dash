
pageIntroIconUI <- function(id, pageName) {
  ns <- NS(id)
  
  PROSECUTION_DIV <- div(
    actionLink(
      inputId = ns("link_pros_proc_icon"),
      span(class = "icon-row",
           h6(PROSECUTION_PAGE_TITLE_SHORT), PROSECUTION_ICON
      )
    )
  )
  
  GLOSSARY_DIV <- div(
    actionLink(
      inputId = ns("link_glossary_icon"),
      span(class = "icon-row",
           h6(GLOSSARY_PAGE_TITLE_SHORT), GLOSSARY_ICON
      )
    )
  )
  
  METHODOLOGY_DIV <- div(
    actionLink(
      inputId = ns("link_data_methodology_icon"),
      span(class = "icon-row",
           h6(METHODOLOGY_PAGE_TITLE), METHODOLOGY_ICON
      )
    )
  )
  
  DASHBOARD_DIV <-  div(
    actionLink(
      inputId = ns("link_arrest_icon"),
      span(class = "icon-row",
           h6("Dashboards"), DASHBOARD_ICON
      )
    )
  )
  
  # blank variable for icons 
  icons <- column(width = 6) 
  
  # dashboard icon set 
  if (pageName %in% DASHBOARD_PAGE_TITLES) {
    icons <- column(width = 6,
                    div(class = "icon-ctr", 
                        PROSECUTION_DIV,
                        GLOSSARY_DIV
                    )
    )
    
  } else {
    #  resource page icon set 
    icons <- column(width = 6,
                    br(),
                    div(class = "icon-ctr",
                        DASHBOARD_DIV,
                        if (pageName == GLOSSARY_PAGE_TITLE) {
                          #data and methodology page only has three icons
                          PROSECUTION_DIV
                        } else if (pageName == PROSECUTION_PAGE_TITLE) {
                          GLOSSARY_DIV
                        } else if (pageName == HOW_TO_PAGE_TITLE) {
                          METHODOLOGY_DIV
                        }
                        
                    )
    )
  }
  
  return(icons)
}


pageIntroIconServer <- function(id, parent_session) {
  
  moduleServer(id,
               function(input, output, session) {
                 
                 # icon column (right side of page)
                 observeEvent(input$link_pros_proc_icon, {
                   updateTabsetPanel(session = parent_session, 
                                     inputId = "navbar_page", 
                                     selected = PROSECUTION_PAGE_ID)
                 })
                 
                 observeEvent(input$link_glossary_icon, {
                   updateTabsetPanel(session = parent_session, 
                                     inputId = "navbar_page", 
                                     selected = GLOSSARY_PAGE_ID)
                 })
                 
                 observeEvent(input$link_data_methodology_icon, {
                   updateTabsetPanel(session = parent_session, 
                                     inputId = "navbar_page", 
                                     selected = METHODOLOGY_PAGE_ID)
                 })
                 observeEvent(input$link_arrest_icon, {
                   updateTabsetPanel(session = parent_session, 
                                     inputId = "navbar_page", 
                                     selected = ARREST_PAGE_ID)
                 })
               }
  )
}

