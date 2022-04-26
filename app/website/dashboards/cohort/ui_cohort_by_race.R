library(treemap)
library(ggiraph);
library(plotly);
library(shiny);
library(gt);
library(packcircles);
library(shinyWidgets);


cohortUI <- function(id) {
  
  ns <- NS(id)

  # text imports  
  source('dashboards/cohort/text_cohort.R')
  
  # text with links
  dpIntro <- paste0(
    "For more information on the Office's declination policies, 
please see the ",
    as.character(actionLink(inputId = ns('link_arr'), label = 'Arrests Dashboard')) ,
    ", the ",
    as.character(actionLink(inputId = ns('arr_link_pros_proc'), label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('arr_link_glossary'), label = 'Glossary')),
    ".")
  
  bailIntro <- paste0("For more information on arraignments and release status, please 
see the ",
    as.character(actionLink(inputId = ns('link_arc'), label = 'Arraignments Dashboard')) ,
    ", the ",
    as.character(actionLink(inputId = ns('arc_link_pros_proc'), label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('arc_link_glossary'), label = 'Glossary')),
    ".")
  
  indictIntro <- paste0(
    "Under New York State law, almost all felony cases must be 
presented to the Grand Jury , which is empowered to hear evidence presented by 
Assistant D.A.s and can vote an indictment  (a written statement charging an 
individual with a felony offense). The Grand Jury must determine that the 
evidence is legally sufficient and that it provides reasonable cause to believe 
that the charged individual has committed the crime. If an individual has been 
indicted on a felony, the case is transferred to and arraigned in Supreme Court. 
Criminal Court  no longer has jurisdiction over a charged individual once an 
indictment has been filed. For more information on the Grand Jury and 
indictments, please see the ",
    as.character(actionLink(inputId = ns('ind_link_pros_proc'), 
                            label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('ind_link_glossary'), label = 'Glossary')),
    ".")
  
  dispoIntro <- paste0(
    "For more information on how a case is disposed, please see the ",
    as.character(actionLink(inputId = ns('link_disp'), 
                            label = 'Dispositions Dashboard')) ,
    ", the ",
    as.character(actionLink(inputId = ns('disp_link_pros_proc'), 
                            label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('disp_link_glossary'), label = 'Glossary')),
    ".")
  
  senIntro <- paste0(
    "For more information on how a case is sentenced, please see the ",
    as.character(actionLink(inputId = ns('link_sen'), label = 'Sentences Dashboard')) ,
    ", the ",
    as.character(actionLink(inputId = ns('sen_link_pros_proc'), 
                            label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('sen_link_glossary'), 
                            label = 'Glossary')),
    ".")
  
  # Side bar #### 
  sideBar <- column(
    width = SIDEBAR_PANEL_WIDTH,
    class = "dash-sidepanel",
    h3("Filters"),
  # cohort-specific
    pickerInput(
      ns('cohortYear'), 'Cohort Year',
      choices = COH_YEAR_OPT, selected = COH_YEAR_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
      ns('category'), 'Alleged Offense Category',
      choices = CAT_OPT, selected = CAT_OPT
    ),
    pickerInput(
      ns('majorGroup'), 'Alleged Offense Major Group', 
      choices = MG_OPT, selected = MG_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    # demographics
    checkboxGroupInput(
      ns('gender'), 'Gender of Individual*',
      choices = GENDER_OPT, selected = GENDER_OPT
    ),
    pickerInput(
      ns('race'), 'Race/Ethnicity of Individual*',
      choices = RACE_OPT, selected = RACE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('age'), 'Age at Time of Alleged Offense of Individual',
      choices = AGE_OPT, select = AGE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('pct'), 'Neighborhood Where Arrest Occurred',
      choices = PCT_OPT, select = PCT_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    # convictions
    pickerInput(
      # . . . prior fel cvcts####
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
    # . warning re: no self id####
    DEMO_DISCLAIMER_1
  )
  
  # Main bar ####
  mainBar <- column(
    width = MAIN_PANEL_WIDTH,
    class = "dash-mainpanel",
    
    column(
      width = MAIN_SUBPANEL_WIDTH,
      offset = MAIN_SUBPANEL_OFFSET,
     
      br(), 
      fluidRow(h5(HTML(cohortsIntro2))),
      
      # . legend####
      fluidRow(h4("Legend"),
               plotOutput(ns('legend'), height = "60px") %>% 
                                        SPINNER
      ),
      
      # . screening####
      fluidRow(h2("Screening")),
      fluidRow(class = "graph-row",
               # . . . dps####
               h3("Declinations"),
               downloadButton(ns("dlCohDecl"), "DOWNLOAD DATA"),
               h5(HTML(dpIntro)),
               
               h4(HTML(dpSummary)),
               column(6,
                      h4(HTML(dpCap1)),
                      plotlyOutput(ns('plot_r1')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(dpCap2)),
                      plotlyOutput(ns('plot_r1.1')) %>% 
                                        SPINNER
               )
      ),
      
      # . arraignment####
      fluidRow(h2("Arraignment"),
               # . . . bail####
               h3("Bail Requested"),
               downloadButton(ns("dlCohBailReq"), "DOWNLOAD DATA"),
               h5(HTML(bailIntro)),
               
               h4(HTML(bailSummary))
               ),
      fluidRow(class = "graph-row",
               h3('Felony Cases'),
               column(6,
                      h4(HTML(bailReqCapF1)),
                      plotlyOutput(ns('pBailReqFel')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(bailReqCapF2)),
                      plotlyOutput(ns('pBailReqFel2')) %>% 
                                        SPINNER
               )
      ),
      fluidRow(class = "graph-row",
               h3('Misdemeanor Cases'),
               column(6,
                      h4(HTML(bailReqCapM1)),
                      plotlyOutput(ns('pBailReqMisd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(bailReqCapM2)),
                      plotlyOutput(ns('pBailReqMisd2')) %>% 
                                        SPINNER
               )
      ),
      # . . . arc release####
      fluidRow(h3("Detained at Arraignment"),
               h4(HTML(detainSummary)),
               downloadButton(ns("dlCohDetention"), "DOWNLOAD DATA")
      ),
      fluidRow(class = "graph-row",
               h3('Felony Cases'),
               column(6,
                      h4(HTML(detainArcCapF1)),
                      plotlyOutput(ns('pArcReleaseFel')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(detainArcCapF2)),
                      plotlyOutput(ns('pArcReleaseFel2')) %>% 
                                        SPINNER
               )
      ),
      fluidRow(class = "graph-row",
               h3('Misdemeanor Cases'),
               column(6,
                      h4(HTML(detainArcCapM1)),
                      plotlyOutput(ns('pArcReleaseMisd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(detainArcCapM2)),
                      plotlyOutput(ns('pArcReleaseMisd2')) %>% 
                                        SPINNER
               )
      ),
      
      # . indictments####
      fluidRow(
        h2("Indictment"),
        h5(HTML(indictIntro)),
        
        h4(HTML(indictSummary)),
        downloadButton(ns("dlCohIndict"), "DOWNLOAD DATA")
      ),
      fluidRow(class = "graph-row",
               column(6,
                      h4(HTML(indictCap1)),
                      
                      plotlyOutput(ns('pIndict'))
               ),
               
               column(6,
                      h4(HTML(indictCap2)),
                      plotlyOutput(ns('pIndict2'))
               )
      ),
      
      # . dispositions####
      fluidRow(
        h2("Disposition"),
        h5(HTML(dispoIntro)),
        
        h4(HTML(convSummary)),
        
      ),
      # . . . convictions####
      fluidRow(class = "graph-row",
               h3("Convictions"),
               downloadButton(ns("dlCohCvt"), "DOWNLOAD DATA"),
               h3("Unindicted Felony Cases"),
               # . . . . felony####
               column(6,
                      h4(HTML(convF1Cap1)),
                      plotlyOutput(ns('pConvictNotInd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(convF1Cap2)),
                      plotlyOutput(ns('pConvictNotInd2')) %>% 
                                        SPINNER
               )
      ),
      fluidRow(class = "graph-row",
               h3("Indicted Felony Cases"),
               # . . . . felony####
               column(6,
                      h4(HTML(convF2Cap1)),
                      plotlyOutput(ns('pConvictInd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(convF2Cap2)),
                      plotlyOutput(ns('pConvictInd2')) %>% 
                                        SPINNER
               )
      ),
      fluidRow(class = "graph-row",
               # . . . . misdemeanor####
               h3("Misdemeanor Cases"),
               column(6,
                      h4(HTML(convMCap1)),
                      plotlyOutput(ns('pConvictMisd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(convMCap2)),
                      plotlyOutput(ns('pConvictMisd2')) %>% 
                                        SPINNER
               )
               
      ),
      
      # . sentencing####
      fluidRow(
        h2("Sentencing"),
        h5(HTML(senIntro)),
        
        h4(HTML(imprisonSummary))
      ),
      # . . . imprisonment####
      fluidRow(class = "graph-row",
               h3('Imprisonment'),
               downloadButton(ns("dlCohIncarc"), "DOWNLOAD DATA"),
               h3("Felony Convicted Cases"),
               column(6,
                      h4(HTML(imprisonCapFel1)),
                      plotlyOutput(ns('pIncFel')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(imprisonCapFel2)),
                      plotlyOutput(ns('pIncFel2')) %>% 
                                        SPINNER
               )
      ),
      fluidRow(class = "graph-row",
               h3("Misdemeanor Convicted Cases"),
               column(6,
                      h4(HTML(imprisonCapMisd1)),
                      plotlyOutput(ns('pIncMisd')) %>% 
                                        SPINNER
               ),
               column(6,
                      h4(HTML(imprisonCapMisd2)),
                      plotlyOutput(ns('pIncMisd2')) %>% 
                                        SPINNER
               )
      )
    )
  )
  
  # Final page ####
  tabPanel(
    title = COHORT_PAGE_TITLE_SHORT,
    value = COHORT_PAGE_ID,
    pageTabsUI(id = ns('tab'), currDashName = COHORT_PAGE_TITLE_SHORT),
    fluidRow(class = "page-intro-row",
             column(width = 6,
                    class = "page-intro-text",
                    h3(toupper(COHORT_PAGE_TITLE)),
                    h4(class = "regular", HTML(cohortsIntro))
             ),
             pageIntroIconUI(id = ns('intro'), pageName = COHORT_PAGE_TITLE_SHORT)
    ),
    fluidRow(
      class = "main-row",
      sideBar,
      mainBar 
    )
  )
  
}