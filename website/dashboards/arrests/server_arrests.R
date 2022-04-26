#load packages

library(packcircles);
library(plotly);
library(ggplot2);
library(ggrepel);
library(ggiraph);
library(scales);
library(shiny);
library(shinydashboard);
library(tidyverse);
library(viridis);

arrestServer <- function(id, parent_session) {
  moduleServer(id, 
               function(input, output, session) {
                 
  # page intro
  pageIntroIconServer('intro', parent_session = parent_session)
  pageTabsServer('tab', parent_session = parent_session)
  
  # intro paragraph links (left side)
  observeEvent(input$intro_link_pros_proc,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
               })
  observeEvent(input$intro_link_glossary,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
               })
  # treemap caption link
  observeEvent(input$treemap,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = HOW_TO_PAGE_ID)
               })
  # major group caption link
  observeEvent(input$link_mg_ecab_common,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
               })
  observeEvent(input$link_mg_pros,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
               })
  
  
  
  
  
  #  constants ####
  PROSECUTE <- 'Prosecute'
  DECLINE_TO_PROSECUTE <- 'Decline to Prosecute'
  DEFERRED <- 'Deferred Prosecution'
  
  #  reactive data ####
  dt <- reactive({
    
    validate(
      need(input$firstEvtYear != "", "Please select a screen year."),
      need(input$category != "", "Please select an arrest offense category."),
      need(input$majorGroup != "", "Please select an arrest offense major group."),
      need(input$arrestType != "", "Please select an arrest type."),
      need(input$screenOutcome != "", "Please select a screen outcome."),
      need(input$gender != "", "Please select a gender of arrested individual."),
      need(input$race != "", "Please select a race/ethnicity of arrested individual."),
      need(input$age != "", "Please select age at time of alleged offense of arrested individual."),
      need(input$pct != "", "Please select an arrest location."),
      need(input$priorFelConv != "", "Please select prior Manhattan felony convictions."),
      need(input$priorMisdConv != "", "Please select prior Manhattan misdemeanor convictions."),
      need(input$yrSinceConv != "", "Please select years since most recent Manhattan conviction.")
      
    )
    
    arr_data %>%
      filter(
        firstEvtYear %in% input$firstEvtYear,
        arrestTopCat %in% input$category,
        arrestTopMg %in% input$majorGroup,
        arrestType %in% input$arrestType,
        screenOutcome %in% input$screenOutcome,
        gender %in% input$gender,
        race %in% input$race,
        ageAtOffGrp %in% input$age,
        arrestLocation %in% input$pct,
        priorFelConvGrp %in% input$priorFelConv,
        priorMisdConvGrp %in% input$priorMisdConv,
        yrSinceLastConvGrp %in% input$yrSinceConv)
    
  })
  
  # reset button ####
  observeEvent(input$button_reset, {
    
    # arrest-specific
    updatePickerInput(
      session,
      inputId = 'firstEvtYear',
      selected = YEAR_OPT,
    )
    
    updateCheckboxGroupInput(
      session,
      inputId = 'category',
      selected = CAT_OPT
    )
    
    updatePickerInput(
      session,
      inputId = 'majorGroup',
      selected = MG_OPT
    )
    
    updateCheckboxGroupInput(
      session, inputId = 'arrestType', 
      selected = arrestTypeOptions
    )
    
    updateCheckboxGroupInput(
      session, inputId = 'screenOutcome', 
      selected = screenOutcomeOptions
    )
    
    # demographics
    updateCheckboxGroupInput(
      session, inputId = 'gender', 
      selected = GENDER_OPT
    )
    
    updatePickerInput(
      session, inputId = 'race', 
      selected = RACE_OPT,
    )
    
    updatePickerInput(
      session, inputId = 'age',
      selected = AGE_OPT,
    )
    
    updatePickerInput(
      session, inputId = 'pct',
      selected = PCT_OPT,
    )
    
    # convictions
    updatePickerInput(
      session, inputId = 'priorFelConv', 
      selected = PRIOR_FEL_OPT,
    )
    
    updatePickerInput(
      session, inputId = 'priorMisdConv', 
      selected = PRIOR_MISD_OPT,
    )
    
    updatePickerInput(
      session, inputId = 'yrSinceConv',
      selected = YR_SINCE_CONV_OPT,
    )
    
  })
  
  
  
  #  _____________________________________________
  #  Tab 1                                  ####
  
  ### total arrests screened ####
  
  # . line graph: total arrests screened ####
  output$plot0 <- renderPlotly({
    
    d <- dt() %>% 
      #d <- arr_data %>% 
      group_by(firstEvtYear) %>% 
      summarize(arrests = n_distinct(defendantId)) %>%    
      group_by(firstEvtYear) %>% 
      mutate(arrestLabel = CLEAN_TEXT(arrests)) %>% 
      ungroup() %>% 
      mutate(firstEvtYear = as.character(firstEvtYear),
             hoverText = STRING_BREAK(paste0(arrestLabel, 
                                             ' arrests were screened in ', firstEvtYear, '.'))
      ) %>% 
      arrange(firstEvtYear)  
    
    VALIDATE(d)
    
    p <- ggplot(d, 
                aes(x = firstEvtYear, 
                    y = arrests,
                    group = 1,
                    text = hoverText)
    ) + 
      THEME_LINE_DISCRETE
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests')
    
  })
  
  # . box: arrests screened ####
  output$boxArr <- renderValueBox({
    
    # cat(file=stderr(), "in renderValueBox", input$firstEvtYear, "\n")
    d <- dt() %>% 
      summarize(N = n()) %>% 
      mutate(N = CLEAN_TEXT(N))
    
    valueBox(d, "Arrests screened")
    
  })
  
  # . box: individuals arrested ####
  # TODO: create new identifier to replace NYSID in SQL pull 
  # (for security reasons, real personal identifiers should not be in final data)
  # output$boxArrInd <- renderValueBox({
  #   
  #   d <- dt() %>% 
  #     # arr_data %>% 
  #     filter(!is.na(nysid)) %>%
  #     summarize(N = n_distinct(nysid)) %>% 
  #     mutate(N = CLEAN_TEXT(N))
  #   
  #   missing <- dt() %>%
  #     # arr_data %>%
  #     filter(is.na(nysid)) %>%
  #     summarize(N = n_distinct(defendantId)) %>%
  #     mutate(N = CLEAN_TEXT(N)) %>%
  #     pull
  #   
  #   valueBox(
  #     d,
  #     HTML(
  #       paste0("Individuals arrested* <br/><p style='font-size: 14px;'>* ",
  #              missing,
  #              " arrests were missing a NYSID and excluded from this count.<p>")
  #     )
  #   )
  #   
  # })
  # 
   
  ### arrests by arrest type #### 
  
  # . table ####
   tabArrType <- reactive({
     
       d <- dt() %>%
        #d <- arr_data %>% 
        group_by(firstEvtYear, arrestTopCat, arrestType) %>%
        summarize(arrests = n_distinct(defendantId)) %>% 
        mutate(arrestText = CLEAN_TEXT(arrests),
               hoverText = 
                 STRING_BREAK(
                   paste0(arrestText, ' ', tolower(arrestTopCat), ' ',
                          ifelse(arrestType != 'DAT', tolower(arrestType), arrestType), 
                          's', ' were screened in ', firstEvtYear, '.')))
      
     })
     
  # . dl btn ####
  output$dlArrType <- downloadHandler(
    
    filename = function() {
      "arrests_by_cat_and_type.csv"
    },
    content = function(file) {
      write.csv(tabArrType(), file, row.names = FALSE)
    }
  )
  
  # . line: total arrests by arrest type ####
  output$pArrTypeTotal <- renderPlotly({
    
   d <- tabArrType() %>% 
      group_by(firstEvtYear, arrestType) %>% 
      summarize(arrests = sum(arrests)) %>% 
      mutate(hoverText =
               STRING_BREAK(
                 paste0(CLEAN_TEXT(arrests), ' ',
                        ifelse(arrestType != 'DAT', tolower(arrestType), arrestType),
                        's', ' were screened in ', firstEvtYear, '.' )))
   
   VALIDATE(d)
   
   p <- ggplot(d,
               aes(x = firstEvtYear, 
                   y = arrests,
                   group = arrestType, 
                   shape = arrestType, 
                   text = hoverText, 
                   color = arrestType)
   ) + 
     THEME_LINE_DISCRETE +
     COL_SCALE_ARR_TYPE
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests', 
               legend = 'Arrest Type')
    
  })
  
  # . line: felony arrests by arrest type ####
  output$pArrTypeFel <- renderPlotly({
    
    d <- tabArrType() %>% 
      filter(arrestTopCat == 'Felony') 
      
    VALIDATE(d)
    
   p <- ggplot(d,
        aes(x = firstEvtYear,
            y = arrests,
            group = arrestType,
            color = arrestType,
            shape = arrestType,
            text = hoverText)
      ) + 
      THEME_LINE_DISCRETE + 
      COL_SCALE_ARR_TYPE
    
    LAYOUT_NO_LEG_TITLE(p, x = 'Screen Year', y = 'Felony Arrests')
    
    
  })
  
  # . line: misdemeanor arrests by arrest type ####

    output$pArrTypeMisd <-   renderPlotly({
   
    d <- tabArrType() %>% 
      filter(arrestTopCat == 'Misdemeanor') 
    
    VALIDATE(d)
    
    p <-  ggplot(d,
        aes(x = firstEvtYear,
            y = arrests,
            group = arrestType,
            color = arrestType,
            shape = arrestType,
            text = hoverText)
      ) + 
     
      THEME_LINE_DISCRETE + 
      COL_SCALE_ARR_TYPE

    
  
    
    # if (is.null(p))
    #   return(NULL)
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Misdemeanor Arrests', 
               legend = 'Arrest Type')
   
  })
 
  # . line: violation/infraction arrests by arrest type ####
  output$pArrTypeViol <- renderPlotly({
    
    d <- tabArrType() %>% 
      filter(arrestTopCat == 'Violation/Infraction') 
    
    VALIDATE(d)
    
    p<-  ggplot(d,
        aes(x = firstEvtYear,
            y = arrests,
            group = arrestType,
            color = arrestType,
            shape = arrestType,
            text = hoverText)
      ) + 
      THEME_LINE_DISCRETE + 
      COL_SCALE_ARR_TYPE
    
    LAYOUT_NO_LEG_TITLE(p, x = 'Screen Year', y = 'Violation/Infraction Arrests')
    
  })
  
  
  # arrest characteristics ####
  
  # . table ####
  tabArrChar <- reactive({
    
    tabCat <- dt() %>%
      # arr_data %>% 
      group_by(subCategory = arrestTopCat) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(
        category = 'Arrest Category', # name this section arrest category
        hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabGen <- dt() %>%
      # arr_data %>%
      group_by(subCategory = gender) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Gender', # name this section gender
             hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabRace <- dt() %>%
      group_by(subCategory = race) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Race/Ethnicity',
             hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabAge <- dt() %>%
      group_by(subCategory = ageAtOffGrp) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Age',
             hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabPriorMisd <- dt() %>%
      group_by(subCategory = priorMisdConvGrp) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Prior Manhattan Misdemeanor Convictions',
             hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabPriorFel <- dt() %>%
      group_by(subCategory = priorFelConvGrp) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Prior Manhattan Felony Convictions',
               hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    tabYrLastConv <- dt() %>%
      group_by(subCategory = yrSinceLastConvGrp) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(category = 'Years Since Most Recent Manhattan Conviction',
             hoverText = PERCENT_OUTPUT(arrests/sum(arrests)))
    
    rbind(tabCat, tabGen, tabRace, tabAge,
          tabPriorMisd, tabPriorFel, tabYrLastConv) %>% 
      select(category, subCategory, arrests, hoverText)
    
  })
  
  # . dl btn ####
  output$dlArrChar <- downloadHandler(
    
    filename = function() {
      "arrests_by_characteristics.csv"
    },
    content = function(file) {
      write.csv(tabArrChar(), file, row.names = FALSE)
    }
    
  )
  
  # . tree: arrest by category ####
  output$pArrCat <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Arrest Category') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by gender ####
  output$pArrGen <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Gender') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by race ####
  output$pArrRace <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Race/Ethnicity') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by age ####
  output$pArrAge <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Age') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by prior mds cvct ####
  output$pArrMisdConv <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Prior Manhattan Misdemeanor Convictions') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by prior fel cvct ####
  output$pArrFelConv <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Prior Manhattan Felony Convictions') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText')
    
  })
  
  # . tree: arrest by yr since cvct ####
  output$pYrSinceConv <- renderPlotly({
    
    tabArrChar() %>% 
      filter(category == 'Years Since Most Recent Manhattan Conviction') %>% 
      PLOTLY_TREEMAP(., 'subCategory', 'arrests', 'hoverText') 
    
  })
  
  
  ### 5 most common arrest charges ####
  
  # . table ####
  tabArrChg <- reactive({

    dt() %>%
      # dArrChg <-arr_data %>%
      group_by(year = firstEvtYear, 
               cat = arrestTopCat, 
               grp = arrestTopMg) %>% 
      summarize(cases = n_distinct(defendantId)) %>% 
      group_by(year, cat) %>% 
      mutate(caseLabel = CLEAN_TEXT(cases),
             rank = rank(-cases, ties.method = 'first'),
             year = factor(year)) %>% 
      filter(rank <= 5) %>% 
      ungroup() %>% 
      select(year, cat, grp, cases, caseLabel, rank) %>% 
      mutate(hoverText = STRING_BREAK(
        paste0(caseLabel, ' ', tolower(cat), ' ', tolower(grp), 
               ' arrests were screened in ', year, '.'))) %>% 
      arrange(year, cat, rank)
    
    
    
  })
  
  # . dl btn ####
  output$dlArrChg <- downloadHandler(
    
    filename = function() {
      "arrests_by_cat_and_chg.csv"
    },
    content = function(file) {
      write.csv(
        tabArrChg() %>% 
          rename(
            firstEvtYear = year,
            arrestTopCat = cat,
            arrestTopShort = grp,
            arrests = cases,
            arrestLabel = caseLabel
          ),
        file, row.names = FALSE)
    }
    
  )
  
  # . hztl bar: 5 felony arrest charges ####
  output$arrChgFel13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2013)
  })
  
  output$arrChgFel14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2014)
  })
  
  output$arrChgFel15 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2015)
  })
  
  output$arrChgFel16 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2016)
  })
  
  output$arrChgFel17 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2017)
  })
  
  output$arrChgFel18 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2018)
  })
  
  output$arrChgFel19 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2019)
  })
  
  output$arrChgFel20 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2020)
  })
  
  output$arrChgFel21 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2021)
  })
    
  output$arrChgFel22 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabArrChg, 'Felony', 2022)  
  })
  
  output$arrChgFel <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(tabArrChg, 'Felony')
  })
  
  # . hztl bar: 5 misdemeanor arrest charges ####
  output$arrChgMisd13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2013)
  })
  
  output$arrChgMisd14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2014)
  })
  
  output$arrChgMisd15 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2015)
  })
  
  output$arrChgMisd16 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2016)
  })
  
  output$arrChgMisd17 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2017)
  })
  
  output$arrChgMisd18 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2018)
  })
  
  output$arrChgMisd19 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2019)
  })
  
  output$arrChgMisd20 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2020)
  })
  
  output$arrChgMisd21 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2021)
  })  
    
  output$arrChgMisd22 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Misdemeanor', 2022)    
  })
  
  output$arrChgMisd <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(tabArrChg, 'Misdemeanor')
  })
  
  # . hztl bar: 5 violation/infraction arrest charges ####
  output$arrChgVio13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2013)
  })
  
  output$arrChgVio14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2014)
  })
  
  output$arrChgVio15 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2015)
  })
  
  output$arrChgVio16 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2016)
  })
  
  output$arrChgVio17 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2017)
  })
  
  output$arrChgVio18 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2018)
  })
  
  output$arrChgVio19 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2019)
  })
  
  output$arrChgVio20 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2020)
  })
  
  output$arrChgVio21 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2021)
  })  
    
  output$arrChgVio22 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabArrChg, 'Violation/Infraction', 2022)  
  })
  
  output$arrChgVio <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(tabArrChg, 'Violation/Infraction')
  })
  
  #  _____________________________________________
  #  Tab 2: Arrests Declined to Prosecute   ####
 
  
  ### arrests by screen outcome #### 
  
  # . table ####
  tabArrScreenOut <- reactive({
    
    dt() %>%
      group_by(firstEvtYear, screenOutcome) %>% 
      summarize(arrests = n_distinct(defendantId)) %>% 
      ungroup() %>% 
      mutate(outcomeLabel = 
               case_when(screenOutcome == DECLINE_TO_PROSECUTE ~ 'DPed',
                         screenOutcome == PROSECUTE ~ 'prosecuted',
                         screenOutcome == DEFERRED ~ 'deferred to prosecute',
                         TRUE ~ NA_character_)) %>% 
      mutate(arrestLabel = CLEAN_TEXT(arrests),
             hoverText = 
               STRING_BREAK(
                 paste0(arrestLabel, ' arrests were ', outcomeLabel, 
                        ' at screening in ',  firstEvtYear, '.')))
    
  })
  
  # . dl btn ####
  output$dlArrScreenOut <- downloadHandler(
    
    filename = function() {
      "arrests_by_screen_outcome.csv"
    },
    content = function(file) {
      write.csv(tabArrScreenOut(), file, row.names = FALSE)
    }
    
  )
  
  # . line: arrests by screen outcome ####
  output$pArrScreenOut <- renderPlotly({
    
    p <- ggplot(tabArrScreenOut(),
                aes(x = firstEvtYear,
                    y = arrests,
                    group = screenOutcome,
                    color = screenOutcome,
                    shape = screenOutcome,
                    text = hoverText)
    ) +
      THEME_LINE_DISCRETE +
      COL_SCALE_SCR_OUT
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests', legend = 'Screen Outcome')
    
  })
  
  
  ### arrests DPed by category ####
  
  # . table ####
  tabDpCat <- reactive({
    
    dt() %>%
      filter(isDp == 1) %>%
      group_by(firstEvtYear, arrestTopCat) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      mutate(hoverText = 
               STRING_BREAK(
                 paste0(CLEAN_TEXT(arrests), ' ', tolower(arrestTopCat),
                        ' arrests were DPed in ', firstEvtYear, '.' )))
    
  })
  
  # . dl btn ####
  output$dlDpCat <- downloadHandler(
    
    filename = function() {
      "arrests_dp_by_cat.csv"
    },
    content = function(file) {
      write.csv(tabDpCat(), file, row.names = FALSE)
    }
    
  )
  
  # . line: arrests DPed by category ####
  output$pDpCat <- renderPlotly({
    
    p <- ggplot(tabDpCat(),
                aes(x = firstEvtYear,
                    y = arrests,
                    group = arrestTopCat,
                    color = arrestTopCat,
                    shape = arrestTopCat,
                    text = hoverText)
    ) + 
      THEME_LINE_DISCRETE +
      COL_SCALE_CHG_CAT
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests', legend = 'Arrest Offense')
    
  })
  

  ### arrests DPed by dp reason #### 
  
  # . table ####
  tabDpReason <- reactive({
    
      dt() %>%
      # tabDpReason <- arr_data %>%
      filter(isDp == 1) %>%
      group_by(dpReason) %>%
      summarize(arrests = n_distinct(defendantId)) %>% 
      mutate(rateLabel = PERCENT_OUTPUT(arrests/sum(arrests)),
             hoverText = 
               STRING_BREAK(
                 paste0(CLEAN_TEXT(arrests),
                        ' arrests were DPed for the following reason: ',
                        dpReason,' (', rateLabel, ').')))

  })
  
  # . dl btn ####
  output$dlDpReason <- downloadHandler(
    
    filename = function() {
      "arrests_dp_by_dp_reason.csv"
    },
    content = function(file) {
      write.csv(tabDpReason(), file, row.names = FALSE)
    }
    
  )
  
  # . bubble: arrests DPed by dp reason ####
  # https://www.r-graph-gallery.com/305-basic-circle-packing-with-one-level.html 
  output$pDpReason <- renderGirafe({ 
    
    maxGroup <- max(tabDpReason()$arrests)
    minVal <- maxGroup * .10
    
    packing <- circleProgressiveLayout(
      x = ifelse(tabDpReason()$arrests < 10 & maxGroup > 1000, 
                 tabDpReason()$arrests * 10, 
                 tabDpReason()$arrests), sizetype = 'area')
    
    packing$radius <- 0.95*packing$radius
    
    # create new dataframe with packing values for geom_text
    dp_data <- cbind(tabDpReason(), packing) %>% 
      mutate(label = ifelse(arrests < minVal, '',
                            gsub('[ ]', '\n', dpReason)))
    
    # create dataframe for geom_polygon_interactive
    dp_gg <- circleLayoutVertices(packing, npoints = 50)
    
    p <- ggplot() +
      geom_polygon_interactive(
        data = dp_gg, 
        aes(x, 
            y, 
            group = id, 
            fill = as.factor(id),
            tooltip = tabDpReason()$hoverText[id], 
            data_id = id),
        colour = "white") +
      geom_text(data = dp_data, 
                aes(x, y, 
                    label = label,
                    size = arrests,
                    family = 'proxima'
                ),
                lineheight = .75
      ) + 
      THEME_BUBBLE(discrete = TRUE)
    
    # turn it interactive
    GIRAFE_BUBBLE(p = p) 
    
  })
  
  
  ### mj office dp policy ####
  
  # . table ####
  tabDpMj <- reactive({
    
    dt() %>%
      # test <- arr_data %>% 
      filter(isMj == 1) %>% 
      group_by(firstEvtYear, screenOutcome) %>% 
      summarize(arrests = n()) %>% 
      ungroup() %>% 
      mutate(outcomeLabel = 
               case_when(screenOutcome==DECLINE_TO_PROSECUTE ~ 'DPed',
                         screenOutcome==PROSECUTE ~ 'prosecuted',
                         screenOutcome==DEFERRED ~ 'deferred',
                         TRUE ~ NA_character_),
             hoverText = STRING_BREAK(paste0(CLEAN_TEXT(arrests),
                                             ' marijuana possession/smoking arrests were ', 
                                             outcomeLabel, ' in ', firstEvtYear, '.')))
  })
  
  # . dl btn ####
  output$dlDpMj <- downloadHandler(
    
    filename = function() {
      "arrests_mj_dp_policy.csv"
    },
    content = function(file) {
      write.csv(tabDpMj(), file, row.names = FALSE)
    }
    
  )
  
  # . box: mj prosecuted ####
  output$boxProsMj <- renderValueBox({
    
    d <- tabDpMj() %>% 
      filter(screenOutcome == PROSECUTE) %>% 
      select(arrests) %>% 
      sum() %>% 
      format(big.mark = ",")
    
    valueBox(d, "Arrests prosecuted where marijuana possession/smoking is the top charge")
    
  })
  
  # . box: mj DPed ####
  output$boxDpMj <- renderValueBox({
    
    d <- tabDpMj() %>% 
      filter(screenOutcome == DECLINE_TO_PROSECUTE) %>% 
      select(arrests) %>% 
      sum() %>% 
      format(big.mark = ",")
    
    valueBox(d, "Arrests DPed where marijuana possession/smoking is the top charge")
  })
  
  # . box: mj underlying prosecuted ####
  output$boxUnderlyingMj <- renderValueBox({
    
    d <- dt() %>% 
      filter(hasMjUnderlying == 1, screenOutcome == PROSECUTE, isMj == 0) %>% 
      summarize(N = n()) %>% 
      mutate(N = CLEAN_TEXT(N))
    
    valueBox(d, "Arrests prosecuted with marijuana possession as an underlying charge")
  })
  
  # . line: mj by screen outcome ####
  output$pDpMj <- renderPlotly({
    p <- ggplot(tabDpMj(),
                aes(x = firstEvtYear,
                    y = arrests,
                    group = screenOutcome,
                    shape = screenOutcome,
                    color = screenOutcome,
                    text = hoverText)
    ) + 
      THEME_LINE_DISCRETE + 
      COL_SCALE_SCR_OUT
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests', legend = 'Screen Outcome')
  })
  
  
  ### tos office dp policy ####
  # ToS charges
  # 1     PL 165.15(3)
  # 2     PL 140.10(a)
  # 3 PL 110/140.10(a)
  # 4  PL 140.10(a)(h)
 
  # . table #### 
  tabDpTos <- reactive({
    
    dt() %>% 
      filter(isTos == 1) %>% 
      group_by(firstEvtYear, screenOutcome) %>% 
      summarize(arrests = n()) %>% 
      ungroup() %>% 
      mutate(outcomeLabel = 
               case_when(screenOutcome==DECLINE_TO_PROSECUTE ~ 'DPed',
                         screenOutcome==PROSECUTE ~ 'prosecuted',
                         screenOutcome==DEFERRED ~ 'deferred',
                         TRUE ~ NA_character_),
             hoverText = 
               STRING_BREAK(paste0(CLEAN_TEXT(arrests), 
                                   ' subway fare evasion arrests were ',
                                   outcomeLabel, ' in ', firstEvtYear, '.')))
  })
  
  # . dl btn #### 
  output$dlDpTos <- downloadHandler(
    
    filename = function() {
      "arrests_tos_dp_policy.csv"
    },
    content = function(file) {
      write.csv(tabDpTos(), file, row.names = FALSE)
    }
    
  )
  # . box: tos prosecuted ####
  output$boxProsTos <- renderValueBox({
    
    d <- tabDpTos() %>% 
      filter(screenOutcome == PROSECUTE) %>% 
      select(arrests) %>% 
      sum() %>% 
      CLEAN_TEXT()
    
    valueBox(d, "Arrests prosecuted where subway fare evasion theft of services is the top charge")
    
  })
  
  # . box: tos DPed ####
  output$boxDpTos <- renderValueBox({
    
    d <- tabDpTos() %>% 
      filter(screenOutcome == DECLINE_TO_PROSECUTE) %>% 
      select(arrests) %>% 
      sum() %>% 
      CLEAN_TEXT()
    
    valueBox(d, "Arrests DPed where subway fare evasion theft of services is the top charge")
    
  })
  
  # . box: tos underlying prosecuted ####
  output$boxUnderlyingTos <- renderValueBox({
    d <- dt() %>% 
      filter(hasTosUnderlying == 1, screenOutcome == PROSECUTE, isTos == 0) %>% 
      summarize(n = n()) %>% 
      CLEAN_TEXT()
    
    valueBox(d, "Arrests prosecuted with subway fare evasion theft of services underlying charge")
  })
  
  
  # . line: tos by screen outcome ####
  output$pDpTos <- renderPlotly({
    
    p <- ggplot(tabDpTos(),
                aes(x = firstEvtYear,
                    y = arrests,
                    group = screenOutcome,
                    shape = screenOutcome,
                    color = screenOutcome,
                    text = hoverText)
    ) + 
      THEME_LINE_DISCRETE + 
      COL_SCALE_SCR_OUT
    
    LAYOUT_GEN(p, x = 'Screen Year', y = 'Arrests', legend = 'Screen Outcome')
    
  })
  
  #  _____________________________________________
  #  Tab 3: Arrests Prosecuted                  ####
 
  
  ### arrests prosecuted by charge major group ####
  
  # . table ####
  tabProsMg <- reactive({
    
    dt() %>%
      # tabProsMg <- arr_data %>%
      filter(screenOutcome == PROSECUTE) %>% 
      group_by(scrTopMg) %>% 
      summarize(cases = n()) %>% 
      mutate(
        scrTopMg = gsub('/', ' or ', scrTopMg),
        rateLabel = PERCENT_OUTPUT(cases/sum(cases)),
        hoverText = 
               STRING_BREAK(
                 paste0(CLEAN_TEXT(cases), ' arrests screened had a(n) ', 
                        tolower(scrTopMg), ' alleged offense (', rateLabel, ').')),
             size = ifelse(nchar(scrTopMg) >= 15,
                           ifelse(cases >= 20000, cases/6, cases/8), cases/2) %>% 
               ifelse(is.na(.), 0, .)
      )
    
  })
  
  # . dl btn ####
  output$dlProsMg <- downloadHandler(
    
    filename = function() {
      "arrests_pros_chg_major_grp.csv"
    },
    content = function(file) {
      write.csv(tabProsMg(), file, row.names = FALSE)
    }
    
  )
  
  # . bubble: arrests prosecuted by charge major group ####
  output$pProsMg <- renderGirafe({ 
    
    maxGroup <- max(tabProsMg()$cases)
    minVal <- maxGroup * .10
    
    packing <- circleProgressiveLayout(
      x = ifelse(tabProsMg()$cases < 10 & maxGroup > 1000, 
                 tabProsMg()$cases * 10, 
                 tabProsMg()$cases), sizetype = 'area')
    
    packing$radius <- 0.95 * packing$radius
    
    prosMg_data <- cbind(tabProsMg(), packing) %>% 
      mutate(label = ifelse(cases < minVal, '',
                            gsub('[ ]', '\n', scrTopMg)))
    
    prosMg_gg <- circleLayoutVertices(packing, npoints = 50)
    prosMg_gg$cases <- rep(prosMg_data$cases, each = 51)
    
    p <- ggplot() +
      geom_polygon_interactive(data = prosMg_gg, 
                               aes(x, y, 
                                   group = as.factor(id), 
                                   fill = cases,
                                   tooltip = tabProsMg()$hoverText[id], 
                                   data_id = id),
                               colour = "white") +
      geom_text(data = prosMg_data, 
                    aes(x, y,
                        label = label, 
                        family = 'proxima',
                        size = size
                    ), lineheight = .75) +
       THEME_BUBBLE()
    
    # Turn it interactive
    GIRAFE_BUBBLE(p = p)
    
  })
  
  
  ### arrests prosecuted charge changes in ECAB ####
  
  # . table ####
  tabChgChange <- reactive({
    
    dt() %>%
      # arr_data %>%
      filter(screenOutcome == PROSECUTE) %>% 
      group_by(firstEvtYear, arrestTopCat, chargeChangeDetail) %>% 
      summarize(arrests = n_distinct(defendantId)) %>% 
      group_by(firstEvtYear, arrestTopCat) %>% 
      mutate(rateTotal = arrests/sum(arrests)) %>% 
      mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
             chargeChangeDetail = gsub('/', ' or ', chargeChangeDetail),
             arrestLabel = CLEAN_TEXT(arrests),
             hoverText =  
               STRING_BREAK(
                 ifelse(grepl('to|Unknown', chargeChangeDetail) , 
                        paste0(rateLabel, 
                               ' of ', tolower(arrestTopCat), 
                               ' arrests were screened and the charge was ', 
                               tolower(chargeChangeDetail), ' in ', firstEvtYear, ' (',arrestLabel,' cases)','.'),
                        paste0(rateLabel, 
                               ' of ', tolower(arrestTopCat), 
                               ' arrests were screened and the charge was a(n) ', 
                               tolower(chargeChangeDetail), ' in ', firstEvtYear, ' (',arrestLabel,' cases)','.')
                 ))
      ) 
    
  })
  
  # . dl btn ####
  output$dlChgChange <- downloadHandler(
    
    filename = function() {
      "arrests_pros_chg_change.csv"
    },
    content = function(file) {
      write.csv(tabChgChange(), file, row.names = FALSE)
    }
    
  )
  
  # . vert bar: felony arrests charge changes ####
  output$pChgChangeFel <- renderPlotly({
    
    d <- tabChgChange() %>% 
      # dArrChange %>% 
      filter(arrestTopCat == 'Felony')
    
    p <- ggplot(d,
                aes(x = firstEvtYear,
                    y = rateTotal,
                    fill = chargeChangeDetail,
                    text = hoverText)
    ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_5) +
      THEME_VERT_BAR_STACKED(labelType = percent) +
      COL_SCALE_FILL_CHG_CHNG
    
    LAYOUT_GEN(p, x = 'Screen Year', 
               y = 'Percentage of Felony Arrests Prosecuted',
               legend = 'Charge<br>Changes',
               legend_y = 1.55)
    
  }) 
  
  # . vert bar: misdemeanor arrest charge changes ####
  output$pChgChangeMisd <- renderPlotly({

    d <- tabChgChange() %>% 
      filter(arrestTopCat == 'Misdemeanor')
    
    p <- ggplot(d, 
                aes(x = firstEvtYear,
                    y = rateTotal,
                    fill = chargeChangeDetail,
                    text = hoverText
                )
    ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_5) + 
      THEME_VERT_BAR_STACKED(labelType = percent)
    
    LAYOUT_NO_LEG_TITLE(p, x = 'Screen Year', 
                        y = 'Percentage of Misdemeanor Arrests Prosecuted',
                        legend_y = 1.55)
    
  }) 
  
  # vert bar: violation/infraction arrest charge changes ####
  output$pChgChangeVio <- renderPlotly({  
    
    d <- tabChgChange() %>% 
      filter(arrestTopCat == 'Violation/Infraction')
    
    p <- ggplot(d, 
                aes(x = firstEvtYear,
                    y = rateTotal,
                    fill = chargeChangeDetail,
                    text = hoverText
                )
    ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_5) + 
      THEME_VERT_BAR_STACKED(labelType = percent)
    
    LAYOUT_GEN(p, x = 'Screen Year', 
               y = 'Percentage of Violation/Infraction Arrests Prosecuted',
               legend = 'Charge<br>Changes',
               legend_y = 1.55)
    
  }) 
}

  )
}