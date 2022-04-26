library(shinydashboard);
library(shinyWidgets);
library(ggiraph);
library(packcircles);
library(viridis);


arraignmentUI <- function(id) {
  
  ns <- NS(id)
 
  # import text 
  source('dashboards/arraignments/text_arraignments.R')
 
  # text with links 
  arcIntro <- paste0(
    "The Arraignments Dashboard provides information about cases arraigned in Manhattan Criminal Court each year. \"Year\" indicates when the case was first arraigned. In some instances, an individual's case may originate in Supreme Court, bypassing Criminal Court arraignments. For more information on the arraignment process please see the ",
    as.character(actionLink(inputId = ns('intro_link_pros_proc'), 
                            label = 'Prosecution Process Overview')) ,
    " and ",
    as.character(actionLink(inputId = ns('intro_link_glossary'), 
                            label = 'Glossary')),
    ".")
  
  caseArcIntro <- paste0(
    "Unless they are issued a DAT, arrested individuals are usually arraigned before a judge in Manhattan Criminal Court  within twenty-four hours of their arrest. Before their arraignment, the arrested individual meets with an attorney. If they cannot afford an attorney, one is appointed prior to the arraignment. They then appear before the presiding Criminal Court Judge and are formally charged with a crime. The total number of cases arraigned in Manhattan declined by 57.7% between 2013 and 2019.<br/><br/> 
The resolution of a case is referred to as its \"disposition.\" Many misdemeanor and violation/infraction cases are disposed of at arraignment, particularly for non-violent offenses such as shoplifting, drug possession, or disorderly conduct. 27.7% of cases are resolved at arraignment with dispositions that do not result in a criminal conviction, such as an Adjournment in Contemplation of Dismissal (\"ACD\"), which is a dismissal of all charges following a period (typically six months) of being arrest-free. Almost no felony cases are resolved at arraignment. In 2019, 31.7% of misdemeanor cases and 86.6% of violation or infraction cases were disposed of at arraignment. For more information on cases disposed of at arraignment, please see the ",
    as.character(actionLink(inputId = ns('body_link_disp'), 
                            label = 'Dispositions Dashboard')),
    ".")
  
  bailSummCap2 <- paste0("While an Assistant D.A. may request bail on select cases, judges ultimately determine release status and any conditions for release. The graph below illustrates whether bail was requested by an Assistant D.A. and whether bail was subsequently set by the judge. This graph excludes cases with dollar bail set. 
For more information on dollar bail, and a detailed description of how and when bail is set, please see the ",
                         as.character(actionLink(inputId = ns('body_link_pros_proc'), 
                                                 label = 'Prosecution Process Overview')) ,
                         ".")
  
  
  
  # Side bar #### 
  sideBar <- column(
      width = SIDEBAR_PANEL_WIDTH,
      class = "dash-sidepanel",
      h3("Filters"),
      
      # arraignment-specific
      pickerInput(
        ns('year'), 'Arraignment Year',
        choices = YEAR_OPT, selected = YEAR_OPT,
        options = list(`actions-box` = TRUE), multiple = TRUE
      ),
      checkboxGroupInput(
        ns('category'), 'Alleged Offense Category*',
        choices = CAT_OPT2, selected = CAT_OPT2
      ),
      pickerInput(
        ns('majorGroup'),'Alleged Offense Major Group',
        choices = MG_OPT, select = MG_OPT,
        options = list(`actions-box` = TRUE), multiple = TRUE
      ),
      pickerInput(
        ns('releaseStatus'),'Release Status',
        choices = relStatOpt, select = relStatOpt,
        options = list(`actions-box` = TRUE), multiple = TRUE
      ),
      # demographics
      checkboxGroupInput(
        ns('gender'), 'Gender of Charged Individual**',
        choices = GENDER_OPT, select = GENDER_OPT
      ),
      pickerInput(
        ns('race'), 'Race/Ethnicity of Charged Individual**',
        choices = RACE_OPT, select = RACE_OPT,
        options = list(`actions-box` = TRUE), multiple = TRUE
      ),
      pickerInput(
        ns('age'), 'Age at Time of Alleged Offense of Charged Individual',
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
      RESET_BUTTON(ns('button_reset')),
      VFO_DISCLAIMER,
      DEMO_DISCLAIMER_2
    )
  
  mainBar <- column(
    width = MAIN_PANEL_WIDTH,
    class = "dash-mainpanel",
    tabsetPanel(
      tabPanel(h4("Cases Arraigned"),
               column(
                 width = MAIN_SUBPANEL_WIDTH,
                 offset = MAIN_SUBPANEL_OFFSET,
                 br(),
                 fluidRow(
                   h5(HTML(caseArcIntro))
                 ),
                 
                 fluidRow(class = "graph-row",
                          h3("Cases Arraigned in Manhattan Criminal Court"),
                          # downloadButton("dlArcAll", "DOWNLOAD DATA"),
                          plotlyOutput(ns('pArcAll')) %>% 
                            SPINNER
                 ),
                 
                 fluidRow(class = "graph-row",
                          h3('Cases Arraigned by Alleged Offense Category'),
                          downloadButton(ns("dlArcCat"), "DOWNLOAD DATA"),
                          plotlyOutput(ns('pArcCat')) %>%
                            SPINNER
                 ),

                 fluidRow(
                   h3("Arraignment Outcomes by Alleged Offense Category"),
                   downloadButton(ns('dlArcOut'), "DOWNLOAD DATA")
                 ),
                 fluidRow(class = "graph-row",
                      column(6,
                             h4('Felony Cases'),
                             plotlyOutput(ns('pArcOutFel'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                          ),
                      column(6,
                             h4('Misdemeanor Cases'),
                             plotlyOutput(ns('pArcOutMisd'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                          )
                    ),
                 fluidRow(class = "graph-row",
                          column(6,
                                 h4('Violation/Infraction Cases'),
                                 plotlyOutput(ns('pArcOutViol'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                          )
                 )
               )
      ),
      tabPanel(h4("Cases Continuing Past Arraignment: Custody and Bail"),
               column(
                 width = MAIN_SUBPANEL_WIDTH,
                 offset = MAIN_SUBPANEL_OFFSET,
                 br(),
                 fluidRow(
                   h5(HTML(caseArcContIntro))
                 ),

                 fluidRow(class = "graph-row",
                          h3("Cases Continuing Past Arraignment"),
                          downloadButton(ns("dlArcSurvive"), "DOWNLOAD DATA"),
                          plotlyOutput(ns('pArcSurvive')) %>%
                            SPINNER
                 ),

                 fluidRow(class = "graph-row",
                          h3("Cases Continuing Past Arraignment by Major Group"),
                          h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_survive")))),
                          downloadButton(ns("dlSurviveMg"), "DOWNLOAD DATA"),
                          girafeOutput(ns('pSurviveMg'), height = HEIGHT_750) %>%
                            SPINNER
                 ),

                 fluidRow(
                   h3("Five Most Common Offenses by Top Charges"),
                   h5(HTML(MAJOR_GROUP_CAPTION(ns("link_mg_survive_common")))),
                   downloadButton(ns("dlSurviveChg"), "DOWNLOAD DATA")
                 ),
                 fluidRow(class = "graph-row",
                          h4("Felony Cases"),
                          tabsetPanel(
                            tabPanel("2013", plotlyOutput(ns('survChgFel13')) %>%
                                       SPINNER
                            ),
                            tabPanel("2014", plotlyOutput(ns('survChgFel14')) %>%
                                       SPINNER
                            ),
                            tabPanel("2015", plotlyOutput(ns('survChgFel15')) %>%
                                       SPINNER
                            ),
                            tabPanel("2016", plotlyOutput(ns('survChgFel16')) %>%
                                       SPINNER
                            ),
                            tabPanel("2017", plotlyOutput(ns('survChgFel17')) %>%
                                       SPINNER
                            ),
                            tabPanel("2018", plotlyOutput(ns('survChgFel18')) %>%
                                       SPINNER
                            ),
                            tabPanel("2019", plotlyOutput(ns('survChgFel19')) %>%
                                       SPINNER
                            ),
                            tabPanel("2020", plotlyOutput(ns('survChgFel20')) %>%
                                       SPINNER
                            ),
                            tabPanel("2021", plotlyOutput(ns('survChgFel21')) %>%
                                       SPINNER
                            ),
                            tabPanel("2022", plotlyOutput(ns('survChgFel22')) %>%
                                       SPINNER
                            ),
                            tabPanel("All", plotlyOutput(ns('survChgFel'),
                                                         height = HEIGHT_750) %>%
                                       SPINNER
                            )
                          )
                 ),
                 fluidRow(class = "graph-row",
                          h4("Misdemeanor Cases"),
                          tabsetPanel(
                            tabPanel("2013", plotlyOutput(ns('survChgMisd13')) %>%
                                       SPINNER),
                            tabPanel("2014", plotlyOutput(ns('survChgMisd14')) %>%
                                       SPINNER),
                            tabPanel("2015", plotlyOutput(ns('survChgMisd15')) %>%
                                       SPINNER),
                            tabPanel("2016", plotlyOutput(ns('survChgMisd16')) %>%
                                       SPINNER),
                            tabPanel("2017", plotlyOutput(ns('survChgMisd17')) %>%
                                       SPINNER),
                            tabPanel("2018", plotlyOutput(ns('survChgMisd18')) %>%
                                       SPINNER),
                            tabPanel("2019", plotlyOutput(ns('survChgMisd19')) %>%
                                       SPINNER),
                            tabPanel("2020", plotlyOutput(ns('survChgMisd20')) %>%
                                       SPINNER),
                            tabPanel("2021", plotlyOutput(ns('survChgMisd21')) %>%
                                       SPINNER),
                            tabPanel("2022", plotlyOutput(ns('survChgMisd22')) %>%
                                       SPINNER),
                            tabPanel("All", plotlyOutput(ns('survChgMisd'),
                                                         height = HEIGHT_750) %>%
                                       SPINNER)
                          )
                 ),
                 fluidRow(
                   h3("Release Status at Arraignment by Alleged Offense Category"),
                   downloadButton("dlSurviveRelease", "DOWNLOAD DATA")
                 ),
                 fluidRow(class = "graph-row",
                         column(6,
                          h4("Felony Cases"),
                          plotlyOutput(ns('pSurviveReleaseFel'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                         ),
                         column(6,
                          h4("Misdemeanor Cases"),
                          plotlyOutput(ns('pSurviveReleaseMisd'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                         )
                 ),
                fluidRow(class = "graph-row",
                         column(6,
                         h4("Violation/Infraction Cases"),
                         plotlyOutput(ns('pSurviveReleaseViol'), height = HEIGHT_VERT_STACK) %>%
                           SPINNER
                         )
                         ),
                 fluidRow(
                   h2('Bail')
                 ),

                 fluidRow(class = "graph-row",
                          h3('Total Bail Requested and Set'),
                          downloadButton("dlSurviveBail", "DOWNLOAD DATA"),
                          h5(HTML(bailSummCap2)),
                          column(width = 10,
                                 plotlyOutput(ns('pSurviveBail')) %>%
                                   SPINNER
                          ),
                          column(width = 2,
                                 align = "center",
                                 h4('Graph Summary'),
                                 div(class = "value-box-dynamic",
                                     valueBoxOutput(ns('boxBailReq'), width = NULL)
                                 ),
                                 br(),
                                 div(class = "value-box-dynamic",
                                     valueBoxOutput(ns('boxBailSet'), width = NULL)
                                 )
                          )

                 ),
                fluidRow(
                h3("Bail Requested and Set by Alleged Offense Category"),
                downloadButton("dlBailReqVsSet", "DOWNLOAD DATA"),
                h5(HTML(bailReqSetCap))
                ),
                 fluidRow(class = "graph-row",
                         column(6,
                           h4("Felony Cases"),
                          plotlyOutput(ns('pBailReqVsSetFel'), height = HEIGHT_VERT_STACK) %>%
                            SPINNER
                         ),
                         column(6,
                                h4("Misdemeanor Cases"),
                                plotlyOutput(ns('pBailReqVsSetMisd'), height = HEIGHT_VERT_STACK) %>%
                                  SPINNER
                         )
                 ),
                fluidRow(class = "graph-row",
                         column(6,
                        h4("Violation/Infraction Cases"),
                         plotlyOutput(ns('pBailReqVsSetViol'), height = HEIGHT_VERT_STACK) %>%
                          SPINNER
                         )
                ),
                fluidRow(
                h3("Median Bail Amount Requested and Set by Alleged Offense Category"),
                downloadButton(ns("dlMedianBail"), "DOWNLOAD DATA"),
                h5(HTML(medBailCap))
                ),
                 fluidRow(class = "graph-row",
                         column(6,
                           h4("Felony Cases"),
                          plotlyOutput(ns('pMedianBailFel'), height = HEIGHT_VERT_GRP) %>%
                            SPINNER
                         ),
                         column(6,
                                h4("Misdemeanor Cases"),
                                plotlyOutput(ns('pMedianBailMisd'), height = HEIGHT_VERT_GRP) %>%
                                  SPINNER
                         )
                 ),
                fluidRow(class = "graph-row",
                         column(6,
                         h4("Violation/Infraction Cases"),
                         plotlyOutput(ns('pMedianBailViol'), height = HEIGHT_VERT_GRP) %>%
                           SPINNER
                         )
                ),

                fluidRow(class = "graph-row",
                      h3("Dollar Bail"),
                      h5(HTML(dollarBailCap)),
                      column(width = 4, offset = 4,
                             align = "center",
                             div(class = "value-box-dynamic",
                                 valueBoxOutput(ns('boxDollarBail'), width = NULL)
                             )
                      )
      )
      )
      )
    )
  )
  

  # Final page ####
  tabPanel(
    title = ARRAIGNMENT_PAGE_TITLE,
    value = ARRAIGNMENT_PAGE_ID,
    pageTabsUI(id = ns('tab'), currDashName = ARRAIGNMENT_PAGE_TITLE),
    fluidRow(class = "page-intro-row",
             column(width = 6,
                    class = "page-intro-text",
                    h3(toupper(ARRAIGNMENT_PAGE_TITLE)),
                    h4(class = "regular", HTML(arcIntro)),
             ),
             pageIntroIconUI(id = ns('intro'), pageName = ARRAIGNMENT_PAGE_TITLE)
    ),
    fluidRow(
      class = "main-row",
      sideBar,
      mainBar 
    )
  )
  
}
