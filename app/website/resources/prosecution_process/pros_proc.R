
source('resources/prosecution_process/text_pros_proc.R')

# back to top link 
LINK_TO_TOP <- a(
  href = "#",
  h3(class = "back-to-top red", "BACK TO TOP")
)

prosProcPanel <- tabPanel(
  title = PROSECUTION_PAGE_TITLE,
  value = PROSECUTION_PAGE_ID,
  # page intro
  fluidRow(class = "page-intro-row",
           # anchor at top of page 
           HTML('<a name="pros_proc_top"/>'),
           column(width = 6,
                  class = "page-intro-text",
                  h3(toupper(PROSECUTION_PAGE_TITLE)),
                  h4(class = "regular", 
                     "This page provides an overview of the criminal justice process from arrest to sentencing, and aims to answer common questions surrounding case processing in Manhattan."
                  )
           ),
           pageIntroIconUI(id = 'prosecution_intro', pageName = PROSECUTION_PAGE_TITLE)
  ),
  # tabs with links to different sections 
  fluidRow( 
    div(
      class = "pros-proc-banner-ctr",
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_stakeholders",
          h4("STAKEHOLDERS")
        )
      ),
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_arrest",
          h4("ARREST")
        )
      ),
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_arraignment",
          h4("ARRAIGNMENT")
        )
      ),
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_court_proceedings",
          h4("COURT PROCEEDINGS")
        )
      ),
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_trial",
          h4("TRIAL")
        )
      ),
      div(
        class = "pros-proc-banner-tab",
        a(href = "#pros_proc_disposition_sentence",
          h4("DISPOSITION AND SENTENCE")
        )
      )
    )
  ),
  # page body
  fluidRow(
    class = "main-row",
    br(),
    column(width = 5,
           img(src = 'images/prosecution_process.png', width = "100%", 
               height = "100%"),
    ),
    column(width = 7,
           # stakeholders ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_stakholders", 
                     class = "red", "STAKEHOLDERS IN THE PROSECUTION PROCESS"),
                  LINK_TO_TOP,
                  HTML(stakeholderText)
           ),
           
           # arrest ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_arrest", class = "red", "ARREST"),
                  LINK_TO_TOP,
                  HTML(arrestText)
           ),
           column(width = 3,
                  align = "center",
                  class = "pros-proc-button-col",
                  actionButton(inputId = "pros_proc_button_arr",
                               class = "pros-proc-dash-button",
                               label = HTML("ARRESTS<br/>DASHBOARD"))
           ),
           
           # arraignment ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_arraignment", class = "red", "ARRAIGNMENT"),
                  LINK_TO_TOP,
                  HTML(arraignmentText)
           ),
           column(width = 3,
                  align = "center",
                  class = "pros-proc-button-col",
                  actionButton(inputId = "pros_proc_button_arc",
                               class = "pros-proc-dash-button",
                               label = HTML("ARRAIGNMENTS<br/>DASHBOARD"))
           ),
           
           # court proceedings ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_court_proceedings", class = "red", 
                     "COURT PROCEEDINGS"),
                  LINK_TO_TOP,
                  HTML(courtProceedingText)
           ),
           
           # trial ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_trial", class = "red", "TRIAL"),
                  LINK_TO_TOP,
                  HTML(trialText)
           ),
           
           # disposition and sentence ####
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           column(width = 9,
                  h3(id = "pros_proc_disposition_sentence", class = "red", 
                     "DISPOSITION AND SENTENCE"),
                  LINK_TO_TOP,
                  HTML(dispositionSentenceText)
           ),
           column(width = 3,
                  align = "center",
                  class = "pros-proc-button-col",
                  actionButton(inputId = "pros_proc_button_disp",
                               class = "pros-proc-dash-button",
                               label = HTML("DISPOSITIONS<br/>DASHBOARD")),
                  br(),
                  br(),
                  br(),
                  actionButton(inputId = "pros_proc_button_sen",
                               class = "pros-proc-dash-button",
                               label = HTML("SENTENCES<br/>DASHBOARD"))
           )
    )
  )
)