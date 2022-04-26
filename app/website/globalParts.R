
# icons ####
SHARE_ICON <- img(src = "images/normal_u78.svg", width = 25, height = 25)
PRINT_ICON <- img(src = "images/normal_u77.svg", width = 25, height = 25)
GLOSSARY_ICON <- img(src = "images/glossary_icon.svg", width = 30, height = 30)
PROSECUTION_ICON <- img(src = "images/prosecution_icon.svg", width = 30, height = 30)
DASHBOARD_ICON <- img(src = "images/normal_u90.png", width = 30, height = 30)
DASHBOARD_LARGE_ICON <- img(src = "images/dashboard_large_icon.png")
METHODOLOGY_ICON <- img(src = "images/normal_u4309.png", width = 25, height = 25)
DA_LOGO_ICON <- img(id = "da-logo-img", src = "images/logo_u4.png",
                    height = 60, width = 60)
DOWN_ARROW_ICON <- img(src = "images/arrow.svg")

LAST_UPDATED <- 
  format.Date(file.info(paste0(DATA_PATH, 'base.RDS'))$mtime, '%B %d, %Y')


# Page title ####
# home
WELCOME_PAGE_TITLE <- "Welcome"
WELCOME_PAGE_ID <- "welcome"

# . dashboards
ARREST_PAGE_TITLE <- "Arrests"
ARREST_PAGE_MODULE <- "arrest"
ARREST_PAGE_ID <- "arrests"

ARRAIGNMENT_PAGE_TITLE <- "Arraignments"
ARRAIGNMENT_PAGE_MODULE <- "arraignment"
ARRAIGNMENT_PAGE_ID <- "arraignments"

DISPOSITION_PAGE_TITLE <- "Dispositions"
DISPOSITION_PAGE_MODULE <- "disposition"
DISPOSITION_PAGE_ID <- "dispositions"

SENTENCE_PAGE_TITLE <- "Sentences"
SENTENCE_PAGE_MODULE <- "sentence"
SENTENCE_PAGE_ID <- "sentences"

COHORT_PAGE_TITLE <- "Cohort Outcomes by Race/Ethnicity"
COHORT_PAGE_TITLE_SHORT <- "Race/Ethnicity"
COHORT_PAGE_MODULE <- "cohort"
COHORT_PAGE_ID <- "cohorts"

# . resources 
GLOSSARY_PAGE_TITLE <- "Glossary" 
GLOSSARY_PAGE_TITLE_SHORT <- "Glossary"
GLOSSARY_PAGE_MODULE <- "glossary"
GLOSSARY_PAGE_ID <- "glossary"

PROSECUTION_PAGE_TITLE <- "Prosecution Process Overview"
PROSECUTION_PAGE_TITLE_SHORT <- "Prosecution Process"
PROSECUTION_PAGE_MODULE <- "prosecution"
PROSECUTION_PAGE_ID <- "prosecution_process"

METHODOLOGY_PAGE_TITLE <- "Data and Methodology"
METHODOLOGY_PAGE_MODULE <- "methodology"
METHODOLOGY_PAGE_ID <- "data_methodology"

HOW_TO_PAGE_TITLE <- "How to Use Our Site"
HOW_TO_PAGE_MODULE <- "how_to"
HOW_TO_PAGE_ID <- "how_to"

CONTACT_PAGE_TITLE <- "Contact Us"
CONTACT_PAGE_MODULE <- "contact"
CONTACT_PAGE_ID <- "contact"

DASHBOARD_PAGE_TITLES <- c(ARREST_PAGE_TITLE,
                           ARRAIGNMENT_PAGE_TITLE,
                           DISPOSITION_PAGE_TITLE,
                           SENTENCE_PAGE_TITLE,
                           COHORT_PAGE_TITLE_SHORT)

# function: reset button on filters
RESET_BUTTON <- function(id) {
  div(class = 'reset-button',
      actionButton(inputId = id, 'RESET FILTERS',
                   style = "border-radius: 5px; border: 1px solid #ff5850; background-color: #ff5850; font-family: proxima; color: #ffffff; font-size: 18px",
      )
  )
}

# FOOTER_ROW ####
FOOTER_ROW <- fluidRow(
                   theme = "styles.css",
                   class = "blue-background-footer",
                   column(width = 4, 
                          div(style = "display: flex;",
                              div(style = "margin-right: 10px", DA_LOGO_ICON),
                              div(style = "display:block;",
                                  div(style = "font-size: 18px; color: white; font-weight: bold; font-family: caecilia;", 
                                      "Manhattan District Attorney's Office"),
                                  h6(class = "white", "Main Office"),
                                  h6(class = "white", "One Hogan Place"),
                                  h6(class = "white", "New York, NY 10013"),
                                  h6(class = "red", "212.335.9000")
                                  
                              )
                          )
                   ),
                   column(width = 4,
                          column(width = 6,
                                 div(
                                   actionLink(
                                     inputId = "foot_link_arr",
                                     class = "red",
                                     "DASHBOARDS"
                                   )
                                 ),
                                 br(),
                                 div(
                                   actionLink(
                                     inputId = "foot_link_pros_proc",
                                     class = "red", 
                                     toupper(PROSECUTION_PAGE_TITLE)
                                   )
                                 ),
                                 br(),
                                 div(
                                   actionLink(
                                     inputId = "foot_link_glossary",
                                     class = "red", 
                                     toupper(GLOSSARY_PAGE_TITLE)
                                   )
                                 )
                                 
                          ),
                          column(width = 6,
                                 div(
                                   actionLink(
                                     inputId = "foot_link_data_methodology",
                                     class = "red", 
                                     toupper(METHODOLOGY_PAGE_TITLE)
                                   )
                                 ),
                                 br(),
                                 div(
                                   actionLink(
                                     inputId = "foot_link_how_to",
                                     class = "red", 
                                     toupper(HOW_TO_PAGE_TITLE)
                                   )
                                 )
                                 
                          )
                   ),
                   column(width = 3, offset = 1,
                          actionButton(inputId = "button_contact", 
                                       style = "border-radius: 5px; border: 1px solid #ff5850; background-color: #ffffff; font-family: proxima; font-size: 18px;",
                                       label = toupper(CONTACT_PAGE_TITLE)),
                          
                          div(style = "display: flex;",
                              h6(style = "padding-right: 10px", class = "white", 
                                 paste0("All content ", format(Sys.Date(), "%Y"))),
                              a(href = "https://www.manhattanda.org/disclaimer/",
                                h6(class = "red", "Disclaimer"))
                          )
                   )
                   
)



