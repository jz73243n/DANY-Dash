library(ggiraph)
library(ggplot2); 
library(packcircles); 
library(plotly);
library(scales); 
library(shiny); 
library(tidyverse); 
library(viridis);
library(janitor)



sentenceServer <- function(id, parent_session) {
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
  # treemap link 
  observeEvent(input$treemap,
               {
                 updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = HOW_TO_PAGE_ID)
               })
  
    
    
    s <- reactive({
      
      validate(
        need(input$sentenceYear != "", "Please select a sentence year."),
        need(input$category != "", "Please select a top conviction offense category."),
        need(input$majorGroup != "", "Please select a top conviction offense major group."),
        need(input$sentenceClean != "", "Please select a sentence type."),
        need(input$gender != "", "Please select a gender of sentenced individual."),
        need(input$race != "", "Please select a race/ethnicity of sentenced individual."),
        need(input$age != "", "Please select age at time of alleged offense of sentenced individual."),
        need(input$pct != "", "Please select an arrest location."),
        need(input$priorFelConv != "", "Please select prior Manhattan felony convictions."),
        need(input$priorMisdConv != "", "Please select prior Manhattan misdemeanor convictions."),
        need(input$yrSinceConv != "", "Please select years since most recent Manhattan conviction.")
      )
      
      sen_data %>% 
        filter(
          sentenceYear %in% input$sentenceYear,
          senTopCat %in% input$category,
          senTopMg %in% input$majorGroup,
          sentenceClean %in% input$sentenceClean,
          race %in% input$race,
          gender %in% input$gender,
          ageAtOffGrp %in% input$age,
          arrestLocation %in% input$pct,
          priorFelConvGrp %in% input$priorFelConv,
          priorMisdConvGrp %in% input$priorMisdConv,
          yrSinceLastConvGrp %in% input$yrSinceConv
        )
      
    })
    
    f <- reactive({
      
      fines_data %>% 
        filter(
          sentenceYear %in% input$sentenceYear,
          senFineCat %in% input$category,
          senFineMg %in% input$majorGroup,
          sentenceClean %in% input$sentenceClean,
          race %in% input$race,
          gender %in% input$gender,
          ageAtOffGrp %in% input$age,
          arrestLocation %in% input$pct,
          priorFelConvGrp %in% input$priorFelConv,
          priorMisdConvGrp %in% input$priorMisdConv,
          yrSinceLastConvGrp %in% input$yrSinceConv
        ) 
      
    })
    
  observeEvent(input$button_reset, {
    # sentence-specific
    updatePickerInput(
      session,
      inputId = 'sentenceYear',
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
    
    updatePickerInput(
      session, 
      inputId = 'sentenceClean', 
      selected = sentenceTypeOptions
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
    

    # Tab 1: Cases Sentenced ####
    # . tab: s_tab0 total cases sentenced  ####
    tabSenAll <- reactive({ 
      
      s() %>% 
        #s_tab0 <- sen_data %>%
        group_by(sentenceYear) %>% 
        summarize(cases = n_distinct(defendantId)) %>%    
        group_by(sentenceYear) %>% 
        mutate(caseLabel = CLEAN_TEXT(cases)
        ) %>% 
        ungroup() %>% 
        mutate(sentenceYear = as.character(sentenceYear),
               hoverText = STRING_BREAK(paste0(caseLabel, 
                                  ' cases were sentenced in ', sentenceYear, '.')
        )) %>% 
        arrange(sentenceYear)  
      
    }) 
    
  # . dl btn ####
  output$dlSen <- downloadHandler(
    
    filename = function() {
      "sentences_by_year.csv"
    },
    content = function(file) {
      write.csv(tabSenAll(), 
                file, row.names = FALSE)
    }
  )
  
    # . line: total cases sentenced ####
    output$pSenAll <- renderPlotly({
      
      p <- tabSenAll() %>%
        #s_tab0 %>%
        ggplot(aes(x = sentenceYear, 
                   y = cases,
                   group = 1,
                   text = hoverText
        )) + 
        THEME_LINE_DISCRETE
      
      LAYOUT_GEN(p,
                 x = 'Sentence Year', 
                 y = 'Cases Sentenced')
    })
    # scale_y_continuous(breaks = seq(0, max(s_tab0()$Cases), by = 5000), label = comma) 
    
    
    # . tab: s_tab1 total cases sentenced (by sentence type)
    tabSenType <- reactive({
   
      s() %>% 
        #s_tab1 <- sen_data %>%
        group_by(sentenceYear, senTypeCond) %>% 
        summarize(cases = n_distinct(defendantId)) %>%    
        group_by(sentenceYear) %>% 
        mutate(rateTotal = cases/sum(cases)) %>% 
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>% 
        ungroup %>% 
        mutate(senTypeCond = factor(senTypeCond),
               sentenceYear = as.character(sentenceYear),
               hoverText1 =  STRING_BREAK(ifelse(grepl('Incarceration|Time Served|Probation', senTypeCond) , 
                              paste0(caseLabel, 
                                    ' cases were sentenced to ', 
                                            tolower(senTypeCond),' in ', sentenceYear, '.'),
                              paste0(caseLabel, 
                                  ' cases were sentenced to a(n) ', 
                                  ifelse(grepl('Other', senTypeCond), 'other sentence', tolower(senTypeCond)), ' in ', sentenceYear, '.'))),
               hoverText2 = STRING_BREAK(ifelse(grepl('Incarceration|Time Served|Probation', senTypeCond) ,
                                paste(rateLabel, 'cases sentenced were sentenced to ', tolower(senTypeCond), 'in', sentenceYear, '(',gsub(" ", "", caseLabel),'cases)','.'),
                                paste(rateLabel, 'cases sentenced were sentenced to a(n)', ifelse(grepl('Other', senTypeCond), 'other sentence', tolower(senTypeCond)), 'in', sentenceYear, '(',gsub(" ", "", caseLabel),'cases)','.'))
               
        )) %>% 
        arrange(sentenceYear, senTypeCond)
    })
    
    # . dl btn ####
    output$dlSenType <- downloadHandler(
      
      filename = function() {
        "sentences_by_year_and_type.csv"
      },
      content = function(file) {
        write.csv(tabSenType(), 
                  file, row.names = FALSE)
      }
    )
    
    # . line: all cases by sen type ####  
    output$pSenType <- renderPlotly({
      
      p <- tabSenType() %>%
        #s_tab1 %>%
        ggplot(aes(x = sentenceYear, 
                   y = cases,
                   color = senTypeCond,
                   group = senTypeCond,
                   shape = senTypeCond,
                   text = hoverText1)
        ) +
        THEME_LINE_DISCRETE + 
        COL_SCALE_SEN_TYPE
      
      LAYOUT_GEN(p ,x = 'Sentence Year', y = 'Cases Sentenced',
                  legend = 'Sentence<br>Type', legend_y = 1.35)
    })
    
    
    # . vert stack bar: pct sen by type ####
    output$pSenType2 <- renderPlotly({  
      
      p <- tabSenType() %>% 
        rename(fillVar = senTypeCond)
      
      p <-  ggplot(p,
                  aes(x = sentenceYear, 
                      y = rateTotal, 
                      fill = fillVar,
                      text = hoverText2
                  )
      ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_5) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_SEN_TYPE
      
      LAYOUT_NO_LEG_TITLE(p, 
                          x = 'Sentence Year', 
                          y = 'Percentage of Cases Sentenced',
                          legend_y = 1.35) 
      
    })
    
    # . tab: s_tab2 cases sentenced by categry and sentence type
    tabSenTypeCat <- reactive({
      
      s() %>% 
        #s_tab2 <- sen_data %>%
        group_by(sentenceYear, senTopCat, senTypeCond) %>% 
        summarize(cases = n_distinct(defendantId)) %>%    
        group_by(sentenceYear, senTopCat) %>% 
        mutate(rateTotal = cases/sum(cases)) %>% 
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>% 
        ungroup() %>% 
        mutate(senTopCat = factor(senTopCat),
               senTypeCond = factor(senTypeCond),
               sentenceYear = as.character(sentenceYear),
               hoverText1 = STRING_BREAK(ifelse(grepl('Incarceration|Time Served|Probation', senTypeCond) ,
                            paste0(caseLabel, 
                                   ' cases were sentenced to ', tolower(senTypeCond),' in ', sentenceYear, '.'),
                            paste0(caseLabel, 
                      ' cases were sentenced to a(n) ',ifelse(grepl('Other', senTypeCond), 'other sentence', tolower(senTypeCond)),' in ', sentenceYear, '.'))),
               hoverText2 = STRING_BREAK(ifelse(grepl('Incarceration|Time Served|Probation', senTypeCond) ,
                            paste0(rateLabel, ' of ', tolower(senTopCat), 
                                   ' cases were sentenced to ', tolower(senTypeCond), ' in ', sentenceYear, ' (',caseLabel,' cases)', '.'),
                            paste0(rateLabel, ' of ', tolower(senTopCat), 
                                   ' cases were sentenced to a(n) ', ifelse(grepl('Other', senTypeCond), 'other sentence', tolower(senTypeCond)), ' in ', sentenceYear,' (',caseLabel,' cases)','.'))
        )) %>% 
        arrange(sentenceYear, senTopCat, senTypeCond)
      
    })
    
    # . dl btn ####
    output$dlSenCatType <- downloadHandler(
      
      filename = function() {
        "sentences_by_year_category_and_type.csv"
      },
      content = function(file) {
        write.csv(tabSenTypeCat(), 
                  file, row.names = FALSE)
      }
    )
    
    # . line: sen by type, chg facet ####
    output$pSenTypeFel <- renderPlotly({
      
      d <- tabSenTypeCat() %>% 
        filter(senTopCat=='Felony')
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = sentenceYear, 
                   y = cases, 
                   group = senTypeCond, 
                   color = senTypeCond, 
                   shape = senTypeCond,
                   text = hoverText1)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_SEN_TYPE
      
      LAYOUT_GEN(p, x = 'Sentence Year',y = 'Felony Cases Sentenced',
                  legend = 'Sentence<br>Type', legend_y = 1.3)
    })
    
    output$pSenTypeMisd <- renderPlotly({
      
      d <- tabSenTypeCat() %>% 
        filter(senTopCat=='Misdemeanor')
      
      VALIDATE(d)
      
      p <- ggplot(d, aes(x = sentenceYear, 
                   y = cases, 
                   group = senTypeCond, 
                   color = senTypeCond, 
                   shape = senTypeCond,
                   text = hoverText1)
        ) + 
        THEME_LINE_DISCRETE + 
        COL_SCALE_SEN_TYPE
      
      LAYOUT_GEN(p, x = 'Sentence Year',y = 'Misdemeanor Cases Sentenced',
                 legend = 'Sentence<br>Type', legend_y = 1.3)
                 
    })
    
    
    # . vert stack bar: pct sen type, cat facet ####
    output$pSenTypeFel2 <- renderPlotly({  
      
      d <- tabSenTypeCat() %>% 
        filter(senTopCat=='Felony')
      
      VALIDATE(d)
      
      p <- #s_tab2 %>%
        ggplot(d, aes(x = sentenceYear, 
                   y = rateTotal, 
                   fill = senTypeCond,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_SEN_TYPE 
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Sentence Year', 
                          y = 'Percentage of Felony Cases Sentenced',
                          legend_y = 1.3) 
      
    })
    
    output$pSenTypeMisd2 <- renderPlotly({  
      
      d <- tabSenTypeCat() %>% 
        filter(senTopCat=='Misdemeanor')
      
      VALIDATE(d)
      
      p <- #s_tab2 %>%
        ggplot(d, aes(x = sentenceYear, 
                   y = rateTotal, 
                   fill = senTypeCond,
                   text = hoverText2)
        ) + 
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_SEN_TYPE 
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Sentence Year', 
                          y = 'Percentage of Misdemeanor Cases Sentenced',
                          legend_y = 1.3) 
      
    })
    
    # Tab 2: Prison & Jail ####
    
 tabIncType <- reactive({

   s() %>%     
#s_tabInc <- sen_data %>% 
    filter(senTypeCond == 'Incarceration', 
           ifelse(senTopCat!='Felony' 
                  & sentenceClean=='Prison', 0, 1)==1) %>% 
    mutate(sentenceClean = ifelse(senTopCat!='Felony' 
                                  & sentenceClean =='Jail/Prison',
                                'Jail', 
                                ifelse(sentenceClean == 'Jail/Prison',
                                       'Unknown',
                                       sentenceClean))
           ) %>% 
    group_by(sentenceYear, senTopCat, sentenceClean) %>% 
    summarize(cases = n_distinct(defendantId)) %>% 
    spread(senTopCat, cases) %>% 
    adorn_totals(where = 'col') %>% 
    gather('senTopCat', 'cases', 3:ncol(.)) %>% 
     filter(!is.na(cases)) %>% 
    group_by(sentenceYear, senTopCat) %>% 
    mutate(rateTotal = cases/sum(cases)) %>% 
    mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
           caseLabel = CLEAN_TEXT(cases)
    ) %>% 
    ungroup() %>% 
    mutate(senTopCat = factor(senTopCat),
           sentenceClean = factor(sentenceClean, 
                                  levels = c('Jail', 'Prison', 'Unknown')), 
           sentenceYear = as.character(sentenceYear),
           hoverText1 = STRING_BREAK(
                          paste0(caseLabel,
                            ifelse(senTopCat=='Total', '', 
                               paste0(' ', tolower(senTopCat))),
                                      ' cases received a ',
                            ifelse(sentenceClean=='Unknown', 
                                  'carceral sentence of unknown length ',
                                paste0(tolower(sentenceClean), ' sentence ')), 
                             'in ', sentenceYear, '.')
                          ),
           hoverText2 = STRING_BREAK(
             paste0(rateLabel, ' of ', tolower(senTopCat), 
                    ' cases sentenced in ', sentenceYear,
                    ' were sentenced to', tolower(sentenceClean), 
                    ' (',caseLabel,' cases).')
           )) %>% 
    arrange(sentenceYear, senTopCat, sentenceClean)   
        
    })
    
    # . dl btn ####
  output$dlIncType <- downloadHandler(
      
      filename = function() {
        "carceral_sentences_by_type_cat.csv"
      },
      content = function(file) {
        write.csv(tabIncType(), 
                  file, row.names = FALSE)
      }
    )
    
    output$pIncAll <- renderPlotly({
      
      p <- tabIncType() %>%
        filter(senTopCat=='Total') %>% 
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = sentenceClean,
                   color = sentenceClean,
                   shape = sentenceClean,
                   text = hoverText1
        )) +
        THEME_LINE_DISCRETE +
        COL_SCALE_INC_TYPE
      
      LAYOUT_GEN(p,x = 'Sentence Year',
                 y = 'Cases Sentenced to Incarceration',
                 legend = 'Incarceration<br>Type')
    })
    
    output$pIncFel <- renderPlotly({
      
      p <- tabIncType() %>%
        filter(senTopCat=='Felony') %>% 
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = sentenceClean,
                   color = sentenceClean,
                   shape = sentenceClean,
                   text = hoverText1
        )) +
        THEME_LINE_DISCRETE +
        COL_SCALE_INC_TYPE
      
      LAYOUT_GEN(p,x = 'Sentence Year',
                 y = 'Felony Cases Sentenced to Incarceration',
                 legend = 'Incarceration<br>Type')
    })
    
    output$pIncMisd <- renderPlotly({
      
      p <- tabIncType() %>%
        filter(senTopCat=='Misdemeanor') %>% 
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = sentenceClean,
                   color = sentenceClean,
                   shape = sentenceClean,
                   text = hoverText1
        )) + 
        THEME_LINE_DISCRETE +
        COL_SCALE_INC_TYPE
      
      LAYOUT_GEN(p,x = 'Sentence Year',
                 y = 'Misdemeanor Cases Sentenced to Incarceration',
                 legend = 'Incarceration<br>Type')
    })
    
    # . tab: tabJailTime jail sentences by senTopCat and jail time ####
    tabJailTime <- reactive({
      
      s() %>% 
        #tabJailTime <- sen_data %>%
        filter(sentenceClean == 'Jail') %>% 
        group_by(sentenceYear, senTopCat, confineJailTime) %>% 
        summarize(cases = n_distinct(defendantId)) %>%    
        group_by(sentenceYear, senTopCat) %>% 
        mutate(rateTotal = cases/sum(cases)) %>% 
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>% 
        ungroup() %>% 
        mutate(senTopCat = factor(senTopCat),
               confineJailTime = factor(confineJailTime),
               sentenceYear = as.character(sentenceYear),
               hoverText1 = STRING_BREAK(paste0(caseLabel, ' ' , tolower(senTopCat),
                                   ' cases received a jail sentence of ', 
                                   tolower(confineJailTime) , ' in ', sentenceYear, '.')),
               hoverText2 = STRING_BREAK(paste0(rateLabel, ' of ', tolower(senTopCat), ' cases sentenced to jail received a ', gsub('months', 'month', tolower(confineJailTime)), ' sentence in ', sentenceYear,' (',caseLabel,' cases)',
                                    '.')
        )) %>% 
        arrange(sentenceYear, senTopCat, confineJailTime)
      
    })
    
    # . dl btn ####
    output$dlSenJail <- downloadHandler(
      
      filename = function() {
        "jail_sentences_by_year_cat_and_length.csv"
      },
      content = function(file) {
        write.csv(tabJailTime(), 
                  file, row.names = FALSE)
      }
    )
    
    # . line: jail len, cat facet ####
    output$pJailTimeFel <- renderPlotly({
      
      p <- tabJailTime() %>%
        filter(senTopCat=='Felony') %>% 
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = confineJailTime,
                   color = confineJailTime,
                   shape = confineJailTime,
                   text = hoverText1
        )) +
        THEME_LINE_DISCRETE +
        COL_SCALE_JAIL_LEN
      
      LAYOUT_GEN(p,x = 'Sentence Year',y = 'Cases Felony Sentenced to Jail Time',
                  legend = 'Sentence<br>Length')
    })
    
    output$pJailTimeMisd <- renderPlotly({
      
      p <- tabJailTime() %>%
        filter(senTopCat=='Misdemeanor') %>% 
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = confineJailTime,
                   color = confineJailTime,
                   shape = confineJailTime,
                   text = hoverText1
        )) + 
        THEME_LINE_DISCRETE +
        COL_SCALE_JAIL_LEN
      
      LAYOUT_GEN(p,x = 'Sentence Year',y = 'Misdemeanor Cases Sentenced to Jail Time',
                 legend = 'Sentence<br>Length')
    })
    
    # . vert stack bar: pct confine len, cat facet ####
    output$pJailTimeFel2 <- renderPlotly({
      
      p <- tabJailTime() %>%
        #tabJailTime %>%
        filter(senTopCat=='Felony') %>% 
        ggplot(aes(x = sentenceYear,
                   y = rateTotal,
                   fill = confineJailTime,
                   text = hoverText2)
        ) +
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_JAIL_LEN 
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Sentence Year', 
                              y = 'Percentage of Felony Cases Sentenced to Jail Time')
      
    })
    
    output$pJailTimeMisd2 <- renderPlotly({
      
      p <- tabJailTime() %>%
        #tabJailTime %>%
        filter(senTopCat=='Misdemeanor') %>% 
        ggplot(aes(x = sentenceYear,
                   y = rateTotal,
                   fill = confineJailTime,
                   text = hoverText2)
        ) +
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_JAIL_LEN 
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Sentence Year', 
                          y = 'Percentage of Misdemeanor Cases Sentenced to Jail Time')
      
    })
    
    # . tab: tabPrisTime prison sentences by prison time and senTopCat ####
    tabPrisTime <- reactive({
      
      s() %>%
        #tabPrisTime <- sen_data %>%
        filter(sentenceClean == 'Prison', senTopCat=='Felony') %>%
        group_by(sentenceYear, confinePrisTime) %>%
        summarize(cases = n_distinct(defendantId)) %>%
        group_by(sentenceYear) %>%
        mutate(rateTotal = cases/sum(cases)) %>%
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>%
        ungroup() %>%
        mutate(confinePrisTime = factor(confinePrisTime),
               sentenceYear = as.character(sentenceYear),
               hoverText1 = STRING_BREAK(paste0(caseLabel, 
                                   ' cases received a prison sentence of ', tolower(confinePrisTime),' in ', sentenceYear,  '.')),
               hoverText2 = STRING_BREAK(paste0(rateLabel, ' of cases sentenced to prison received a(n) ', gsub('months', 'month', tolower(confinePrisTime)),' sentence in ', sentenceYear, ' (',caseLabel,' cases)','.')
        )) %>%
        arrange(sentenceYear, confinePrisTime)
      
    })
    
    # . dl btn ####
    output$dlSenPris <- downloadHandler(
      
      filename = function() {
        "felony_prison_sentences_by_year_and_length.csv"
      },
      content = function(file) {
        write.csv(tabPrisTime(), 
                  file, row.names = FALSE)
      }
    )
    
    # . line: prison len fel ####
    output$pPrisTime <- renderPlotly({
      
      p <- tabPrisTime() %>%
        #tabPrisTime %>%
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = confinePrisTime,
                   color = confinePrisTime,
                   shape = confinePrisTime,
                   text = hoverText1
        )) +
        THEME_LINE_DISCRETE + 
        COL_SCALE_PRIS_LEN
      
      LAYOUT_GEN(p,x = 'Sentence Year',y = 'Cases Sentenced to Prison Time',
                  legend = 'Sentence<br>Length', legend_y = 1.4)
      
    })
    
    # . vert stack bar: prison len fel ####
    output$pPrisTime2 <- renderPlotly({
      
      p <-
        tabPrisTime() %>%
        #tabPrisTime %>%
        ggplot(aes(x = sentenceYear,
                   y = rateTotal,
                   fill = confinePrisTime,
                   text = hoverText2
        )
        ) +
        geom_bar(stat = 'identity', position = 'stack') + 
        MOD_GEOM_TEXT(minRate = MIN_RATE_10) + 
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_PRIS_LEN 
      
      LAYOUT_NO_LEG_TITLE(p, x = 'Sentence Year', 
                          y = 'Percentage of Felony Cases Sentenced to Prison Time',
                          legend_y = 1.4)
      
    })  
    
    ############################### Tab 3 ###################
    
    # tab: s_tab5 total monetary sentences ####
    tabSenFine <- reactive({
      
      f() %>%
        # s_tab5 <- fines_data %>%
        group_by(sentenceYear) %>%
        summarize(cases = n_distinct(defendantId)) %>%
        ungroup() %>%
        mutate(caseLabel = CLEAN_TEXT(cases),
               hoverText = STRING_BREAK(paste0(caseLabel,
                                  ' cases were sentenced to a monetary payment in ', sentenceYear, '.'))
        )
      
    })
    
    # . dl btn ####
    output$dlSenFine <- downloadHandler(
      
      filename = function() {
        "monetary_sentences_by_year.csv"
      },
      content = function(file) {
        write.csv(tabSenFine(), 
                  file, row.names = FALSE)
      }
    )
    
    # . line: total monetary sentences ####
    output$pSenFine <- renderPlotly({
      
      p <- tabSenFine() %>%
        # s_p5 <- s_tab5 %>%
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = 1,
                   text = hoverText
        )) + 
        THEME_LINE_DISCRETE
      
      LAYOUT_GEN(p, x = 'Sentence Year',
                         y = 'Cases Sentenced to Pay Monetary Sentence')
    })
    
    # tab: s_tab6 monetary sentences by monetary type (percent) ####
    tabSenFineType <- reactive({
      
      f() %>%
         #s_tab6 <- fines_data %>%
        group_by(sentenceYear, sentenceClean) %>%
        summarize(cases = n_distinct(planningSentencesId)) %>%
        group_by(sentenceYear) %>%
        mutate(rateTotal = cases/sum(cases)) %>%
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>%
        ungroup() %>%
        mutate(sentenceClean = factor(sentenceClean),
               sentenceYear = as.character(sentenceYear),
               hoverText = STRING_BREAK(paste0(rateLabel, 
                                  ' of cases sentenced to a monetary payment had to ',
                                  ifelse(sentenceClean == 'Fine', 'pay a fine',
                                         ifelse(sentenceClean == 'Asset Forfeiture', 'forfeit assets',
                                                'pay restitution')), ' in ', sentenceYear, '.'))
        ) %>%
        arrange(sentenceYear, sentenceClean)
      
    }) 
    
    # . dl btn ####
    output$dlSenFineType <- downloadHandler(
      
      filename = function() {
        "monetary_sentences_by_year_and_type.csv"
      },
      content = function(file) {
        write.csv(tabSenFineType(), 
                  file, row.names = FALSE)
      }
    )
    
    # . vert stack bar: pct pay type ####
    output$pSenFineType <- renderPlotly({
      
      p <- tabSenFineType() %>%
        # s_tab6 %>%
        ggplot(aes(x = sentenceYear,
                   y = rateTotal,
                   fill = sentenceClean,
                   text = hoverText
                   
        )) +
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_5) +
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_2
      
      LAYOUT_GEN(p, x = 'Sentence Year', 
                 y = 'Percentage of Monetary Sentences',
                 legend = 'Payment<br>Type')
      
    })
    
    # tab: s_tab7 monetary sentences by fine senTopCat ####
    tabSenFineAmt <- reactive({
      
      f() %>%
        # s_tab7 <- fines_data %>%
        group_by(sentenceYear, fineCatAmt) %>%
        summarize(cases = n_distinct(planningSentencesId)) %>%
        group_by(sentenceYear) %>%
        mutate(rateTotal = cases/sum(cases)) %>%
        mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
               caseLabel = CLEAN_TEXT(cases)
        ) %>%
        ungroup() %>%
        mutate(fineCatAmt = factor(fineCatAmt),
               sentenceYear = as.character(sentenceYear),
               hoverText1 = STRING_BREAK(paste0(caseLabel,
                                   ' cases sentenced to a monetary payment had to pay ',
                                   ifelse(fineCatAmt=='Unknown',
                                          'an unknown amount',
                                          tolower(fineCatAmt)),
                                   ' in ', sentenceYear, '.')),
               hoverText2 = STRING_BREAK(paste0(rateLabel, 
                                   ' of cases sentenced to a monetary payment had to pay ',
                                   ifelse(fineCatAmt=='Unknown', 
                                          'an unknown amount', 
                                          tolower(fineCatAmt)), 
                                   ' in ', sentenceYear, ' (',caseLabel,' cases)','.')
        )) %>%
        arrange(sentenceYear, fineCatAmt)
      
    })
    
    # . dl btn ####
    output$dlSenFineAmt <- downloadHandler(
      
      filename = function() {
        "monetary_sentences_by_year_and_amount.csv"
      },
      content = function(file) {
        write.csv(tabSenFineAmt(), 
                  file, row.names = FALSE)
      }
    )
    
    
    # . line: payment amount ####
    output$pSenFineAmt <- renderPlotly({
      
      p <- tabSenFineAmt() %>%
        #s_tab7 %>%
        ggplot(aes(x = sentenceYear,
                   y = cases,
                   group = fineCatAmt,
                   color = fineCatAmt,
                   shape = fineCatAmt,
                   text = hoverText1
        )
        ) +
        THEME_LINE_DISCRETE + 
        COL_SCALE_FINE
      
      LAYOUT_GEN(p, x = 'Sentence Year', 
                 y = 'Cases Sentenced to Pay Monetary Sentence',
                 legend = 'Fine<br>Amount', legend_y = 1.4)
      
    }) 
    
    #  . vert stack bar: pct fine amt####
    output$pSenFineAmt2 <- renderPlotly({
      
      p <- tabSenFineAmt() %>%
        #s_tab7 %>%
        ggplot(aes(x = sentenceYear,
                   y = rateTotal,
                   fill = fineCatAmt,
                   text = hoverText2
                   
        )
        ) +
        geom_bar(stat = 'identity', position = 'stack') +
        MOD_GEOM_TEXT(minRate = MIN_RATE_5) +
        THEME_VERT_BAR_STACKED(labelType = percent) + 
        COL_SCALE_FILL_FINE
      
      LAYOUT_NO_LEG_TITLE(
        p, x = "Sentence Year", 
        y = "Percentage of Cases Sentenced to Pay Monetary Sentence", 
        legend_y = 1.4)
      
    })
    
    
    # . not referenced in ui_sentences.R####
    # s_tab8 <- reactive({
    #   
    #   f()  %>%
    #     #s_tab8 <- fines_data %>%
    #     group_by(sentenceYear, senTopCat) %>%
    #     summarize(cases = n_distinct(planningSentencesId)) %>%
    #     group_by(sentenceYear) %>%
    #     mutate(rateTotal = cases/sum(cases)) %>%
    #     mutate(rateLabel = PERCENT_OUTPUT(rateTotal),
    #            caseLabel = CLEAN_TEXT(cases)
    #     ) %>%
    #     ungroup() %>%
    #     mutate(senTopCat = factor(senTopCat),
    #            sentenceYear = as.character(sentenceYear)
    #     ) %>%
    #     arrange(sentenceYear, senTopCat)
    #   
    # })
    # 
    # output$plot8 <- renderPlotly({
    #   
    #   s_p8 <-
    #     s_tab8() %>%
    #     #s_tab8 %>%
    #     ggplot(aes(x = sentenceYear,
    #                y = rateTotal,
    #                fill = senTopCat,
    #                text = paste0(rateLabel, ' of monetary sentences in ', sentenceYear, ' were for ', tolower(senTopCat), ' convictions')
    #     )
    #     ) +
    #     geom_bar(stat = 'identity', position = 'stack') +
    #     scale_y_continuous(label = percent) + 
    #     MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
    #     THEME_VERT_BAR_STACKED()
    #   
    #   s_p8 %>%  LAYOUT_GEN(x = 'Sentence Year', 
    #                        y = 'Percentage of Monetary Sentences',
    #                        legend = 'Payment Amount')
    #   
    # })
    # 
    # 
    # s_tab9 <- reactive({
    #   
    #   f() %>%
    #     #s_tab9 <- fines_data %>%
    #     filter(senTopCat!='Felony') %>%
    #     group_by(sentenceYear, senTopCat, fineCatAmt) %>%
    #     summarize(cases = n_distinct(planningSentencesId)) %>%
    #     group_by(sentenceYear, senTopCat) %>%
    #     mutate(rateTotal = cases/sum(cases)) %>%
    #     mutate(rateLabel = ifelse(rateTotal*100==0, '-', ifelse(rateTotal*100<1 & rateTotal*100>0, sprintf("%.2f%%", rateTotal*100), sprintf("%.1f%%",rateTotal*100))),
    #            caseLabel = CLEAN_TEXT(cases)
    #     ) %>%
    #     top_n(1) %>%
    #     ungroup() %>%
    #     mutate(fineCatAmt = factor(fineCatAmt),
    #            senTopCat = factor(senTopCat),
    #            sentenceYear = as.character(sentenceYear)
    #     ) %>%
    #     arrange(sentenceYear, senTopCat, fineCatAmt)
    #   
    # })
    # 
    # # .
    # output$plot9 <- renderPlotly({
    #   
    #   s_p9 <-
    #     s_tab9() %>%
    #     #s_tab9 %>%
    #     ggplot(aes(x = sentenceYear,
    #                y = cases,
    #                text = paste0('In ', sentenceYear, 'the most common payment amount associated with a monetary sentence on a ', tolower(senTopCat),
    #                              ' conviction was ', tolower(fineCatAmt))
    #     )
    #     ) +
    #     geom_point() +
    #     geom_line() +
    #     geom_text(aes(label = fineCatAmt),
    #               size = 3,
    #               fontface = "bold") + 
    #     facet_grid(rows = vars(senTopCat), 
    #                scales = "free") + 
    #     scale_y_continuous(breaks = seq(0, max(s_tab9()$cases), by = 500), label = comma) +
    #     THEME_VERT_BAR_STACKED()
    #   
    #   
    #   s_p9 %>% LAYOUT_GEN(x =  'Sentence Year', 
    #                       y = 'Monetary Sentences',
    #                       legend = 'Conviction Offense')
    #   
    # })
    # 
    
    # . treemap: case characteristics ####
    
    tabSenChar <- reactive({
      
      tabCat <- s() %>%
        group_by(subCategory = senTopCat) %>%
        summarize(sentences = n_distinct(defendantId)) %>% 
        ungroup() %>% 
        mutate(
          category = 'Sentence Category', # name this section arrest category
          hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      
      tabGen <- s() %>%
        group_by(subCategory = gender) %>%
        summarize(sentences = n_distinct(defendantId)) %>% 
        ungroup() %>% 
        mutate(category = 'Gender', # name this section gender
               hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      
      tabRace <- s() %>%
        group_by(subCategory = race) %>%
        summarize(sentences = n_distinct(defendantId)) %>% 
        ungroup() %>% 
        mutate(category = 'Race/Ethnicity',
               hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      
      # tabAge <- s() %>%
      #   group_by(subCategory = ageAtOffGrp) %>%
      #   summarize(sentences = n_distinct(defendantId)) %>% 
      #   ungroup() %>% 
      #   mutate(category = 'Age',
      #          hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      # 
      # tabPriorMisd <- s() %>%
      #   group_by(subCategory = priorMisdConvGrp) %>%
      #   summarize(sentences = n_distinct(defendantId)) %>% 
      #   ungroup() %>% 
      #   mutate(category = 'Prior Manhattan Misdemeanor Convictions',
      #          hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      # 
      # tabPriorFel <- s() %>%
      #   group_by(subCategory = priorFelConvGrp) %>%
      #   summarize(sentences = n_distinct(defendantId)) %>% 
      #   ungroup() %>% 
      #   mutate(category = 'Prior Manhattan Felony Convictions',
      #          hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      # 
      # tabYrLastConv <- s() %>%
      #   group_by(subCategory = yrSinceLastConvGrp) %>%
      #   summarize(sentences = n_distinct(defendantId)) %>% 
      #   ungroup() %>% 
      #   mutate(category = 'Years Since Most Recent Manhattan Conviction',
      #          hoverText = PERCENT_OUTPUT(sentences/sum(sentences)))
      
      rbind(tabGen, tabRace, tabCat) %>% 
        select(category, subCategory, sentences, hoverText)
      
    })
    
    # . dl btn ####
    output$dlSenChar <- downloadHandler(
      
      filename = function() {
        "sentences_by_characteristics.csv"
      },
      content = function(file) {
        write.csv(tabSenChar(), file, row.names = FALSE)
      }
      
    )
    
    output$pSenGen <- renderPlotly({
      
      tabSenChar() %>% 
        filter(category == 'Gender') %>% 
        PLOTLY_TREEMAP(., 'subCategory', 'sentences', 'hoverText')
      
    })
    
    output$pSenRace <- renderPlotly({
      
      tabSenChar() %>% 
        filter(category == 'Race/Ethnicity') %>% 
        PLOTLY_TREEMAP(., 'subCategory', 'sentences', 'hoverText')
      
    })
    
    
    output$pSenCat <- renderPlotly({
      
      tabSenChar() %>% 
        filter(category == 'Sentence Category') %>% 
        PLOTLY_TREEMAP(., 'subCategory', 'sentences', 'hoverText')
      
    })
    
               }
)
}