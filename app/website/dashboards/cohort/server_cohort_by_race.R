library(shiny); library(tidyverse); library(plotly); library(gt)
library(scales); library(packcircles); library(ggplot2); library(viridis)
library(ggiraph)



cohortServer <- function(id, parent_session) {
  moduleServer(id, 
               function(input, output, session) {
                 
      pageIntroIconServer('intro', parent_session = parent_session)
      pageTabsServer('tab', parent_session = parent_session)
      
      observeEvent(input$arr_link_pros_proc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
                   })
      observeEvent(input$arr_link_glossary,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
                   })
      observeEvent(input$arc_link_pros_proc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
                   })
      observeEvent(input$arc_link_glossary,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
                   })
      observeEvent(input$disp_link_pros_proc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
                   })
      observeEvent(input$disp_link_glossary,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
                   })
      observeEvent(input$ind_link_pros_proc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
                   })
      observeEvent(input$ind_link_glossary,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
                   })
      observeEvent(input$sen_link_pros_proc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = PROSECUTION_PAGE_ID)
                   })
      observeEvent(input$sen_link_glossary,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = GLOSSARY_PAGE_ID)
                   })
      
      observeEvent(input$link_arr,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = ARREST_PAGE_ID)
                   })
      observeEvent(input$link_arc,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = ARRAIGNMENT_PAGE_ID)
                   })
      observeEvent(input$link_disp,
                   {
                     updateTabsetPanel(session = parent_session, inputId = "navbar_page", selected = DISPOSITION_PAGE_ID)
                   })
      observeEvent(input$link_sen,
                   {
                     updateTabsetPanel(session = session, inputId = "navbar_page", selected = SENTENCE_PAGE_ID)
                   })
      
      LEG <- bind_cols(x = c(1,1,1,1,1,1), y = levels(coh_data$raceCat))
      
      cohort <- reactive({
         
        validate(
          need(input$cohortYear != "", "Please select a cohort year."),
          need(input$category != "", "Please select an alleged offense category."),
          need(input$majorGroup != "", "Please select an alleged offense major group."),
          need(input$gender != "", "Please select a gender of individual."),
          need(input$race != "", "Please select a race/ethnicity of individual."),
          need(input$age != "", "Please select age at time of alleged offense of individual."),
          need(input$pct != "", "Please select an arrest location."),
          need(input$priorFelConv != "", "Please select prior Manhattan felony convictions."),
          need(input$priorMisdConv != "", "Please select prior Manhattan misdemeanor convictions."),
          need(input$yrSinceConv != "", "Please select years since most recent Manhattan conviction.")
        )
        
         coh_data %>%
            filter(cohort %in% input$cohortYear,
                   instTopCat %in% input$category,
                   instTopMg %in% input$majorGroup,
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
    updatePickerInput(
      session,
      inputId = 'cohortYear',
      selected = COH_YEAR_OPT,
    )
    
    updateCheckboxGroupInput(
      session,
      inputId = 'category',
      selected = CAT_OPT
    )
    
    updateCheckboxGroupInput(
      session,
      inputId = 'majorGroup',
      selected = MG_OPT
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
      
      # . bar graph: legend ####
      output$legend <- renderPlot({
         
         ggplot(LEG, aes(x, y, group = y, fill = y)) +
            geom_bar(stat = 'identity', width = .8) + 
            coord_flip() +
            theme(axis.text.y = element_blank(),
                  axis.ticks = element_blank(),
                  axis.title = element_blank(), 
                  panel.background = element_blank(),
                  legend.position = "none",
                  axis.text.x = element_text(size = 10)
            ) +
            COL_SCALE_FILL_RACE
         
      })
    
      
      # Tab 1: Screening ####
      # . tab: r1 declined to prosecute ####
  
      r1 <- reactive({
         
         cohort() %>%
            #r1 <- coh_data %>%
            group_by(cohort, raceCat, screenOutcome) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 = STRING_BREAK(paste0(caseLabel, ' of ', caseTotalLabel,' ', raceCat,
                                      ' individuals arrested in ', 
                                      cohort, ' had their case DPed.' )),
                   hoverText2 = STRING_BREAK(paste0('The DP rate for ', raceCat, 
                                       ' individuals arrested in ', cohort, ' is ', rateLabel))
            ) 
         
      })
  
  # . dl btn ####
  output$dlCohDecl <- downloadHandler(
    
    filename = function() {
      "cohorts_by_race_ethnicity_ecab_declinations.csv"
    },
    content = function(file) {
      write.csv(r1() %>% 
                  filter(screenOutcome=='Decline to Prosecute'), 
                file, row.names = FALSE)
    }
  )
      
      # . line: dp ####  
      output$plot_r1 <- renderPlotly({
         
         r_plot1x <- r1() %>%
            #r1 %>%
            filter(screenOutcome=='Decline to Prosecute') %>%
            ggplot(aes(x = cohort,
                       y = cases,
                       group = raceCat,
                       color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE +
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(r_plot1x, x = 'Arrest Cohort', y = 'DPs')
         
         
      }) 
      
      
      # . hrzntl bar: dp pct ####
      output$plot_r1.1 <- renderPlotly({
         
         r_plot1b <- r1() %>%
            # r1 %>%
            filter(screenOutcome=='Decline to Prosecute') %>% 
            ggplot(aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), 
                           position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, 
                       position = position_dodge(width = .8) ) +
            THEME_HORIZONTAL_LOLLI + 
            scale_y_continuous(breaks = seq(0, round(max(r1()$rate),2), by = .01), 
                               label = scales::percent_format(accuracy = 1)) +
            COL_SCALE_RACE
        
         LAYOUT_GEN(r_plot1b, x = 'DP Rate', y = 'Arrest Cohort')
         
      })
      
      
      
      # . tab: r2 bail requested ####
      r2 <- reactive({
         
         cohort() %>%
        # r2 <- coh_data %>%
            filter(screenOutcome=='Prosecute', !is.na(ccArraignId), 
                   ccArraignOutcome == 'Adjourned') %>% 
            group_by(cohort, raceCat, instTopCat, bailRequested) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat, instTopCat) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 =  STRING_BREAK(paste0(caseLabel, ' of ', caseTotalLabel,' ', raceCat,
                                        ' individuals arrested and prosecuted in ', 
                                        cohort, ' were subjected to bail request.')),
                   hoverText2 = STRING_BREAK(paste0(rateLabel, ' of the ', raceCat, 
                                       ' individuals arrested and prosecuted in ', 
                                       cohort, ' were subject to a bail request'))
            ) %>% 
            ungroup() %>% 
            filter(bailRequested == 'Bail Requested') %>% 
            select(-bailRequested)
         
      })
      
  # . dl btn ####
  output$dlCohBailReq <- downloadHandler(
    
    filename = function() {
      "cohorts_by_race_ethnicity_ccarraign_bailrequests.csv"
    },
    content = function(file) {
      write.csv(r2(), 
                file, row.names = FALSE)
    }
  )    
  
  
      # . line: bail request ####
      output$pBailReqFel <- renderPlotly({
         
        d <- r2() %>%
          filter(instTopCat == 'Felony')
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE +
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(p, x = 'Arrest Cohort', y = 'Bail Requests')
         
         
      })
      
      
      # . vert bar: pct race bail #####
      output$pBailReqFel2 <- renderPlotly({
         
        d <- r2() %>%
          filter(instTopCat == 'Felony')
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), 
                           position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
            scale_y_continuous(breaks = seq(0, round(max(r2()$rate),2), by = .1), 
                               label = scales::percent_format(accuracy = 1)) +
            THEME_HORIZONTAL_LOLLI +
            COL_SCALE_RACE
         
         LAYOUT_GEN(p, x = 'Bail Request Rate', y = 'Arrest Cohort')
         
         
      })
      
      
      output$pBailReqMisd <- renderPlotly({
        
        d <- r2() %>%
          filter(instTopCat == 'Misdemeanor')
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                     text = hoverText1)
          ) +
          THEME_LINE_DISCRETE +
          COL_SCALE_RACE + 
          theme(legend.position = "none")
        
        LAYOUT_GEN(p, x = 'Arrest Cohort', y = 'Bail Requests')
        
        
      })
      
      
      # . vert bar: pct race bail #####
      output$pBailReqMisd2 <- renderPlotly({
        
        d <- r2() %>%
          filter(instTopCat == 'Misdemeanor')
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                     text = hoverText2)
          ) +
          geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), 
                         position = position_dodge(width = .8)) +
          geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
          scale_y_continuous(breaks = seq(0, round(max(r2()$rate),2), by = .1), 
                             label = scales::percent_format(accuracy = 1)) +
          THEME_HORIZONTAL_LOLLI +
          COL_SCALE_RACE
        
        LAYOUT_GEN(p, x = 'Bail Request Rate', y = 'Arrest Cohort')
        
      })
      
      
      # . tab: r3 arc release ####
      r3 <- reactive({

         cohort() %>%
            #r3 <- coh_data %>%
            filter(screenOutcome=='Prosecute', !is.na(ccArraignId), ccArraignOutcome == 'Adjourned', instTopCat!='Violation/Infraction') %>%
            mutate(ccArraignRelease = ifelse(ccArraignRelease =='Jail'|ccArraignRelease=='Remand', 'Detained', as.character(ccArraignRelease))) %>%
            group_by(cohort, raceCat, instTopCat, ccArraignRelease) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat, instTopCat) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 = STRING_BREAK(paste0(caseLabel, ' of the ', caseTotalLabel,' ', raceCat,
                                       ' individuals prosecuted in ', cohort, 
                                       ' whose cases\' continued past arraignment ' ,
                                       'were detained at arraignment.')),
                   hoverText2 = STRING_BREAK(paste0(rateLabel, ' of the ', raceCat, 
                                       ' individuals prosecuted in ', cohort, 
                                       ' whose cases continued past arraignment were detained at arraignment'))
            ) %>%
            ungroup() %>% 
            filter(ccArraignRelease == 'Detained')
         
      })
      
      # . dl btn ####
      output$dlCohDetention <- downloadHandler(
        
        filename = function() {
          "cohorts_by_race_ethnicity_ccarraign_detention.csv"
        },
        content = function(file) {
          write.csv(r3(), 
                    file, row.names = FALSE)
        }
      )
      
      # . line: arc release, cat facet ####
      output$pArcReleaseFel <- renderPlotly({
         
        d <- r3() %>%
          filter(instTopCat == 'Felony')
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE +
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(p, x = 'Arrest Cohort', 
                            y = 'Cases Detained at Arraignment')
         
      })
      
      # . vert bar: race pct detained arc ####
      output$pArcReleaseFel2 <- renderPlotly({
       
        d <- r3() %>%
          filter(instTopCat == 'Felony')
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
            scale_y_continuous(breaks = seq(0, round(max(r3()$rate),2), by = .1), 
                               label = scales::percent_format(accuracy = 1)) +
            THEME_HORIZONTAL_LOLLI + 
            COL_SCALE_RACE
         
         LAYOUT_NO_LEG_TITLE(p, x = 'Arraignment Detention Rate', y = 'Arrest Cohort')
         
      })
      
      
      output$pArcReleaseMisd <- renderPlotly({
        
        d <- r3() %>%
          filter(instTopCat == 'Misdemeanor')
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                     text = hoverText1)
          ) +
          THEME_LINE_DISCRETE +
          COL_SCALE_RACE + 
          theme(legend.position = "none")
        
        LAYOUT_GEN(p, x = 'Arrest Cohort', 
                   y = 'Cases Detained at Arraignment')
        
      })
      
      # . vert bar: race pct detained arc ####
      output$pArcReleaseMisd2 <- renderPlotly({
        
        d <- r3() %>%
          filter(instTopCat == 'Misdemeanor')
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                     text = hoverText2)
          ) +
          geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
          geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
          scale_y_continuous(breaks = seq(0, round(max(r3()$rate),2), by = .1), 
                             label = scales::percent_format(accuracy = 1)) +
          THEME_HORIZONTAL_LOLLI + 
          COL_SCALE_RACE
        
        LAYOUT_NO_LEG_TITLE(p, x = 'Arraignment Detention Rate', y = 'Arrest Cohort')
        
      })
      
      # . tab: r4 indict ####
      r4 <- reactive({
         
         cohort() %>%
            #r4 <- coh_data %>%
            filter(instTopCat=='Felony') %>%
            mutate(raceCat = fct_rev(raceCat)) %>%
            group_by(cohort, raceCat, isIndicted) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 = STRING_BREAK(paste0(caseLabel, ' of the ', caseTotalLabel,' ', raceCat,
                                       ' individuals prosecuted in ', cohort, 
                                       " whose cases' continued past arraignment ", 
                                       'were indicted.' )),
                   hoverText2 = STRING_BREAK(paste0(rateLabel, ' of ', raceCat, ' individuals prosecuted in ', cohort, 
                                       ' whose cases continued past arraignment with a felony top charge were indicted.'))
            ) %>%
            filter(isIndicted == 'Indicted')
         
      })
      
      # . dl btn ####
      output$dlCohIndict <- downloadHandler(
        
        filename = function() {
          "cohorts_by_race_ethnicity_felony_indictments.csv"
        },
        content = function(file) {
          write.csv(r4(), 
                    file, row.names = FALSE)
        }
      )
      
      # . line: indict after arc ####
      output$pIndict <- renderPlotly({
         
        d <- r4() 
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE + 
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(p, x = 'Arrest Cohort', 
                            y = 'Cases Indicted')
         
         
         
      })
      
      # . vert bar: pct indict after arc ####
      output$pIndict2 <- renderPlotly({
         
        d <- r4() 
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), 
                           position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, 
                       position = position_dodge(width = .8) ) +
            scale_y_continuous(breaks = seq(0, round(max(r4()$rate),2), by = .05), label = scales::percent_format(accuracy = 1)) +
            THEME_HORIZONTAL_LOLLI + 
            COL_SCALE_RACE 
         
            LAYOUT_GEN(p, x = 'Indictment Rate', y = 'Arrest Cohort', )
         
      })
      
      
      # . tab : r5f fel convictions ####
      r5f <- reactive({
         
         cohort() %>%
            #r5f <- coh_data %>%
            filter(screenOutcome=='Prosecute', instTopCat=='Felony') %>%
            group_by(cohort, raceCat, instantCaseType, dispoType) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat, instantCaseType) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 = STRING_BREAK(paste0(caseLabel, ' of the ', caseTotalLabel,' ', raceCat,
                                      ' individuals prosecuted in ', cohort, " on a felony " ,
                                      'were convicted at trial or by guilty plea.' )),
                   hoverText2 = STRING_BREAK(paste0(rateLabel, ' of ', raceCat, ' individuals prosecuted in ', cohort, 
                                       ' on a felony were convicted at trial or by guilty plea.'))
            )
      })
      
      # . tab: r5m msd cvcts ####
      r5m <- reactive({
        cohort() %>%
          #r5m <- coh_data %>%
          filter(screenOutcome=='Prosecute', instTopCat=='Misdemeanor') %>%
          group_by(cohort, raceCat, instantCaseType, dispoType) %>%
          summarise(cases = n_distinct(defendantId)) %>%
          group_by(cohort, raceCat, instantCaseType) %>%
          mutate(rate = cases/sum(cases),
                 caseTotal = sum(cases)) %>%
          mutate(rateLabel = PERCENT_OUTPUT(rate), 
                 caseLabel = CLEAN_TEXT(cases),
                 caseTotalLabel = CLEAN_TEXT(caseTotal),
                 hoverText1 =  STRING_BREAK(paste0(caseLabel, ' of the ', caseTotalLabel,' ', raceCat,
                                                   ' individuals prosecuted in ', cohort, " on a misdemeanor " ,
                                                   'were convicted at trial or by guilty plea.' )),
                 hoverText2 = STRING_BREAK(paste0(rateLabel, ' of ', raceCat, ' individuals prosecuted in ', cohort, 
                                                  ' on a misdemeanor were convicted at trial or by guilty plea.')
                 ))
        
      })
      
   r5 <- reactive({
        
        bind_rows(r5f() %>% filter(dispoType=='Conviction'),
                  r5m() %>% filter(dispoType=='Conviction')
        )
        
      })
      
      # . dl btn ####
      output$dlCohCvt <- downloadHandler(
        
        filename = function() {
          "cohorts_by_race_ethnicity_convictions.csv"
        },
        content = function(file) {
          write.csv(r5(), 
                    file, row.names = FALSE)
        }
      )
      
      # . line: cvt, fel by ind facet ####
      output$pConvictNotInd <- renderPlotly({
         
        d <- r5f() %>%
          filter(instantCaseType=='Unindicted Felony Case') %>% 
          filter(dispoType=='Conviction') 
        
        VALIDATE(d)
        
         p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE +
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(p, x = 'Arrest Cohort', 
                            y = 'Cases Convicted')
         
      })
      
      
      # . hrzntl bar: pct cvct, fel by ind facet ####
      output$pConvictNotInd2 <- renderPlotly({
         
        d <- r5f() %>%
          filter(dispoType=='Conviction', instantCaseType=='Unindicted Felony Case')
        
        VALIDATE(d)
        
         p <-  ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
            scale_y_continuous(breaks = seq(0, round(max(r5f()$rate),2), by = .1), label = scales::percent_format(accuracy = 1)) +
            THEME_HORIZONTAL_LOLLI + 
            COL_SCALE_RACE
         
         LAYOUT_NO_LEG_TITLE(p,  x= 'Conviction Rate', y = 'Arrest Cohort',)

         
      })
      
      output$pConvictInd <- renderPlotly({
        
        d <- r5f() %>%
          filter(dispoType=='Conviction', instantCaseType=='Indicted Felony Case') 
          
          VALIDATE(d)
        
        p <-  #r5f %>%
          ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                     text = hoverText1)
          ) +
          THEME_LINE_DISCRETE +
          COL_SCALE_RACE + 
          theme(legend.position = "none")
        
        LAYOUT_GEN(p, x = 'Arrest Cohort', 
                   y = 'Cases Convicted')
        
      })
      
      
      # . hrzntl bar: pct cvct, fel by ind facet ####
      output$pConvictInd2 <- renderPlotly({
        
        d <- r5f() %>%
          filter(dispoType=='Conviction', instantCaseType=='Indicted Felony Case') 
          
          VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                     text = hoverText2)
          ) +
          geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
          geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
          scale_y_continuous(breaks = seq(0, round(max(r5f()$rate),2), by = .1), label = scales::percent_format(accuracy = 1)) +
          THEME_HORIZONTAL_LOLLI + 
          COL_SCALE_RACE
        
        LAYOUT_NO_LEG_TITLE(p, x = 'Conviction Rate', y = 'Arrest Cohort')
        
      })
      
      
      # . line: msd cvcts ####
      output$pConvictMisd <- renderPlotly({
        
        d <- r5m() %>%
          filter(dispoType=='Conviction') 
          
          VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                     text = hoverText1)
          ) +
          THEME_LINE_DISCRETE +
          COL_SCALE_RACE + 
          theme(legend.position = "none")
        
        LAYOUT_GEN(p, x = 'Arrest Cohort', 
                   y = 'Cases Convicted')
        
      })
      
      
      # . hrzntl bar: pct cvct, fel by ind facet ####
      output$pConvictMisd2 <- renderPlotly({
       
        d <- r5m() %>%
          filter(dispoType=='Conviction') 
        
        VALIDATE(d)
        
        p <- ggplot(d, aes(x = cohort, y = rate, group = raceCat,
                     text = hoverText2)
          ) +
          geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
          geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
          scale_y_continuous(breaks = seq(0, round(max(r5f()$rate),2), by = .1), label = scales::percent_format(accuracy = 1)) +
          THEME_HORIZONTAL_LOLLI + 
          COL_SCALE_RACE
        
        LAYOUT_NO_LEG_TITLE(p, x = 'Conviction Rate', y = 'Arrest Cohort')
        
        
      })
      
      # . tab: r6 incarceration ####
      r6 <- reactive({
         
         cohort() %>%
            #r6 <- coh_data %>%
            filter(dispoType=='Conviction') %>%
            group_by(cohort, raceCat, dispoTopCat, 
                     sentenceType = ifelse(grepl('Jail', sentenceType)|grepl('Prison', sentenceType), 
                                           'Incarceration', as.character(sentenceType))) %>%
            summarise(cases = n_distinct(defendantId)) %>%
            group_by(cohort, raceCat, dispoTopCat) %>%
            mutate(rate = cases/sum(cases),
                   caseTotal = sum(cases)) %>%
            mutate(rateLabel = PERCENT_OUTPUT(rate), 
                   caseLabel = CLEAN_TEXT(cases),
                   caseTotalLabel = CLEAN_TEXT(caseTotal),
                   hoverText1 = 
                     STRING_BREAK(
                       paste0(caseLabel, ' of the ', caseTotalLabel,' ', raceCat,
                              ' individuals prosecuted in ', cohort, 
                              ' and convicted at trial or by guilty plea ',  
                              'were sentenced to a term of incarceration.')),
                   hoverText2 = 
                     STRING_BREAK(
                       paste0(
                         rateLabel, ' of ', raceCat, ' individuals prosecuted in ',  
                         cohort, 
                         ' and convicted at trial or by guilty plea were sentenced to a term of incarceration.')))
        
      })
      
      # . dl btn ####
      output$dlCohIncarc <- downloadHandler(
        
        filename = function() {
          "cohorts_by_race_ethnicity_incarcerations.csv"
        },
        content = function(file) {
          write.csv(r6(), 
                    file, row.names = FALSE)
        }
      )
      
      # . line: incarceration ####
      output$pIncFel <- renderPlotly({
         
         p <-
            r6() %>%
            #r6 %>%
            filter(!is.na(dispoTopCat), sentenceType=='Incarceration',
                   dispoTopCat == 'Felony') %>%
            ggplot(aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                       text = hoverText1)
            ) +
            THEME_LINE_DISCRETE +
            COL_SCALE_RACE + 
            theme(legend.position = "none")
         
         LAYOUT_GEN(p, x = 'Arrest Cohort', 
                            y = 'Cases Incarcerated')
         
      })
      
      
      # . hrzntl bar: pct incarceration ####
      output$pIncFel2 <- renderPlotly({
         
         p <-
            r6() %>%
            #r6 %>%
            filter(!is.na(dispoTopCat), sentenceType=='Incarceration', dispoTopCat=='Felony') %>%
            ggplot(aes(x = cohort, y = rate, group = raceCat,
                       text = hoverText2)
            ) +
            geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
            geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
            scale_y_continuous(label = scales::percent_format(accuracy = 1)) + 
            THEME_HORIZONTAL_LOLLI + 
            COL_SCALE_RACE
        
         LAYOUT_NO_LEG_TITLE(p, x = 'Incarceration Rate', y = 'Arrest Cohort')
         
      })
      
      output$pIncMisd <- renderPlotly({
        
        p <-
          r6() %>%
          #r6 %>%
          filter(!is.na(dispoTopCat), sentenceType=='Incarceration',
                 dispoTopCat == 'Misdemeanor') %>%
          ggplot(aes(x = cohort, y = cases, group = raceCat, color = raceCat,
                     text = hoverText1)
          ) +
          THEME_LINE_DISCRETE +
          COL_SCALE_RACE + 
          theme(legend.position = "none")
        
        LAYOUT_GEN(p, x = 'Arrest Cohort', 
                   y = 'Cases Incarcerated')
        
      })
      
      
      # . hrzntl bar: pct incarceration ####
      output$pIncMisd2 <- renderPlotly({
        
        p <-
          r6() %>%
          #r6 %>%
          filter(!is.na(dispoTopCat), sentenceType=='Incarceration', dispoTopCat=='Misdemeanor') %>%
          ggplot(aes(x = cohort, y = rate, group = raceCat,
                     text = hoverText2)
          ) +
          geom_linerange(aes(x=cohort, ymin=0, ymax=rate, color = raceCat), position = position_dodge(width = .8)) +
          geom_point(aes(color = raceCat), size = 1, position = position_dodge(width = .8) ) +
          scale_y_continuous(label = scales::percent_format(accuracy = 1)) +
          THEME_HORIZONTAL_LOLLI +
          COL_SCALE_RACE
        
        LAYOUT_NO_LEG_TITLE(p, x = 'Incarceration Rate', y = 'Arrest Cohort')
        
      })
      
}
)
}



