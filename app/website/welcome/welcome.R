library(shinydashboard);
library(scales);
library(dplyr);

welcomePanel <- tabPanel(
  title = WELCOME_PAGE_TITLE,
  value = WELCOME_PAGE_ID,
  # workaround: place manhattan da button at top right of navbar
  # even though this page is not the navbar, the html will insert it into the navbar
  # included on this page because otherwise would create a ghost tab
  # https://github.com/rstudio/shiny/issues/827#issuecomment-103119861
  # https://stackoverflow.com/questions/58288216/add-action-button-on-the-right-side-of-navbar-page
  tags$script(
    includeHTML('welcome/manhattan_da_external_button.html')
  ),
  fluidRow(
    div(class = "banner-desktop-warning",
         "For best viewing and functionality, please view on a computer.")
  ),
  fluidRow(
    column(width = 6,
           class = "banner-ctr",
           actionButton(
             inputId = "wel_button_pros_proc",
             class = "banner",
             label = span(class = "blue", PROSECUTION_ICON, toupper(PROSECUTION_PAGE_TITLE))
           )
    ),
    column(width = 6,
           class = "banner-ctr",
           actionButton(
             inputId = "wel_button_glossary",
             class = "banner",
             label = span(class = "blue", GLOSSARY_ICON, toupper(GLOSSARY_PAGE_TITLE))
           )
    )
  ),
  fluidRow(class = "grey-background",
           # first row
           fluidRow(
             # welcome box
             br(),
             column(width = 6, offset = 1,
                    h3("Welcome to the Manhattan D.A.'s"),
                    img(src = "images/logo.png"),
                    br(),
                    br(),
                    HTML(paste0("<p>This user-centered website aims to provide the public with comprehensive data to increase transparency about the Manhattan D.A.'s operations and enhance understanding of the justice system. Here, you will find up-to-date information about the Office's prosecutions and learn more about the Manhattan D.A.'s efforts to ensure public safety and promote justice for all.<br/><br/>
You can also visit the Resources tab for an ",
                         as.character(actionLink(inputId = 'wel_link_pros_proc', label = 'educational overview of the criminal justice system')) ,
                         ", a ",
                         as.character(actionLink(inputId = 'wel_link_glossary', label = 'glossary of key terms')),
                         ", and information about ",
                         as.character(actionLink(inputId = 'wel_link_how_to', label = 'how to use this website')),
                         ". The Office welcomes your feedback as it continues to enhance this site.</p>"))
             ),
             # latest special report image
             column(width = 4,
                    style = "margin-top: 20px;",
                    align = "center",
                    div(
                      style = "max-width: 240px; max-height: 320px",
                      a(
                        img(src = "images/special_report_sentencing_alternatives.png", width = "100%", height = "100%"),
                        target = "_blank", 
                        href = "special_reports/Sentencing_Alternatives_In_Manhattan.pdf"
                      )
                    )
             )
           ),
           # key dashboards
           fluidRow(
             align = "center",
             # overwrite default h3 margin-top so that on smaller desktops you can see the icons
             h3(style = "margin-top: 0px",
                "KEY DASHBOARDS"),
             # overwrite default p margin-bottom so that on smaller desktops you can see the icons
             p(style = "margin-bottom: 0px",
               "Follow how a case progresses from arrest to sentencing through Manhattan's criminal justice system.")
           ),
           fluidRow(
             class = "dashboard-button-ctr",
             
             div(
               actionButton(
                 inputId = 'wel_button_arr',
                 class = "dashboard-button",
                 div(
                   h4(class = "regular", toupper(ARREST_PAGE_TITLE)),
                   DASHBOARD_LARGE_ICON
                 )
               )
             ),
             div(
               actionButton(
                 inputId = 'wel_button_arc',
                 class = "dashboard-button",
                 div(
                   h4(class = "regular", toupper(ARRAIGNMENT_PAGE_TITLE)),
                   DASHBOARD_LARGE_ICON
                 )
               )
             ),
             div(
               actionButton(
                 inputId = 'wel_button_disp',
                 class = "dashboard-button",
                 div(
                   h4(class = "regular", toupper(DISPOSITION_PAGE_TITLE)),
                   DASHBOARD_LARGE_ICON
                 )
               )
             ),
             div(
               actionButton(
                 inputId = 'wel_button_sen',
                 class = "dashboard-button",
                 div(
                   h4(class = "regular", toupper(SENTENCE_PAGE_TITLE)),
                   DASHBOARD_LARGE_ICON
                 )
               )
             ),
             div(
               actionButton(
                 inputId = 'wel_button_coh',
                 class = "dashboard-button",
                 div(
                   h4(class = "regular", toupper("Race/Ethnicity")),
                   DASHBOARD_LARGE_ICON
                 )
               )
             )
           ),
           fluidRow(br(), br())
  )
)