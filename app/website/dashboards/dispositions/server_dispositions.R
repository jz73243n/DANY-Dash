library(shiny); library(tidyverse); library(plotly); library(gt)
library(scales); library(packcircles); library(ggplot2); library(viridis)
library(ggiraph); library(stringr);

# setwd('~/dany_dashboard/app/website/')

dispositionServer <- function(id, parent_session) {
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
  
  # major group caption link
  observeEvent(input$link_mg_conv,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
               })
  observeEvent(input$link_mg_conv_common,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
               })
  
    
    dispos <- reactive({
      
      validate(
        need(input$dispoYear != "", "Please select a disposition year."),
        need(input$arcDispo != "", "Please select Yes/No disposed at arraignment."),
        need(input$category != "", "Please select an alleged offense category."),
        need(input$majorGroup != "", "Please select an alleged offense major group."),
        need(input$dispoType != "", "Please select a disposition type."),
        need(input$gender != "", "Please select a gender of charged individual."),
        need(input$race != "", "Please select a race/ethnicity of charged individual."),
        need(input$age != "", "Please select age at time of alleged offense of charged individual."),
        need(input$pct != "", "Please select an arrest location."),
        need(input$priorFelConv != "", "Please select prior Manhattan felony convictions."),
        need(input$priorMisdConv != "", "Please select prior Manhattan misdemeanor convictions."),
        need(input$yrSinceConv != "", "Please select years since most recent Manhattan conviction.")
      )
      
      # debugging test
      # print('dispoYear') 
      # print(unique(dispo_data$dispoYear) %in% input$dispoYear)
      # print('isArcDispo') 
      # print(unique(dispo_data$isArcDispo) %in% input$arcDispo)
      # print('instTopCat') 
      # print(unique(dispo_data$instTopCat) %in% input$category)
      # print('instTopMg') 
      # print(subset(unique(dispo_data$instTopMg), !unique(dispo_data$instTopMg) %in% input$majorGroup))
      # print('dispoType') 
      # print(unique(dispo_data$dispoType) %in% input$dispoType)
      # print('gender') 
      # print(unique(dispo_data$gender) %in% input$gender)
      # print('race') 
      # print(subset(unique(dispo_data$race), !unique(dispo_data$race) %in% input$race))
      # print('age') 
      # print(subset(unique(dispo_data$ageAtOffGrp), !unique(dispo_data$ageAtOffGrp) %in% input$age))
      # print('arrest') 
      # print(unique(dispo_data$arrestLocation) %in% input$pct)
      # print('priorFel') 
      # print(unique(dispo_data$priorFelConvGrp) %in% input$priorFelConv)
      # print('priorMisd') 
      # print(unique(dispo_data$priorMisdConvGrp) %in% input$priorMisdConv)
      # print('yr') 
      # print(unique(dispo_data$yrSinceLastConvGrp) %in% input$yrSinceConv)
      
      dispo_data %>% 
        filter(dispoYear %in% input$dispoYear,
               isArcDispo %in% input$arcDispo,
               instTopCat2 %in% input$category,
               instTopMg %in% input$majorGroup,
               dispoType %in% input$dispoType,
               gender %in% input$gender,
               race %in% input$race,
               ageAtOffGrp %in% input$age,
               arrestLocation %in% input$pct,
               priorFelConvGrp %in% input$priorFelConv,
               priorMisdConvGrp %in% input$priorMisdConv,
               yrSinceLastConvGrp %in% input$yrSinceConv
        )
      
    })
    
  observeEvent(input$button_reset, {
    updatePickerInput(
      session,
      inputId = 'dispoYear',
      selected = YEAR_OPT,
    )
    
    updateCheckboxGroupInput(
      session, 
      inputId = 'arcDispo', 
      selected = ARC_DISPO_SELECT
    )
    
    updateCheckboxGroupInput(
      session,
      inputId = 'category',
      selected = CAT_OPT2
    )
    
    updatePickerInput(
      session, inputId = 'majorGroup', 
      selected = MG_OPT,
    )
    
    updateCheckboxGroupInput(
      # . . . dispo type ####
      session, 
      inputId = 'dispoType', 
      selected = dispoTypeOptions
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
    #  Tab 1: Cases Disposed                        ####
  
      tabDispoAll <- reactive({
        
        dispos() %>% 
        #TODO: when global function is created for aggregation, .drop = FALSE
        # will help autopopulate years with 0 cases 
        group_by(dispoYear, .drop = FALSE) %>% 
        summarize(cases = n_distinct(defendantId)) %>%    
        group_by(dispoYear) %>% 
        mutate(caseLabel = CLEAN_TEXT(cases)) %>% 
        ungroup() %>% 
        mutate(dispoYear = as.character(dispoYear),
               hoverText = 
                 STRING_BREAK(paste0(caseLabel, ' cases were disposed in ', 
                                     dispoYear, '.'))
        ) %>% 
        arrange(dispoYear)  
        
      })
  
  # . dl btn ####
  output$dlDispoAll <- downloadHandler(
    
    filename = function() {
      "cases_dispod.csv"
    },
    content = function(file) {
      write.csv(tabDispoAll(), file, row.names = FALSE)
    }
    
  )
    
    # . line: total cases disposed ####
    output$pDispoAll <- renderPlotly({
      
        p <- tabDispoAll() %>% 
          ggplot(aes(x = dispoYear, 
                     y = cases,
                     group = 1,
                     text = hoverText)
          ) + 
          THEME_LINE_DISCRETE
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Cases Disposed')
      
    })
    

    
    # . tab: dTable2 ####
    tabDispoType <- reactive({
      
        dispos() %>% 
       # dispo_data %>%
          group_by(dispoYear, dispoType) %>% 
          summarize(cases = n_distinct(defendantId)) %>% 
          group_by(dispoYear) %>% 
          mutate(rateTotal = cases/sum(cases)) %>% 
          mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
                 caseLabel = CLEAN_TEXT(cases)
          ) %>% 
          ungroup() %>% 
          mutate(dispoType = factor(dispoType),
                 dispoYear = as.character(dispoYear),
                 hoverText1 = STRING_BREAK(ifelse(grepl('Other', dispoType) , 
                                      paste0(caseLabel, ' cases were disposed with a(n) other disposition in ', 
                                             dispoYear, '.'),
                                      paste0(caseLabel, ' cases were disposed with a(n) ', tolower(dispoType), 
                                             ' in ', dispoYear, '.'))),
                 hoverText2 = STRING_BREAK(ifelse(grepl('Other', dispoType) , 
                                      paste0(rateLabel,' of cases were disposed with a(n) other disposition in ', 
                                             dispoYear, ' (',caseLabel,' cases)', '.'),
                                      paste0(rateLabel,' of cases were disposed with a(n) ', tolower(dispoType), 
                                             ' in ', dispoYear, ' (',caseLabel,' cases)', '.'))
          )) %>% 
          arrange(dispoYear, dispoType)
      
    })
  
  # . dl btn ####
  output$dlDispoType <- downloadHandler(
    
    filename = function() {
      "cases_dispod_by_dispo_type.csv"
    },
    content = function(file) {
      write.csv(tabDispoType(), file, row.names = FALSE)
    }
    
  )
    
    # . line: d by d type ####
    output$pDispoType <- renderPlotly({
      
      p <- tabDispoType() %>%
        # dPlot2 <- dTable2 %>%
        ggplot(aes(x = dispoYear, 
                   y = cases, 
                   group = dispoType,
                   color = dispoType,
                   shape = dispoType,
                   text = hoverText1)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_TYPE
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Cases Disposed', 
                  legend = 'Disposition<br>Type')
      
    })
    
    # . vert stack bar: pct d by d type ####
    output$pDispoType2 <- renderPlotly({    
      
      p <- tabDispoType() %>%
        ggplot(aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = dispoType,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_DSP_TYPE
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', y = 'Percentage of Cases Disposed')
      
    })
    
    
    # . tab: t3 ####
    tabCatDispoType <- reactive({
      
      dispos() %>%
        #dispo_data %>%
        filter(instTopCat!='Unknown') %>% 
        group_by(dispoYear, instTopCat, dispoType) %>% 
        summarize(cases = n_distinct(defendantId)) %>%   
        group_by(dispoYear, instTopCat) %>% 
        mutate(rateTotal = cases/sum(cases)) %>% 
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>% 
        ungroup() %>% 
        mutate(instTopCat = factor(instTopCat),
               dispoType = factor(dispoType),
               dispoYear = as.character(dispoYear),
               hoverText1 = STRING_BREAK(ifelse(grepl('Other', dispoType) ,
                            paste0(caseLabel, 
                                   ' cases were disposed with a(n) other disposition in ', 
                                   dispoYear, '.'),
                            paste0(caseLabel, 
                                  ' cases were disposed with a(n) ', 
                                  tolower(dispoType),' in ', dispoYear, '.'))),
               hoverText2 = STRING_BREAK(ifelse(grepl('Other', dispoType) ,
                            paste0(rateLabel, ' of ', tolower(instTopCat), 
                                   ' cases were disposed with a(n) other disposition in ', dispoYear, ' (',caseLabel,' cases)','.'),
                            paste0(rateLabel, ' of ', tolower(instTopCat), 
                                   ' cases were disposed with a(n) ', tolower(dispoType),' in ', dispoYear, ' (',caseLabel,' cases)','.')))
        ) %>% 
        arrange(dispoYear, instTopCat, dispoType)
      
    })
    
  output$dlCatDispoType <- downloadHandler(
    
    filename = function() {
      "cases_dispod_by_cat_and_dispo_type.csv"
    },
    content = function(file) {
      write.csv(tabCatDispoType(), file, row.names = FALSE)
    }
    
  )
  
    # . line: d by d type, cat facet stack ####
    output$pDispoTypeFel <- renderPlotly({  
      
    d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
    p <- ggplot(d, aes(x = dispoYear, 
                     y = cases,
                     group = dispoType,
                     color = dispoType,
                     shape = dispoType,
                     text = hoverText1)
          ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_TYPE
      
      LAYOUT_GEN(p, x = 'Disposition Year', 
                  y = 'Felony Cases Disposed', legend = 'Disposition<br>Type')
      
    })

    output$pDispoTypeMisd <- renderPlotly({  
      
      d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = cases,
                   group = dispoType,
                   color = dispoType,
                   shape = dispoType,
                   text = hoverText1)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_TYPE
        
        LAYOUT_GEN(p, x = 'Disposition Year', 
                   y = 'Misdemeanor Cases Disposed', 
                   legend = 'Disposition<br>Type')
    })  
    
    output$pDispoTypeViol <- renderPlotly({  
      
      d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Violation/Infraction') 
      
      VALIDATE(d)
      
      p <- #dPlot3 <- dTable3 %>%
        ggplot(d, aes(x = dispoYear, 
                   y = cases,
                   group = dispoType,
                   color = dispoType,
                   shape = dispoType,
                   text = hoverText1)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_TYPE
      
      LAYOUT_GEN(p, x = 'Disposition Year', 
                 y = 'Violation/Infraction Cases Disposed', 
                 legend = 'Disposition<br>Type')
    })  
    
        
    # . vert stack bar: d by type, cat facet stack ####
    output$pDispoTypeFel2 <- renderPlotly({  
      
      d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = dispoType,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_DSP_TYPE
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                             y = 'Percentage of Felony Cases Disposed')
      
    })
    
    output$pDispoTypeMisd2 <- renderPlotly({  
      
      d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = dispoType,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_DSP_TYPE
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                             y = 'Percentage of Misdemeanor Cases Disposed')
      
    })
    
    output$pDispoTypeViol2 <- renderPlotly({  
      
      d <-  tabCatDispoType() %>% 
        filter(instTopCat=='Violation/Infraction') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                     y = rateTotal, 
                     fill = dispoType,
                     text = hoverText2)
          ) + 
          geom_bar(stat = 'identity', position = 'stack') +
          MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
          THEME_VERT_BAR_STACKED(labelType = percent) + 
          COL_SCALE_FILL_DSP_TYPE
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                             y = 'Percentage of Violation/Infraction Cases Disposed')
      
    })
    
    
    # . tab: dTable4 ####
    tabCatConvType <- reactive({
      
        dispos() %>% 
          filter(isPleaConvict == 1, !is.na(dispoTypeDetail), instTopCat!='Unknown') %>% 
          group_by(dispoYear, instTopCat, dispoTypeDetail) %>% 
          summarize(cases = n_distinct(defendantId)) %>%   
          group_by(dispoYear, instTopCat) %>% 
          mutate(rateTotal = cases/sum(cases)) %>% 
          mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
                 caseLabel = CLEAN_TEXT(cases)
          ) %>% 
          ungroup() %>% 
          mutate(instTopCat = factor(instTopCat),
                 dispoTypeDetail = factor(dispoTypeDetail),
                 dispoYear = as.character(dispoYear),
                 hoverText = STRING_BREAK(paste0(caseLabel, ' ', 
                          tolower(instTopCat), ' cases were disposed with a ', 
                          tolower(dispoTypeDetail),' in ', dispoYear, '.')),
                 hoverText2 = STRING_BREAK(paste0(rateLabel, ' of ', tolower(instTopCat), 
                                     ' cases were disposed in ', dispoYear,
                                     ' resulted in a(n) ', tolower(dispoTypeDetail), ' (',caseLabel,' cases)','.'))
          ) %>% 
          arrange(dispoYear, instTopCat,dispoTypeDetail)
      
    })
    
  # . dl btn ####
  output$dlCatConvType <- downloadHandler(
    
    filename = function() {
      "cases_convd_by_cat_and_dispo_type.csv"
    },
    content = function(file) {
      write.csv(tabCatConvType(), file, row.names = FALSE)
    }
    
  )
    
    # Pleas/Trial Convictions by Alleged Offense
    # . line: d detail cvct v plea, cat facet ####
    output$pConvictTypeFel <- renderPlotly({
      
      d <-  tabCatConvType() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = cases, 
                   color = dispoTypeDetail,
                   group = dispoTypeDetail,
                   shape = dispoTypeDetail,
                   text = hoverText)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_CAT
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Felony Cases Convicted', 
                 legend = 'Outcome', legend_y = 1.5)
      
    })
    
    output$pConvictTypeFel2 <- renderPlotly({
      
      d <-  tabCatConvType() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = dispoTypeDetail,
                   text = hoverText2
        )
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_DSP_CAT
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                          y = 'Percentage of Felony Cases Convicted',
                          legend_y = 1.5)
      
    })
    
    output$pConvictTypeMisd <- renderPlotly({
      
      d <-  tabCatConvType() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = cases, 
                   color = dispoTypeDetail,
                   group = dispoTypeDetail,
                   shape = dispoTypeDetail,
                   text = hoverText)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_DSP_CAT
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Misdemeanor Cases Convicted', 
                 legend = 'Outcome', legend_y = 1.5)
    })
    
    output$pConvictTypeMisd2 <- renderPlotly({
      
      d <-  tabCatConvType() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = dispoTypeDetail,
                   text = hoverText2
        )
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_DSP_CAT
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                          y = 'Percentage of Misdemeanor Cases Convicted',
                          legend_y = 1.5)
      
    })
      
    
    # . tab: dTable5 charge changes ####
    tabCatConvChange <- reactive({
      
        dispos() %>%
        # tabCatConvChange <- dispo_data %>%
          filter(isPleaConvict == 1, !is.na(dispoTypeDetail), 
                 instTopCat %in% c('Felony', 'Misdemeanor')) %>% 
          mutate(chargeChangeDetail = gsub('/', ' or ', chargeChangeDetail)) %>% 
          group_by(dispoYear, instTopCat, chargeChangeDetail) %>% 
          summarize(cases = n_distinct(defendantId)) %>%   
          group_by(dispoYear, instTopCat) %>% 
          mutate(rateTotal = cases/sum(cases)) %>% 
          mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
                 caseLabel = CLEAN_TEXT(cases)) %>% 
          ungroup() %>% 
          mutate(instTopCat = factor(instTopCat),
                 chargeChangeDetail = factor(chargeChangeDetail),
                 dispoYear = as.character(dispoYear),
                 hoverText1 = 
                   STRING_BREAK( 
                     ifelse(grepl('Downgraded to a', chargeChangeDetail), 
                            paste0(caseLabel, ' ', 
                                   tolower(instTopCat),
                                   ' cases were ', tolower(chargeChangeDetail),
                                   ' and convicted in ', dispoYear, '.'),
                            paste0(caseLabel, ' ', 
                                   tolower(instTopCat), 
                                   ' cases were convicted on a(n) ', 
                                   tolower(chargeChangeDetail),' in ', 
                                   dispoYear, '.'))),
                 hoverText2 = 
                   STRING_BREAK(
                     ifelse(grepl('Downgraded to a', chargeChangeDetail), 
                            paste0(rateLabel, ' of ',
                                   tolower(instTopCat), 
                                   ' cases were ', tolower(chargeChangeDetail),
                                   ' and convicted in ', dispoYear,  ' (',caseLabel,' cases)','.'),
                            paste0(rateLabel, ' of ',
                                   tolower(instTopCat), 
                                   ' cases were convicted on a(n) ', 
                                   tolower(chargeChangeDetail),' in ', 
                                   dispoYear, ' (',caseLabel,' cases)','.'))
                   )) %>% 
        arrange(dispoYear, instTopCat, chargeChangeDetail)
  
    })
    
  # . dl btn ####
  output$dlCatConvChange <- downloadHandler(
    
    filename = function() {
      "cases_convd_change.csv"
    },
    content = function(file) {
      write.csv(tabCatConvChange(), file, row.names = FALSE)
    }
    
  )
    
    # . line: chg change fel ####
    output$pConvictChangeFel <- renderPlotly({
      
      d <-tabCatConvChange() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                     y = cases, 
                     group = chargeChangeDetail,
                     color = chargeChangeDetail,
                     shape = chargeChangeDetail,
                     text = hoverText1
                       )
          ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_CHG_CHNG
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Felony Cases Convicted', 
                 legend = 'Charge<br>Changes', legend_y = 1.4)
    })

    # . vert bar: chg change pct, felony ####
    output$pConvictChangeFel2 <- renderPlotly({
      
      d <-tabCatConvChange() %>% 
        filter(instTopCat=='Felony') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = chargeChangeDetail,
                   text = hoverText2
                     )
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_CHG_CHNG
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year', 
                          y = 'Percentage of Felony Cases Convicted',
                          legend_y = 1.4)
      
    })
    
    # . line: chg change misd ####
    output$pConvictChangeMisd <- renderPlotly({
      
      d <-tabCatConvChange() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = dispoYear, 
                   y = cases, 
                   group = chargeChangeDetail,
                   color = chargeChangeDetail,
                   shape = chargeChangeDetail,
                   text = hoverText1
        )
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_CHG_CHNG
      
      LAYOUT_GEN(p, x = 'Disposition Year', y = 'Misdemeanor Cases Convicted', 
                 legend = 'Charge<br>Changes', legend_y = 1.5)
                  
    })
    

    # . vert bar: chg change pct, msd ####
    output$pConvictChangeMisd2 <- renderPlotly({
      
      d <-tabCatConvChange() %>% 
        filter(instTopCat=='Misdemeanor') 
      
      VALIDATE(d)
      
      p <- tabCatConvChange() %>% 
        filter(instTopCat=='Misdemeanor') %>% 
        ggplot(aes(x = dispoYear, 
                   y = rateTotal, 
                   fill = chargeChangeDetail,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_CHG_CHNG
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Disposition Year',
                          y = 'Percentage of Misdemeanor Cases Convicted',
                          legend_y = 1.5)
      
      
    })
    
    
    
    #  _____________________________________________
    #  Tab 2: Disposition Charges                   ####
    
    # Major Group
    
    tabConvMg <- reactive({
      
      dispos() %>%
        filter(isPleaConvict==1) %>%
        mutate(dispoTopMg = gsub('/', ' or ', dispoTopMg)) %>% 
        group_by(dispoTopMg) %>%
        summarise(cases = n_distinct(defendantId)) %>%
        ungroup() %>%
        mutate(dispoTopMg = fct_rev(dispoTopMg),
               caseLabel = CLEAN_TEXT(cases),
               rateLabel = PERCENT_OUTPUT(cases/sum(cases)),
               hoverText = paste0(caseLabel, ' cases were convicted on a top charge of ',
                                  tolower(dispoTopMg), ' (', rateLabel,').'),
               size = ifelse(nchar(as.character(dispoTopMg)) >= 15,
                                      ifelse(cases >= 20000, cases/6, cases/8), cases/2) %>% 
                 ifelse(is.na(.), 0, .))
      
    })
    
  # . dl btn ####
  output$dlConvMg <- downloadHandler(
    
    filename = function() {
      "cases_convd_chg_major_grp.csv"
    },
    content = function(file) {
      write.csv(tabConvMg() %>% select(-size), file, row.names = FALSE)
    }
    
  )
    
    # . bubble: d by major group ####
    output$pConvMg <- renderGirafe({
      
      maxGroup <- max(tabConvMg()$cases)
      minVal <- maxGroup * .04
      
      mgPacking <- circleProgressiveLayout(
          ifelse(tabConvMg()$cases < 10 & maxGroup > 1000, 
                 tabConvMg()$cases * 10, 
                 tabConvMg()$cases), sizetype = 'area')
      mgPacking$radius <- 0.95 * mgPacking$radius
      
      mgPack_data <- cbind(tabConvMg(), mgPacking) %>% 
        mutate(label = ifelse(cases < minVal, '',
                              gsub('[ ]', '\n', dispoTopMg)))
      
      mgPack_gg <- circleLayoutVertices(mgPacking, npoints = 50)
      mgPack_gg$cases <- rep(mgPack_data$cases, each = 51)
      
      # Make the plot with a few differences compared to the static version:
      p <- ggplot() +
        geom_polygon_interactive(data = mgPack_gg, 
                                 aes(x, y, 
                                     group = as.factor(id), 
                                     fill = cases, 
                                     tooltip = tabConvMg()$hoverText[id], 
                                     data_id = id), 
                                 colour = "white") +
        geom_text(data = mgPack_data, 
                  aes(x, y, 
                      label = label,
                      size = size,
                      family = 'proxima'
                  ), lineheight = .75) + 
        THEME_BUBBLE()
      
      # Turn it interactive
      GIRAFE_BUBBLE(p)
      
    })
    
    # . tab: tabFreqConvict frq conviction chgs ####
    tabFreqConvict <- reactive({
      
      dispos() %>%
      # tabFreqConvict <- dispo_data %>% 
        filter(dispoType=='Conviction') %>%
        mutate(instTopTxt = 
                 str_squish(gsub('(.*)(-)(.*)', '\\1', instTopTxt))) %>%
        group_by(year = dispoYear, 
                 instTopCat, 
                 grp = paste0(dispoTopCat, ': ', dispoTopTxt)) %>%
        summarise(cases= n_distinct(defendantId)) %>%
        group_by(year, cat = instTopCat) %>%
        mutate(cat = factor(cat),
               rank = rank(-cases, ties.method = 'first'),
               year = factor(year),
               caseLabel = CLEAN_TEXT(cases),
               hoverText = 
                 STRING_BREAK(paste0(caseLabel, ' ', tolower(cat), 
                        ' cases were convicted of ', tolower(grp),  ' in ', year,
                        '.'))) %>% 
        filter(rank<=5) %>%
        mutate(grp = STRING_BREAK(grp)) %>% 
        ungroup() %>% 
        arrange(year, cat, rank)
    })

    # . dl btn ####    
  output$dlFreqConvict <- downloadHandler(
    
    filename = function() {
      "cases_convd_chg.csv"
    },
    content = function(file) {
      write.csv(tabFreqConvict() %>% 
                  rename(dispoYear = year,
                         dispoTopCatTxt = grp) %>% 
                  select(-cat),
                file, row.names = FALSE)
    }
    
  )
    
    # . hrzntl bar: frq fel cvct chgs by yr ####
    output$convChgFel13 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2013)
    })
    
    output$convChgFel14 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2014)
    })
    
    output$convChgFel15<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2015)
    })
    
    output$convChgFel16<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2016)
    })
    
    output$convChgFel17<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2017)
    })
    
    output$convChgFel18<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2018)
    })
    
    output$convChgFel19<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2019)
    })
    
    output$convChgFel20<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2020)
    })
    
    output$convChgFel21<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2021)
    })
    
    output$convChgFel22<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Felony', 2022)
    })
    
    output$convChgFel <- renderPlotly({
      THEME_HORIZONTAL_BAR_FACET(tabFreqConvict, 'Felony')
    })
    
    #  . hrzntl bar: frq msd cvct chgs by yr ####
    output$convChgMisd13 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2013)
    })
    
    output$convChgMisd14 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2014)
    })
    
    output$convChgMisd15<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2015)
    })
    
    output$convChgMisd16<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2016)
    })
    
    output$convChgMisd17<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2017)
    })
    
    output$convChgMisd18<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2018)
    })
    
    output$convChgMisd19<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2019)
    })
    
    output$convChgMisd20<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2020)
    })
    
    output$convChgMisd21<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2021)
    })
    
    output$convChgMisd22<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqConvict, 'Misdemeanor', 2022)
    })
    
    output$convChgMisd <- renderPlotly({
      THEME_HORIZONTAL_BAR_FACET(tabFreqConvict, 'Misdemeanor')
    })
    
    
    # . tab: tabFreqAcd frq acd chgs####
    tabFreqAcd <- reactive({
      
      dispos() %>%
        # dispo_data %>% 
        filter(dispoType=='ACD') %>%
        mutate(instTopTxt = str_squish(gsub('(.*)(-)(.*)', '\\1', instTopTxt))) %>%
        group_by(year = dispoYear, 
                 instTopCat, 
                 grp = instTopTxt) %>%
        summarise(cases = n_distinct(defendantId)) %>%
        group_by(year, cat = instTopCat) %>%
        mutate(
          rank = rank(-cases, ties.method = 'first'),
          caseLabel = CLEAN_TEXT(cases),
          year = factor(year),
          hoverText = paste0(caseLabel, ' ', tolower(cat), 
                             ' cases received an ACD on ', tolower(grp), 
                             ' in ', year, '.')) %>% 
        filter(rank<=5) %>%
        mutate(grp = STRING_BREAK(grp)) %>% 
        ungroup()
      
    })
    
  output$dlFreqAcd <- downloadHandler(
    
    filename = function() {
      "cases_acd_chg.csv"
    },
    content = function(file) {
      write.csv(tabFreqAcd() %>% 
                  rename(dispoYear = year,
                         instTopTxt = grp) %>% 
                  select(-cat),
                file, row.names = FALSE)
    }
    
  )
    
    # . hrzntl bar: msd acds ####
    output$acdChgMisd13 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2013)
    })
    
    output$acdChgMisd14 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2014)
    })
    
    output$acdChgMisd15<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2015)
    })
    
    output$acdChgMisd16<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2016)
    })
    
    output$acdChgMisd17<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2017)
    })
    
    output$acdChgMisd18<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2018)
    })
    
    output$acdChgMisd19<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2019)
    })
    
    output$acdChgMisd20<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2020)
    })
    
    output$acdChgMisd21<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2021)
    })
    
    output$acdChgMisd22<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Misdemeanor', 2022)
    })
    
    output$acdChgMisd <- renderPlotly({
      THEME_HORIZONTAL_BAR_FACET(tabFreqAcd, 'Misdemeanor')
    })
    
    # . hrzntl bar: violation acds ####
    output$acdChgVio13 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2013)
    })
    
    output$acdChgVio14 <- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2014)
    })
    
    output$acdChgVio15<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2015)
    })
    
    output$acdChgVio16<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2016)
    })
    
    output$acdChgVio17<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2017)
    })
    
    output$acdChgVio18<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2018)
    })
    
    output$acdChgVio19<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2019)
    })
    
    output$acdChgVio20<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2020)
    })
    
    output$acdChgVio21<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2021)
    })
    
    output$acdChgVio22<- renderPlotly({
      THEME_HORIZONTAL_BAR(tabFreqAcd, 'Violation/Infraction', 2022)
    })
    
    output$acdChgVio <- renderPlotly({
      THEME_HORIZONTAL_BAR_FACET(tabFreqAcd, 'Violation/Infraction')
    })
    
}

)
}

