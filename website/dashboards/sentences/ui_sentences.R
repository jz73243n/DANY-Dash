library(ggiraph);
library(packcircles);
library(plotly);
library(shiny);
library(shinyWidgets);

# setwd("~/dany_dashboard/app/website/")


sentenceUI <- function(id) {
  
  ns <- NS(id)
 
  # text import 
  source('dashboards/sentences/text_sentences.R')
  
  # text with links
  senIntro <- paste0(
    "A sentence  refers to the consequences or punishment ordered as a 
result of a conviction at trial or guilty plea. A case is sentenced when these 
consequences are formally imposed by a judge. There are a wide range of 
sentences for criminal convictions, which may involve monetary payment, 
probation, programming to address outstanding needs (such as addiction 
disorders, unstable housing, mental health needs, etc.), community service, 
or a term of imprisonment. 
<br/><br/>
While judges have latitude in sentencing decisions, mandatory sentencing 
provisions in New York State law limit judges' discretion over the type or 
length of sentence associated with a conviction of a specific charge or type 
of offense. For example, Criminal Procedural Law 70.02 establishes sentencing 
guidelines and requirements for individuals convicted of a violent felony 
offense. For more information on how and when a case is sentenced, please see the ",
    as.character(actionLink(inputId = ns('intro_link_pros_proc'), label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('intro_link_glossary'), label = 'Glossary')),
    ".")
  
  # Side bar #### 
  sideBar <- column(
    width = SIDEBAR_PANEL_WIDTH,
    class = "dash-sidepanel",
    h3("Filters"),
    
    # sentence-specific
    pickerInput(
      ns('sentenceYear'), 'Sentence Year', 
      choices = YEAR_OPT, selected = YEAR_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
      ns('category'), 'Top Conviction Offense Category', 
      choices = CAT_OPT, selected = CAT_OPT
    ),
    pickerInput(
      ns('majorGroup'), 'Top Conviction Offense Major Group',
      choices = MG_OPT, selected = MG_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('sentenceClean'), 'Sentence Type', 
      choices = sentenceTypeOptions, selected = sentenceTypeOptions,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    
    # demographics 
    checkboxGroupInput(
      ns('gender'), 'Gender of Sentenced Individual*', 
      choices = GENDER_OPT, selected = GENDER_OPT
    ),
    pickerInput(
      ns('race'), 'Race/Ethnicity of Sentenced Individual*', 
      choices = RACE_OPT, selected = RACE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('age'), 'Age at Time of Offense of Sentenced Individual',
      choices = AGE_OPT, select = AGE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      # . . . arrest location####
      ns('pct'), 'Neighborhood Where Arrest Occurred',
      choices = PCT_OPT, select = PCT_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),    
    # convictions
    pickerInput(
      # . . . prior fel cvct####
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
      # . tab 1: sentences ####
      tabPanel(h4("Cases Sentenced"),
               
               column(width = MAIN_SUBPANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      # . . . total cases sentenced ####
                      fluidRow(class = "graph-row",
                               h3('Cases Sentenced'),
                               downloadButton(ns("dlSen"), "DOWNLOAD DATA"),
                               plotlyOutput(ns('pSenAll')) %>% 
                                        SPINNER
                      ),
                      # . . . case characteristics####
                      fluidRow(
                        h3('Case Characteristics'),
                        downloadButton(ns("dlSenChar"), "DOWNLOAD DATA"),
                        TREEMAP_CAPTION(ns("treemap"))
                      ),
                      fluidRow(class = "graph-row",
                               column(6, 
                                      # . . . . gender####
                                      h4('Gender of Sentenced Individual'),
                                      plotlyOutput(ns('pSenGen')) %>% 
                                        SPINNER
                               ),
                               column(6, 
                                      # . . . . race####
                                      h4('Race/Ethnicity of Sentenced Individual'),
                                      plotlyOutput(ns('pSenRace')) %>% 
                                        SPINNER
                               )
                      ),
                      fluidRow(class = "graph-row",
                               column(6, 
                                      # . . . . sen top chg cat####
                                      h4('Sentence Category'),
                                      plotlyOutput(ns('pSenCat')) %>% 
                                        SPINNER
                               )
                      ),
                      
                      # . . . sentences by type####
                      fluidRow(
                               h3('Cases Sentenced by Sentence Type'),
                               h5(HTML(monetaryPayment)),
                               downloadButton(ns("dlSenType"), "DOWNLOAD DATA")),
                               # . . . . total sentences by type####'
                      fluidRow(class = "graph-row",
                               column(6,
                                      h4('Total Cases Sentenced'),
                                      plotlyOutput(ns('pSenType'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      h4('Percentage of Total Cases Sentenced'),
                                      plotlyOutput(ns('pSenType2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      ),
                      fluidRow(
                        h3('Cases Sentenced by Conviction Offense Category'),
                        downloadButton(ns("dlSenCatType"), "DOWNLOAD DATA")
                      ),
                      fluidRow(class = "graph-row",
                               # . . . . sentences by top chg cat####
                               # volume
                               column(6,
                                      h4('Total Felony Cases Sentenced'),
                                      plotlyOutput(ns('pSenTypeFel'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               # percent 
                               column(6,
                                      h4('Percentage of Felony Cases Sentenced'),
                                      plotlyOutput(ns('pSenTypeFel2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      ),
                      fluidRow(class = "graph-row",
                               # . . . . sentences by top chg cat####
                               # volume
                               column(6,
                                      h4('Total Misdemeanor Cases Sentenced'),
                                      plotlyOutput(ns('pSenTypeMisd'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               # percent 
                               column(6,
                                      h4('Percentage of Misdemeanor Cases Sentenced'),
                                      plotlyOutput(ns('pSenTypeMisd2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      )
               )
      ),
      # . tab 2: prison and jail sentences####
      tabPanel(h4("Prison & Jail Sentences"),
               
               column(width = MAIN_PANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      fluidRow(
                        h5(HTML(confineIntro))
                      ),
                      # . . . carceral sentence by type####
                      fluidRow(h3('Cases Sentenced to Incarceration (Prison or Jail)'),
                               downloadButton(ns("dlIncType"), "DOWNLOAD DATA")),
                      fluidRow(class = "graph-row",
                                      h4('Total Cases Sentenced to Incarceration by Sentence Type'),
                                      plotlyOutput(ns('pIncAll'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                      fluidRow(class = "graph-row",
                               column(6,
                                      h4('Total Felony Cases Sentenced to Incarceration by Sentence Type'),
                                      plotlyOutput(ns('pIncFel'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      h4('Total Misdemeanor Cases Sentenced to Incarceration by Sentence Type'),
                                      plotlyOutput(ns('pIncMisd'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      ), 
                      # . . . jail by cat and len####
                    fluidRow(h3('Cases Sentenced to Jail Time by Conviction Offense Category and Incarceration Time'),
                             downloadButton(ns("dlSenJail"), "DOWNLOAD DATA")),
                    fluidRow(class = "graph-row",
                               column(6,
                                      h4('Total Felony Cases Sentenced to Jail Time by Incarceration Time'),
                                      plotlyOutput(ns('pJailTimeFel'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      h4('Percentage of Felony Cases Sentenced to Jail Time by Incarceration Time'),
                                      plotlyOutput(ns('pJailTimeFel2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      ),
                    fluidRow(class = "graph-row",
                             column(6,
                                    h4('Total Misdemeanor Cases Sentenced to Jail Time by Incarceration Time'),
                                    plotlyOutput(ns('pJailTimeMisd'), height = HEIGHT) %>% 
                                        SPINNER
                             ),
                             column(6,
                                    h4('Percentage of Misdemeanor Cases Sentenced to Jail Time by Incarceration Time'),
                                    plotlyOutput(ns('pJailTimeMisd2'), height = HEIGHT) %>% 
                                        SPINNER
                             )
                    ),
                      # . . . prison by cat and len####
                     fluidRow(
                               h3('Cases Sentenced to Prison Time by Conviction Offense Category and Incarceration Time'),
                               downloadButton(ns("dlSenPris"), "DOWNLOAD DATA")),
                     fluidRow(class = "graph-row",
                               column(6,
                                      h4('Total Felony Cases Sentenced to Prison Time by Incarceration Time'),
                                      plotlyOutput(ns('pPrisTime'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      h4('Percentage of Felony Cases Sentenced to Prison Time by Incarceration Time'),
                                      plotlyOutput(ns('pPrisTime2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      )
               )
      ),
      # . tab 3: monetary sentences ####
      tabPanel(h4("Monetary Sentences"),

               column(width = MAIN_PANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      fluidRow(
                        h5(HTML(monetaryIntro))
                      ),
                      
                      fluidRow(h3("Monetary Sentences by Type")),
                      fluidRow(class = "graph-row",
                               column(6,
                                      # . . . total monetary sens####
                                      h4('Total Cases Sentenced to a Monetary Payment'),
                                      downloadButton(ns("dlSenFine"), "DOWNLOAD DATA"),
                                      plotlyOutput(ns('pSenFine')) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      # . . . monetary sens by type####
                                      h4('Percentage of Total Cases Sentenced to a Monetary Payment by Sentence Type'),
                                      downloadButton(ns("dlSenFineType"), "DOWNLOAD DATA"),
                                      plotlyOutput(ns('pSenFineType')) %>% 
                                        SPINNER
                               )
                      ),
                      
                      # . . . monetary sens by amount ####
                      fluidRow(h3("Monetary Sentences by Payment Amount"),
                               downloadButton(ns("dlSenFineAmt"), "DOWNLOAD DATA")),
                      fluidRow(class = "graph-row",
                               column(6,
                                      h4('Total Cases Sentenced to a Monetary Payment by Payment Amount'),
                                      plotlyOutput(ns('pSenFineAmt'), height = HEIGHT) %>% 
                                        SPINNER
                               ),
                               column(6,
                                      h4('Percentage of Total Cases Sentenced to a Monetary Payment by Payment Amount'),
                                      plotlyOutput(ns('pSenFineAmt2'), height = HEIGHT) %>% 
                                        SPINNER
                               )
                      )
               )
      )
    )
  )
  
  # Final page ####
  tabPanel(
    title = SENTENCE_PAGE_TITLE,
    value = SENTENCE_PAGE_ID,
    pageTabsUI(id = ns('tab'), currDashName = SENTENCE_PAGE_TITLE),
    fluidRow(class = "page-intro-row",
             column(width = 6,
                    class = "page-intro-text",
                    h3(toupper(SENTENCE_PAGE_TITLE)),
                    h4(class = "regular", HTML(senIntro))
             ),
             pageIntroIconUI(id = ns('intro'), pageName = SENTENCE_PAGE_TITLE)
    ),
    fluidRow(
      class = "main-row",
      sideBar,
      mainBar 
    )
  )
  
}
