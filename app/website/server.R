# server.R

source('dashboards/arraignments/server_arraignments.R')
source('dashboards/arrests/server_arrests.R')
source('dashboards/dispositions/server_dispositions.R')
source('dashboards/sentences/server_sentences.R')
source('dashboards/cohort/server_cohort_by_race.R')

server <- function(input, output, session) {
 
  pageIntroIconServer(id = 'methodology_intro', parent_session = session)
  pageIntroIconServer(id = 'contact_intro', parent_session = session)
  pageIntroIconServer(id = 'how_to_intro', parent_session = session)
  pageIntroIconServer(id = 'prosecution_intro', parent_session = session)
  pageIntroIconServer(id = 'glossary_intro', parent_session = session)
  
  arrestServer(id = ARREST_PAGE_MODULE, parent_session = session)
  arraignmentServer(id = ARRAIGNMENT_PAGE_MODULE, parent_session = session)
  dispositionServer(id = DISPOSITION_PAGE_MODULE, parent_session = session)
  sentenceServer(id = SENTENCE_PAGE_MODULE, parent_session = session)
  cohortServer(id = COHORT_PAGE_MODULE, parent_session = session)
  
  # welcome page buttons/links
  observeEvent(input$wel_button_pros_proc, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  observeEvent(input$wel_link_pros_proc, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  observeEvent(input$wel_link_glossary,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  observeEvent(input$wel_button_glossary,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  observeEvent(input$wel_link_how_to,{
    updateTabsetPanel(session = session, inputId = "navbar_page",
                      selected = HOW_TO_PAGE_ID)
  })
  observeEvent(input$wel_button_arr,{
    updateTabsetPanel(session = session, inputId = "navbar_page",
                      selected = ARREST_PAGE_ID)
  })
  observeEvent(input$wel_button_arc,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = ARRAIGNMENT_PAGE_ID)
  })
  observeEvent(input$wel_button_disp,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = DISPOSITION_PAGE_ID)
  })
  observeEvent(input$wel_button_sen,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = SENTENCE_PAGE_ID)
  })
  observeEvent(input$wel_button_coh,{
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = COHORT_PAGE_ID)
  })
  

  # footer links/buttons 
  observeEvent(input$wel_button_contact, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = CONTACT_PAGE_ID)
  })
  observeEvent(input$foot_link_pros_proc, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  observeEvent(input$foot_link_glossary, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  observeEvent(input$foot_link_data_methodology, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = METHODOLOGY_PAGE_ID)
  })
  observeEvent(input$foot_link_how_to, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = HOW_TO_PAGE_ID)
  })
  observeEvent(input$foot_link_arr, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = ARREST_PAGE_ID)
  })
  
  
  # header logo button 
  observeEvent(input$link_welcome, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = WELCOME_PAGE_ID)
  })
  
  # prosecution process page buttons
  observeEvent(input$pros_proc_button_arr, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = ARREST_PAGE_ID)
  })
  observeEvent(input$pros_proc_button_arc, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = ARRAIGNMENT_PAGE_ID)
  })
  observeEvent(input$pros_proc_button_disp, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = DISPOSITION_PAGE_ID)
  })
  observeEvent(input$pros_proc_button_sen, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = SENTENCE_PAGE_ID)
  })
  
  # how to page links 
  observeEvent(input$how_to_link_pros_proc, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  observeEvent(input$how_to_link_glossary, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  observeEvent(input$how_to_link_data_methodology, {
    updateTabsetPanel(session = session, inputId = "navbar_page", 
                      selected = METHODOLOGY_PAGE_ID)
  })

  
}
