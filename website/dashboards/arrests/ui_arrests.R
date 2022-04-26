library(shinydashboard);
library(shinyWidgets);
library(plotly);
library(shinycssloaders);

arrestUI <- function(id) {
  
  ns <- NS(id)
 
  # text import 
  source('dashboards/arrests/text_arrests.R')
  
  # text with links
  arrIntro <- paste0(
    "The Arrests Dashboard provides information on the number of arrests the Manhattan D.A.'s Office screened, charged, and declined to prosecute each year. \"Year\" indicates when the Manhattan D.A.'s Office first processed or \"screened\" each arrest. For more information about the arrest to screening process, please see the ",
    as.character(actionLink(inputId = ns('intro_link_pros_proc'), 
                            label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('intro_link_glossary'), 
                            label = 'Glossary')),
    ".")
  
  # Side bar ####
  sideBar <- column(
    width = SIDEBAR_PANEL_WIDTH,
    class = "dash-sidepanel",
   
    # tags$style(".checkbox {font-family:'proxima'; color: #2b316f;}"),
    # tags$style("input[type = 'checkbox'] {font-family:'proxima'; color: #2b316f;}"),
    h3("Filters"),
    # arrest-specific
    pickerInput(
      ns('firstEvtYear'), 'Screen Year',
      choices = YEAR_OPT, selected = YEAR_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
      ns('category'), 'Arrest Offense Category',
      choices = CAT_OPT, selected = CAT_OPT
    ),
    pickerInput(
      ns('majorGroup'), 'Arrest Offense Major Group',
      choices = MG_OPT, selected = MG_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
      ns('arrestType'), 'Arrest Type',
      choices = arrestTypeOptions, selected = arrestTypeOptions
    ),
    checkboxGroupInput(
      ns('screenOutcome'), 'Screen Outcome',
      choices = screenOutcomeOptions, selected = screenOutcomeOptions
    ),
    # demographics
    checkboxGroupInput(
      ns('gender'), 'Gender of Arrested Individual*',
      choices = GENDER_OPT, selected = GENDER_OPT
    ),
    pickerInput(
      ns('race'), 'Race/Ethnicity of Arrested Individual*',
      choices = RACE_OPT, selected = RACE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('age'), 'Age at Time of Alleged Offense of Arrested Individual',
      choices = AGE_OPT, selected = AGE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('pct'), 'Neighborhood Where Arrest Occurred',
      choices = PCT_OPT, select = PCT_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    # convictions
    pickerInput(
      ns('priorFelConv'), 'Prior Manhattan Felony Convictions',
      choices = PRIOR_FEL_OPT, selected = PRIOR_FEL_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('priorMisdConv'), 'Prior Manhattan Misdemeanor Convictions',
      choices = PRIOR_MISD_OPT, selected = PRIOR_MISD_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('yrSinceConv'), 'Years Since Most Recent Manhattan Conviction',
      choices = YR_SINCE_CONV_OPT, selected = YR_SINCE_CONV_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    RESET_BUTTON(id = ns('button_reset')),
    DEMO_DISCLAIMER_1
  )
  
  # Main bar #### 
  mainBar <- column(
    width = MAIN_PANEL_WIDTH,
    class = "dash-mainpanel",
    tabsetPanel(
     
      # . tab: arrests screened #### 
      tabPanel(h4("Arrests Screened"),
               column(width = MAIN_SUBPANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      
                      br(),
                      fluidRow(
                        h5(HTML(arrScreenIntro))
                      ),
                      
                      fluidRow(
                        class = "graph-row",
                        h3("Arrests Screened"),
                        column(width = 9,
                               plotlyOutput(ns('plot0')) %>% 
                                 SPINNER
                        ),
                        column(width = 3,
                               align = "center",
                               h4('Graph Summary'),
                               div(class = "value-box-dynamic",
                                 valueBoxOutput(ns('boxArr'), width = NULL)
                               ),
                               br(),
                               div(class = "value-box-dynamic",
                                 valueBoxOutput(ns('boxArrInd'), width = NULL)
                               )
                        )
                      ),
                      
                      
                      fluidRow( 
                        h3("Arrests Screened by Arrest Type"),
                        downloadButton(ns("dlArrType"), "DOWNLOAD DATA")
                      ),
                      fluidRow(
                        class = "graph-row",
                       column(6,
                         h4("Total Arrests Screened"),
                        plotlyOutput(ns('pArrTypeTotal')) %>% 
                                 SPINNER
                       ),
                       column(6,
                              h4("Felony Arrests Screened"),
                              plotlyOutput(ns('pArrTypeFel')) %>% 
                                SPINNER
                        )
                      ),
                      fluidRow(
                        class = "graph-row",
                      column(6,
                        h4("Misdemeanor Arrests Screened"),
                        plotlyOutput(ns('pArrTypeMisd')) %>% 
                                SPINNER
                      ),
                      column(6,
                        h4("Violation/Infraction Arrests Screened"),
                        plotlyOutput(ns('pArrTypeViol')) %>% 
                                SPINNER
                        )
                      ),
                      
                   
                      fluidRow(
                        h3('Arrests Screened Characteristics'),
                        downloadButton(ns("dlArrChar"), "DOWNLOAD DATA"),
                        TREEMAP_CAPTION(ns("treemap")),
                      ),
                      fluidRow(
                        class = "graph-row",
                        column(6,
                               h4("Arrest Offense Category"),
                               plotlyOutput(ns('pArrCat')) %>% 
                                SPINNER
                        ),
                        column(6,
                               h4("Gender of Arrested Individual"),
                               plotlyOutput(ns('pArrGen')) %>% 
                                SPINNER
                        )
                      ),
                      
                      fluidRow(
                        class = "graph-row",
                        column(6,
                               h4("Race/Ethnicity of Arrested Individual"),
                               plotlyOutput(ns('pArrRace')) %>% 
                                SPINNER
                        ),
                        column(6, 
                               h4("Age at Time of Alleged Offense of Arrested Individual"),
                               plotlyOutput(ns('pArrAge')) %>% 
                                SPINNER
                        )
                      ), 
                      fluidRow(
                        class = "graph-row",
                        column(6,
                               h4("Number of Prior Manhattan Felony Convictions for Arrested Individual"),
                                plotlyOutput(ns('pArrFelConv')) %>% 
                                SPINNER
                        ),
                        column(6, 
                               h4("Number of Prior Manhattan Misdemeanor Convictions for Arrested Individual"),
                               plotlyOutput(ns('pArrMisdConv')) %>% 
                                SPINNER
                        )
                      ),
                      fluidRow(
                        class = "graph-row",
                        column(6, 
                               h4("Years Since Most Recent Manhattan Conviction for Arrested Individual"),
                               plotlyOutput(ns('pYrSinceConv')) %>% 
                                SPINNER
                        )
                      ),
                      
                      fluidRow(
                        h3("Five Most Common Arrest Offenses in ECAB"),
                        h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_ecab_common")))),
                        downloadButton(ns("dlArrChg"), "DOWNLOAD DATA")
                      ),
                      fluidRow(
                        class = "graph-row",
                        
                        h4("Felony Arrests"),
                        tabsetPanel(
                          tabPanel("2013", 
                                   plotlyOutput(ns('arrChgFel13')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2014", 
                                   plotlyOutput(ns('arrChgFel14')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2015", plotlyOutput(ns('arrChgFel15')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2016", 
                                   plotlyOutput(ns('arrChgFel16')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2017", 
                                   plotlyOutput(ns('arrChgFel17')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2018", 
                                   plotlyOutput(ns('arrChgFel18')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2019", 
                                   plotlyOutput(ns('arrChgFel19')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2020", 
                                   plotlyOutput(ns('arrChgFel20')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2021", 
                                   plotlyOutput(ns('arrChgFel21')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2022", 
                                   plotlyOutput(ns('arrChgFel22')) %>% 
                                     SPINNER
                          ),
                          tabPanel("All", 
                                   plotlyOutput(ns('arrChgFel'), height=HEIGHT_750) %>% 
                                     SPINNER
                          )
                        )
                      ),
                      fluidRow(
                        class = "graph-row",
                        h4("Misdemeanor Arrests"),
                        tabsetPanel(
                          tabPanel("2013", 
                                   plotlyOutput(ns('arrChgMisd13')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2014", 
                                   plotlyOutput(ns('arrChgMisd14')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2015", 
                                   plotlyOutput(ns('arrChgMisd15')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2016", 
                                   plotlyOutput(ns('arrChgMisd16')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2017", 
                                   plotlyOutput(ns('arrChgMisd17')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2018", 
                                   plotlyOutput(ns('arrChgMisd18')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2019", 
                                   plotlyOutput(ns('arrChgMisd19')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2020", 
                                   plotlyOutput(ns('arrChgMisd20')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2021", 
                                   plotlyOutput(ns('arrChgMisd21')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2022", 
                                   plotlyOutput(ns('arrChgMisd22')) %>% 
                                     SPINNER
                          ),
                          tabPanel("All",
                                   plotlyOutput(ns('arrChgMisd'), height = HEIGHT_750) %>% 
                                     SPINNER
                          )
                        )
                      ),
                      fluidRow(
                        class = "graph-row",
                        h4("Violation/Infraction Arrests"),
                        tabsetPanel(
                          tabPanel("2013", 
                                   plotlyOutput(ns('arrChgVio13')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2014", 
                                   plotlyOutput(ns('arrChgVio14')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2015", 
                                   plotlyOutput(ns('arrChgVio15')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2016", 
                                   plotlyOutput(ns('arrChgVio16')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2017", 
                                   plotlyOutput(ns('arrChgVio17')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2018", 
                                   plotlyOutput(ns('arrChgVio18')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2019", 
                                   plotlyOutput(ns('arrChgVio19')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2020", 
                                   plotlyOutput(ns('arrChgVio20')) %>% 
                                     SPINNER
                          ),
                          tabPanel("2021",
                                     plotlyOutput(ns('arrChgVio21')) %>% 
                                     SPINNER
                                  
                          ),
                          tabPanel("2022",
                                   plotlyOutput(ns('arrChgVio22')) %>% 
                                     SPINNER
                                   
                          ),
                          tabPanel("All", 
                                   plotlyOutput(ns('arrChgVio'), height=HEIGHT_750) %>% 
                                     SPINNER
                          )
                          
                        )
                      )
               )
      ),
      # . tab: arrests declined to prosecute #### 
      tabPanel(h4("Arrests Declined to Prosecute"),
               
               column(width = MAIN_SUBPANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      fluidRow(h5(HTML(arrDpIntro))),
                     
                      fluidRow(class = "graph-row", 
                               h3("Arrests Screened by Screen Outcome"),
                              downloadButton(ns("dlArrScreenOut"), "DOWNLOAD DATA"),
                               plotlyOutput(ns('pArrScreenOut')) %>% 
                                SPINNER
                      ),
                      
                      fluidRow(class = "graph-row", 
                               h3("Arrests Screened and Declined to Prosecute (DPed) by Arrest Offense Category"),
                               downloadButton(ns("dlDpCat"), "DOWNLOAD DATA"),
                               plotlyOutput(ns('pDpCat')) %>% 
                                SPINNER
                      ),
                      
                      fluidRow(class = "graph-row",
                               h3("Arrests Screened and Declined to Prosecute (DPed) by Reason"),
                               downloadButton(ns("dlDpReason"), "DOWNLOAD DATA"),
                               girafeOutput(ns('pDpReason'), height = HEIGHT_750) %>% 
                                SPINNER
                      ),
                     
                      fluidRow( 
                        h2("Office Declination Policies"),
                        h5(HTML(arrDpPolicyIntro))
                      ),
                      
                      fluidRow(
                        h3("Possession of Marijuana"),
                        
                        h4("Marijuana Arrests Screened by Screen Outcome"),
                        downloadButton(ns("dlDpMj"), "DOWNLOAD DATA"),
                        h5(HTML(arrMpCap))
                      ),
                      
                      fluidRow(class = "graph-row",
                        column(width = 9,
                               plotlyOutput(ns('pDpMj')) %>% 
                                SPINNER
                        ),
                        column(width = 3,
                               align = "center",
                               h4('Graph Summary'),
                               div(class = "value-box-dynamic",
                                   valueBoxOutput(ns('boxProsMj'), width = NULL)
                               ),
                               br(),
                               div(class = "value-box-dynamic",
                                   valueBoxOutput(ns('boxDpMj'), width = NULL)
                               )
                        )
                      ),
                      
                      fluidRow(class = "graph-row",
                        h5(HTML(arrMpUnderCap)),
                        column(width = 4, offset = 4,
                               align = "center",
                               div(class = "value-box-dynamic",
                                   valueBoxOutput(ns('boxUnderlyingMj'), width = NULL)
                               )
                        )
                      ),
                      
                      
                      fluidRow(
                        h3("Subway Fare Evasion Theft of Services"),
                        h4("Theft of Services Arrests Screened by Screen Outcome"), 
                        downloadButton(ns("dlDpTos"), "DOWNLOAD DATA"),
                        h5(HTML(arrTosCap))
                      ),
                      
                      fluidRow(class = "graph-row",
                        column(width = 9,
                               plotlyOutput(ns('pDpTos')) %>% 
                                SPINNER
                        ),
                        column(width = 3,
                               align = "center",
                               h4('Graph Summary'),
                               div(class = "value-box-dynamic",
                                   valueBoxOutput(ns('boxProsTos'), width = NULL),
                               ),
                               br(),
                               div(class = "value-box-dynamic",
                                   valueBoxOutput(ns('boxDpTos'), width = NULL)
                               )
                        )
                      ),
                      fluidRow(class = "graph-row",
                               h5(HTML(arrTosUnderCap)),
                               column(width = 4, offset = 4,
                                      align = "center",
                                      div(class = "value-box-dynamic",
                                          valueBoxOutput(ns('boxUnderlyingTos'), width = NULL)
                                      )
                               )
                      )
               )
      ),
      # . tab: arrests prosecuted ####
      tabPanel(h4("Arrests Prosecuted"),
               
               column(width = MAIN_SUBPANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      fluidRow(
                        h5(HTML(arrProsIntro))
                      ),
       
                      fluidRow(class = "graph-row", 
                               h3("Arrests Prosecuted by Major Group"),
                               downloadButton("dlProsMg", "DOWNLOAD DATA"),
                               h5(HTML(arrProsMgCap)),
                               h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_pros")))),
                               girafeOutput(ns('pProsMg'), height=HEIGHT_750) %>% 
                                SPINNER
                      ),
        
                      fluidRow(h3("Charge Changes in ECAB"),
                               downloadButton(ns("dlChgChange"), "DOWNLOAD DATA"),
                               h5(HTML(arrProsChgCap))
                      ),
                      fluidRow(class = "graph-row",
                       column(6,
                        h4("Felony Arrests"),
                        plotlyOutput(ns('pChgChangeFel'),height=HEIGHT_VERT_STACK) %>% 
                                SPINNER
                       ),
                       column(6,
                         h4("Misdemeanor Arrests"),
                         plotlyOutput(ns('pChgChangeMisd'),height=HEIGHT_VERT_STACK) %>% 
                                SPINNER
                          )
                       ),
                      fluidRow(class = "graph-row",
                              column(6,
                                h4("Violation/Infraction Arrests"),
                               plotlyOutput(ns('pChgChangeVio'), height=HEIGHT_VERT_STACK) %>% 
                                SPINNER
                              )
                      )
               )
      )
    )
  )
  
  
  # Final page ####
  tabPanel(
    title = ARREST_PAGE_TITLE,
    value = ARREST_PAGE_ID,
    pageTabsUI(id = ns('tab'), currDashName = ARREST_PAGE_TITLE),
    fluidRow(class = "page-intro-row",
             column(width = 6,
                    class = "page-intro-text",
                    h3(toupper(ARREST_PAGE_TITLE)),
                    h4(class = "regular", HTML(arrIntro))
             ),
             pageIntroIconUI(id = ns('intro'), pageName = ARREST_PAGE_TITLE)
    ),
    fluidRow(
      class = "main-row",
      sideBar,
      mainBar
    )
  )
}