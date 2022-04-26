library(treemap); library(ggiraph); library(plotly); library(shiny);
library(gt); library(packcircles)

# setwd('~/dany_dashboard/app/website/')



dispositionUI <- function(id) {
  
  ns <- NS(id)

  # text import  
  source('dashboards/dispositions/text_dispositions.R')
  
  # text with links
  dispoIntro <- paste0(
    "The Dispositions Dashboard provides information about cases 
disposed of by the Manhattan D.A.'s Office each year. \"Year\" indicates when the 
case was disposed. Cases are disposed of, or resolved, when the charged 
individual pleads guilty, consents to an Adjournment in Contemplation of 
Dismissal (\"ACD\"), is convicted  or acquitted at trial, or has their 
case dismissed. For more information on the disposition process, please see the ",
    as.character(actionLink(inputId = ns('intro_link_pros_proc'), label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('intro_link_glossary'), label = 'Glossary')),
    ".")
  
  # Side bar ####
  sideBar <- column(
    width = SIDEBAR_PANEL_WIDTH,
    class = "dash-sidepanel",
    h3("Filters"),
    
    # disposition-specific
    pickerInput(
      ns('dispoYear'), 'Disposition Year', 
      choices = YEAR_OPT, selected = YEAR_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
     ns('arcDispo'), 'Disposed at Arraignment',
     choices = ARC_DISPO_OPT, selected = ARC_DISPO_SELECT
    ),
    checkboxGroupInput(
      ns('category'), 'Alleged Offense Category*', 
      choices = CAT_OPT2, selected = CAT_OPT2
    ),
    pickerInput( 
      ns('majorGroup'), 'Alleged Offense Major Group',
      choices = MG_OPT, selected = MG_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    checkboxGroupInput(
      ns('dispoType'), 'Disposition Type', 
      choices = dispoTypeOptions, selected = dispoTypeOptions
    ),
    # demographics
    checkboxGroupInput(
      ns('gender'), 'Gender of Charged Individual**', 
      choices = GENDER_OPT, selected = GENDER_OPT
    ),
    pickerInput( 
      ns('race'), 'Race/Ethnicity of Charged Individual**', 
      choices = RACE_OPT, selected = RACE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      ns('age'), 'Age at Time of Alleged Offense of Charged Individual',
      choices = AGE_OPT, select = AGE_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    pickerInput(
      # . . . arrest location ####
      ns('pct'), 'Neighborhood Where Arrest Occurred',
      choices = PCT_OPT, select = PCT_OPT,
      options = list(`actions-box` = TRUE), multiple = TRUE
    ),
    
    # convictions 
    pickerInput(
      # . . . prior fel cvcts ####
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
    VFO_DISCLAIMER,
    DEMO_DISCLAIMER_2
  )
  
  # Main bar ####
  mainBar <- column(
    width = MAIN_PANEL_WIDTH,
    class = "dash-mainpanel",
    tabsetPanel(
      # . tab 1: dispos overall ####
      tabPanel(h4("Cases Disposed"),
               column(width = MAIN_SUBPANEL_WIDTH,
                      offset = MAIN_SUBPANEL_OFFSET,
                      br(),
                      
                      # . . . total dispos ####
                      fluidRow( 
                        h5(HTML(caseDispoIntro))
                      ),
                      
                      fluidRow(class = "graph-row", 
                               h3("Cases Disposed"),
                               downloadButton(ns("dlDispoAll"), "DOWNLOAD DATA"),
                               plotlyOutput(ns('pDispoAll')) %>% 
                            SPINNER
                      ),
                      
                      fluidRow(
                        h3("Cases Disposed by Disposition Type"),
                        downloadButton(ns("dlDispoType"), "DOWNLOAD DATA")
                      ),
                      
                      # . . . dispos by type ####
                      fluidRow(class = "graph-row",
                               column(6, 
                                      h4("Total Cases Disposed by Disposition Type"),
                                      plotlyOutput(ns('pDispoType'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6, 
                                      h4("Percentage of Cases Disposed by 
                              Disposition Type"),
                                      plotlyOutput(ns('pDispoType2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      ),
                      
                      # . . . dispos by cat ####
                      fluidRow(
                        h3("Cases Disposed by Alleged Offense Category"),
                        downloadButton(ns("dlCatDispoType"), "DOWNLOAD DATA")
                      ),
                      fluidRow(class = "graph-row",
                               column(6, 
                                      h4("Total Felony Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeFel'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6, 
                                      h4("Percentage of Felony Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeFel2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      ),
                      fluidRow(class = "graph-row",
                               column(6, 
                                      h4("Total Misdemeanor Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeMisd'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6, 
                                      h4("Percentage of Misdemeanor Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeMisd2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      ),
                      
                      fluidRow(class = "graph-row",
                               column(6, 
                                      h4("Total Violation/Infraction Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeViol'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6,
                                      h4("Percentage of Violation/Infraction Cases Disposed"),
                                      plotlyOutput(ns('pDispoTypeViol2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      ),
                      
                      # . . . convictions ####
                      fluidRow(
                        h2("Pleas and Trial Convictions")
                      ),
                      
                      # . . . plea/cvct by offense ####
                     fluidRow( 
                      h3("Pleas and Trial Convictions by Alleged Offense Category"),
                      downloadButton(ns("dlCatConvType"), "DOWNLOAD DATA"),
                      h5(HTML(pleaTrialCap)),
                     ),
                      fluidRow(class = "graph-row",
                               column(6,
                                      h4("Total Felony Cases Convicted by Disposition Type"),
                                      plotlyOutput(ns('pConvictTypeFel'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6,
                                      h4("Percentage of Felony Cases Convicted by Disposition Type"),
                                      plotlyOutput(ns('pConvictTypeFel2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                            ),
                      fluidRow(class = "graph-row",
                             column(6,
                                    h4("Total Misdemeanor Cases Convicted by Disposition Type"),
                                    plotlyOutput(ns('pConvictTypeMisd'), 
                                                 height = HEIGHT) %>% 
                            SPINNER
                             ),
                             column(6,
                                    h4("Percentage of Misdemeanor Cases Convicted by Disposition Type"),
                                    plotlyOutput(ns('pConvictTypeMisd2'), 
                                                 height = HEIGHT) %>% 
                            SPINNER
                             )
                     ),
                      # . . . charge changes for plea/cvct ####
                      fluidRow(
                        h3("Offense-Level Changes for Cases Disposed by Plea or Trial Conviction"),
                        downloadButton(ns("dlCatConvChange"), "DOWNLOAD DATA")
                      ),
                      
                      # . . . . fel chg changes####
                      fluidRow(class = "graph-row",
                               h5(HTML(convChargeChangeCapF)),
                               column(6,
                                      h4("Total Felony Cases Convicted by Charge Change"),
                                      plotlyOutput(ns('pConvictChangeFel'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6,
                                      h4("Percentage of Felony Cases Convicted by Charge Change"),
                                      plotlyOutput(ns('pConvictChangeFel2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      ),
                      
                      # . . . . msd chg changes ####
                      fluidRow(class = "graph-row",
                               h5(HTML(convChargeChangeCapM)),
                               column(6,
                                      h4("Total Misdemeanor Cases Convicted by Charge Change"),
                                      plotlyOutput(ns('pConvictChangeMisd'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               ),
                               column(6,
                                      h4("Percentage of Misdemeanor Cases Convicted by Charge Change"),
                                      plotlyOutput(ns('pConvictChangeMisd2'), 
                                                   height = HEIGHT) %>% 
                            SPINNER
                               )
                      )
               )
      ),
      tabPanel(h4("Disposition Charges"),
               # . tab 2: dispo charges ####
               column(
                 width = MAIN_SUBPANEL_WIDTH,
                 offset = MAIN_SUBPANEL_OFFSET,
                 br(),
                 
                 # . . conviction charges ####
                 fluidRow(
                   h2("Conviction Charges")
                 ),
                 # . . . by major group ####
                 fluidRow(class = "graph-row",
                          h3("Conviction Offense by Major Group"), 
                          downloadButton(ns("dlConvMg"), "DOWNLOAD DATA"),
                          h5(HTML(offenseMajorGroupCaption)),
                          h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_conv")))),
                          girafeOutput(ns('pConvMg'), height=HEIGHT_750) %>% 
                            SPINNER
                 ),
                 
                 # . . . most common cvct chgs####
                 fluidRow(
                   h3("Five Most Common Conviction Offenses and Categories"),
                   downloadButton(ns("dlFreqConvict"), "DOWNLOAD DATA"),
                   h5(HTML(commonPleaConOffCaption)),
                   h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_conv_common"))))
                 ),
                 fluidRow(class = "graph-row",
                          # . . . . for felonies####
                          h4("Felony Cases"),
                          tabsetPanel(
                            tabPanel("2013", 
                                     plotlyOutput(ns('convChgFel13')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2014", 
                                     plotlyOutput(ns('convChgFel14')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2015", 
                                     plotlyOutput(ns('convChgFel15')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2016", 
                                     plotlyOutput(ns('convChgFel16')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2017", 
                                     plotlyOutput(ns('convChgFel17')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2018", 
                                     plotlyOutput(ns('convChgFel18')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2019", 
                                     plotlyOutput(ns('convChgFel19')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2020", 
                                     plotlyOutput(ns('convChgFel20')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2021", 
                                     plotlyOutput(ns('convChgFel21')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2022", 
                                     plotlyOutput(ns('convChgFel22')) %>% 
                                       SPINNER
                            ),
                            tabPanel("All", 
                                     plotlyOutput(ns('convChgFel'), height=HEIGHT_750) %>% 
                                       SPINNER
                            )
                          )
                 ),
                 fluidRow(class = "graph-row",
                          # . . . . for for msd####
                          h4("Misdemeanor Cases"),
                          tabsetPanel(
                            tabPanel("2013", 
                                     plotlyOutput(ns('convChgMisd13')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2014", 
                                     plotlyOutput(ns('convChgMisd14')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2015", 
                                     plotlyOutput(ns('convChgMisd15')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2016", 
                                     plotlyOutput(ns('convChgMisd16')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2017", 
                                     plotlyOutput(ns('convChgMisd17')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2018", 
                                     plotlyOutput(ns('convChgMisd18')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2019", 
                                     plotlyOutput(ns('convChgMisd19')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2020", 
                                     plotlyOutput(ns('convChgMisd20')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2021", 
                                     plotlyOutput(ns('convChgMisd21')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2022", 
                                     plotlyOutput(ns('convChgMisd22')) %>% 
                                       SPINNER
                            ),
                            tabPanel("All", 
                                     plotlyOutput(ns('convChgMisd'), height=HEIGHT_750) %>% 
                                       SPINNER
                            )
                          )
                 ),
                 
                 # . . ACD charges ####
                 fluidRow(
                   h2("Charges Receiving ACDs")
                 ),
                 # . . . most common acd charges ####
                 fluidRow(
                   h3("Five Most Common Alleged Offenses Receiving ACDs"),
                   downloadButton(ns("dlFreqAcd"), "DOWNLOAD DATA"),
                   h5(HTML(commonACDOffCaption)),
                 ),
                 fluidRow(class = "graph-row",
                          # . . . . for msds####
                          h4("Misdemeanor Cases"),
                          tabsetPanel(
                            tabPanel("2013", 
                                     plotlyOutput(ns('acdChgMisd13')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2014", 
                                     plotlyOutput(ns('acdChgMisd14')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2015", 
                                     plotlyOutput(ns('acdChgMisd15')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2016", 
                                     plotlyOutput(ns('acdChgMisd16')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2017", 
                                     plotlyOutput(ns('acdChgMisd17')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2018", 
                                     plotlyOutput(ns('acdChgMisd18')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2019", 
                                     plotlyOutput(ns('acdChgMisd19')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2020", 
                                     plotlyOutput(ns('acdChgMisd20')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2021", 
                                     plotlyOutput(ns('acdChgMisd21')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2022", 
                                     plotlyOutput(ns('acdChgMisd22')) %>% 
                                       SPINNER
                            ),
                            tabPanel("All", 
                                     plotlyOutput(ns('acdChgMisd'), height=HEIGHT_750) %>% 
                                       SPINNER
                            )
                          )
                 ),
                 fluidRow(class = "graph-row",
                          # . . . . for violations####
                          h4("Violation/Infraction Cases"),
                          tabsetPanel(
                            tabPanel("2013", plotlyOutput(ns('acdChgVio13')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2014", 
                                     plotlyOutput(ns('acdChgVio14')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2015", 
                                     plotlyOutput(ns('acdChgVio15')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2016", 
                                     plotlyOutput(ns('acdChgVio16')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2017", 
                                     plotlyOutput(ns('acdChgVio17')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2018", 
                                     plotlyOutput(ns('acdChgVio18')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2019", 
                                     plotlyOutput(ns('acdChgVio19')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2020", 
                                     plotlyOutput(ns('acdChgVio20')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2021", 
                                     plotlyOutput(ns('acdChgVio21')) %>% 
                                       SPINNER
                            ),
                            tabPanel("2022", 
                                     plotlyOutput(ns('acdChgVio22')) %>% 
                                       SPINNER
                            ),
                            tabPanel("All", plotlyOutput(ns('acdChgVio'), height=HEIGHT_750) %>% 
                                       SPINNER
                            )
                          )
                 )
               )
      )
    )
  )
  
  # Final page #### 
  tabPanel(
    title = DISPOSITION_PAGE_TITLE,
    value = DISPOSITION_PAGE_ID,
    pageTabsUI(id = ns('tab'), currDashName = DISPOSITION_PAGE_TITLE),
    fluidRow(class = "page-intro-row",
             column(width = 6,
                    class = "page-intro-text",
                    h3(toupper(DISPOSITION_PAGE_TITLE)),
                    h4(class = "regular", HTML(dispoIntro))
             ),
             pageIntroIconUI(id = ns('intro'), pageName = DISPOSITION_PAGE_TITLE)
    ),
    fluidRow(
      class = "main-row",
      sideBar,
      mainBar
    )
  )
}