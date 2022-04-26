library(shiny);
library(tidyverse);
library(plotly);
library(ggplot2);
library(scales);
library(grid);
library(stringr);
library(numform);
library(shinydashboard);

       
       
arraignmentServer <- function(id, parent_session) {
  moduleServer(id, 
               function(input, output, session) {
                 
  # page intro modules
  pageIntroIconServer('intro', parent_session = parent_session)
  pageTabsServer('tab', parent_session = parent_session)
  
  # intro paragraph links (left side)
  observeEvent(input$intro_link_pros_proc, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  observeEvent(input$intro_link_glossary, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  # body links
  observeEvent(input$body_link_disp, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = DISPOSITION_PAGE_ID)
  })
  observeEvent(input$body_link_pros_proc, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = PROSECUTION_PAGE_ID)
  })
  # major group caption link
  observeEvent(input$link_mg_survive, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  observeEvent(input$link_mg_survive_common, {
    updateTabsetPanel(session = parent_session, inputId = "navbar_page", 
                      selected = GLOSSARY_PAGE_ID)
  })
  
  
                 
  # filter reactive data
      dt <- reactive({
        
        validate(
          need(input$year != "", "Please select an arraignment year."),
          need(input$category != "", "Please select an alleged offense category."),
          need(input$majorGroup != "", "Please select an alleged offense major group."),
          need(input$releaseStatus != "", "Please select a release status."),
          need(input$gender != "", "Please select a gender of charged individual."),
          need(input$race != "", "Please select a race/ethnicity of charged individual."),
          need(input$age != "", "Please select age at time of alleged offense of charged individual."),
          need(input$pct != "", "Please select an arrest location."),
          need(input$priorFelConv != "", "Please select prior Manhattan felony convictions."),
          need(input$priorMisdConv != "", "Please select prior Manhattan misdemeanor convictions."),
          need(input$yrSinceConv != "", "Please select years since most recent Manhattan conviction.")
        )
       
       
       arc_data %>% 
         filter(
           arcYear %in% input$year,
           scrTopCat2 %in% input$category,
           scrTopMg %in% input$majorGroup,
           releaseStatusCond %in% input$releaseStatus,
           gender %in% input$gender,
           race %in% input$race,
           ageAtOffGrp %in% input$age,
           arrestLocation %in% input$pct,
           priorFelConvGrp %in% input$priorFelConv,
           priorMisdConvGrp %in% input$priorMisdConv,
           yrSinceLastConvGrp %in% input$yrSinceConv
         )
       
      })
  
  # reset button
      
      observeEvent(input$button_reset, {
        
        updatePickerInput(
          session,
          inputId = 'year',
          selected = YEAR_OPT,
        )
        
        updateCheckboxGroupInput(
          session,
          inputId = 'category',
          selected = CAT_OPT2
        )
        
        updatePickerInput(
          session,
          inputId = 'majorGroup',
          selected = MG_OPT
        )
        
        updateCheckboxGroupInput(
          session, inputId = 'releaseStatus', 
          selected = relStatOpt
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
  #  Tab 1: Cases Arraigned by Cat                ####
  #  Cases Arraigned
  
  ### total cases arraigned ####
  
  # . table ####
  tabArcAll <- reactive({

    dt() %>%
      #arc_data %>%
      group_by(arcYear) %>%
      summarize(cases = n_distinct(defendantId)) %>%
      group_by(arcYear) %>%
      mutate(caseLabel = CLEAN_TEXT(cases)) %>%
      ungroup() %>%
      mutate(arcYear = as.character(arcYear),
             hoverText =
               STRING_BREAK(
                 paste0(caseLabel,
                        ' cases were arraigned in ', arcYear, '.')))

  })

  # # . dl btn ####
  output$dlArcAll <- downloadHandler(

    filename = function() {
      "cases_arraign.csv"
    },
    content = function(file) {
      write.csv(tabArcAll(), file, row.names = FALSE)
    }

  )

  # . line: arc total ####
  output$pArcAll <- renderPlotly({

    p <- ggplot(tabArcAll(),
                aes(x = arcYear,
                    y = cases,
                    group = 1,
                    text = hoverText)
    ) +
      THEME_LINE_DISCRETE

    LAYOUT_GEN(p, x = 'Arraignment Year', y = 'Cases Arraigned')

  })


  ### cases arraigned by category ####

  # . table ####
  tabArcCat <- reactive({

    dt() %>%
      # arc_data %>%
      group_by(arcYear, scrTopCat) %>%
      summarize(cases = n_distinct(defendantId)) %>%
      group_by(arcYear) %>%
      mutate(caseLabel = CLEAN_TEXT(cases),
             rateTotal = cases/sum(cases),
             rateLabel = PERCENT_OUTPUT(rateTotal),
             hoverText = STRING_BREAK(paste0(caseLabel, ' ', tolower(scrTopCat),
                                             ' cases were arraigned in ', arcYear, '.'))
      ) %>%
      ungroup()

  })

  # . dl btn ####
  output$dlArcCat <- downloadHandler(

    filename = function() {
      "cases_arraign_by_cat.csv"
    },
    content = function(file) {
      write.csv(tabArcCat(), file, row.names = FALSE)
    }

  )

  # . line: arc by cat ####
  output$pArcCat <- renderPlotly({

    p <- ggplot(tabArcCat(),
                aes(x = arcYear,y = cases, group = scrTopCat, color = scrTopCat,
                    shape = scrTopCat, text = hoverText)
    ) +
      THEME_LINE_DISCRETE +
      COL_SCALE_CHG_CAT

    LAYOUT_GEN(p, x = 'Arraignment Year', y = 'Cases Arraigned',
               legend = 'Alleged Offense Category')
  })

  ### cases arraigned by arraignment outcome ####

  # . table ####
  tabArcOut <- reactive({

    dt() %>%
      # tabArcOut <- arc_data %>%
      group_by(arcYear,
               scrTopCat,
               arcOutcome = arcSurviveTxt) %>%
      summarize(cases = n_distinct(defendantId)
      ) %>%
      mutate(caseLabel = CLEAN_TEXT(cases),
             rateTotal = cases/sum(cases),
             rateLabel = PERCENT_OUTPUT(rateTotal),
             hoverText =
               STRING_BREAK(
                 paste0(rateLabel, ' of ',
                        tolower(scrTopCat), ' cases ',
                        ifelse(grepl('Disposed', arcOutcome),
                               paste('were', tolower(arcOutcome)),
                               tolower(arcOutcome)), ' in ', arcYear,
                        ' (', CLEAN_TEXT(caseLabel), ' cases).')
               ))

  })

  # . dl btn ####
  output$dlArcOut <- downloadHandler(

    filename = function() {
      "cases_arraign_by_arraign_outcome.csv"
    },
    content = function(file) {
      write.csv(tabArcOut(), file, row.names = FALSE)
    }

  )

  # . vert grp bar: arc outcome by cat ####
  output$pArcOutFel <- renderPlotly({

    d <- tabArcOut() %>%
      filter(scrTopCat=='Felony')
    
    VALIDATE(d)
    
    p <- ggplot(d,
        # p <- ggplot(test,
        aes(x = arcYear,
            y = rateTotal,
            group = scrTopCat,
            fill = arcOutcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent) +
      COL_SCALE_FILL_ARC_DISPO

    LAYOUT_GEN(p, x = 'Arraignment Year', y = 'Percentage of Felony Cases Arraigned',
               legend = 'Arraignment<br>Outcome')

  })


  output$pArcOutMisd <- renderPlotly({

    d <- tabArcOut() %>%
      filter(scrTopCat=='Misdemeanor')
    
    VALIDATE(d)
    
    p <- ggplot(d,
        # p <- ggplot(test,
        aes(x = arcYear,
            y = rateTotal,
            group = scrTopCat,
            fill = arcOutcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent) +
      COL_SCALE_FILL_ARC_DISPO

    LAYOUT_NO_LEG_TITLE(p, x = 'Arraignment Year', y = 'Percentage of Misdemeanor Cases Arraigned')

  })


  output$pArcOutViol <- renderPlotly({

    d <- tabArcOut() %>%
      filter(scrTopCat=='Violation/Infraction')
    
    VALIDATE(d)
    
    p <- ggplot(d,
        # p <- ggplot(test,
        aes(x = arcYear,
            y = rateTotal,
            group = scrTopCat,
            fill = arcOutcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent) +
      COL_SCALE_FILL_ARC_DISPO


    LAYOUT_GEN(p, x = 'Arraignment Year', y = 'Percentage of Violation/Infraction Cases Arraigned',
               legend = 'Arraignment<br>Outcome')

  })



  #  _____________________________________________
  #  Tab 2: Cases Continued                       ####


  ## cases continuing past arraignment ####

  # . table ####
  tabArcSurvive <- reactive({

    dt() %>%
      filter(arcSurvive == 1) %>%
      group_by(arcYear) %>%
      summarize(cases = n()) %>%
      mutate(caseLabel = CLEAN_TEXT(cases),
             hoverText =
               STRING_BREAK(
                 paste0(caseLabel, ' cases continued past arraignment in ',
                        arcYear, '.')))

  })

  # . dl btn ####
  output$dlArcSurvive <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign.csv"
    },
    content = function(file) {
      write.csv(tabArcSurvive(), file, row.names = FALSE)
    }

  )

  # . line: total cases continued past arraignment ####
  output$pArcSurvive <- renderPlotly({

    p <- ggplot(tabArcSurvive(),
                aes(x = arcYear,
                    y = cases,
                    group = 1,
                    text = hoverText)
    ) +
      THEME_LINE_DISCRETE

    LAYOUT_GEN(p, x = 'Arraignment Year', y = 'Cases Arraigned')

  })


  ### cases continuing past arraignment by major group ####

  # . table ####
  tabSurviveMg <- reactive({

    dt() %>%
      filter(arcSurvive == 1) %>%
      mutate(arcTopMg = gsub('/', ' or ', coalesce(arcTopMg, scrTopMg))) %>%
      group_by(arcTopMg) %>%
      summarize(cases = n_distinct(defendantId)) %>%
      ungroup() %>%
      mutate(arcTopMg = fct_rev(arcTopMg),
             caseLabel = CLEAN_TEXT(cases),
             rateLabel = PERCENT_OUTPUT(cases/sum(cases)),
             hoverText = paste0(caseLabel, ' cases continuing past arraignment were charged with ',
                                tolower(arcTopMg), ' (', rateLabel,').'),
             size = ifelse(nchar(as.character(arcTopMg))>=14,
                           ifelse(cases >=20000, cases/6, cases/8), cases/2) %>%
               ifelse(is.na(.), 0, .)
      )

  })

  # . dl btn ####
  output$dlSurviveMg <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_by_major_grp.csv"
    },
    content = function(file) {
      write.csv(tabSurviveMg() %>% select(-size), # remove size
                file, row.names = FALSE)
    }

  )

  # . bubble: cases contd by major group ####
  output$pSurviveMg <- renderGirafe({

    maxGroup <- max(tabSurviveMg()$cases)
    minVal <- maxGroup * .10

    packing <- circleProgressiveLayout(
      ifelse(tabSurviveMg()$cases < 10 & maxGroup > 1000,
             tabSurviveMg()$cases * 10,
             tabSurviveMg()$cases), sizetype = 'area')

    packing$radius <- 0.95 * packing$radius

    mg_data <- cbind(tabSurviveMg(), packing) %>%
      mutate(label = ifelse(cases < minVal |
                              nchar(as.character(arcTopMg)) > 20,
                            '',
                            gsub('[ ]', '\n', arcTopMg)))

    mg_gg <- circleLayoutVertices(packing, npoints = 50)
    mg_gg$cases <- rep(mg_data$cases, each = 51)

    p <-
      ggplot() +
      geom_polygon_interactive(data = mg_gg,
                               aes(x, y, group = as.factor(id), fill = cases,
                                   tooltip = tabSurviveMg()$hoverText[id],
                                   data_id = id),
                               colour = "white") +
      geom_text(data = mg_data, aes(x, y,
                                    label = label,
                                    size = size,
                                    family ='proxima',
      ), lineheight = .75) +
       THEME_BUBBLE()

    # Turn it interactive
    GIRAFE_BUBBLE(p)


  })

  ### most common charges ####

  # .table ####
  tabSurviveChg <- reactive({

    dt() %>%
      # arc_data %>%
      filter(arcSurvive == 1) %>%
      mutate(arcTopTxt2 =
               str_squish(gsub('(.*)(-)(.*)', '\\1', arcTopTxt))) %>%
      group_by(year = arcYear,
               arcTopCat,
               grp = arcTopTxt2) %>%
      summarize(cases = n_distinct(defendantId)) %>%
      group_by(year, cat = arcTopCat) %>%
      mutate(caseLabel = CLEAN_TEXT(cases),
             rank = rank(-cases, ties.method = 'first'),
             year = factor(year),
             hoverText = STRING_BREAK(paste0(caseLabel, ' ', tolower(cat),
                                             ' cases continuing past arraignment were charged with ',
                                             tolower(grp),' in ', year, '.'))) %>%
      filter(rank <= 5) %>%
      mutate(grp = STRING_BREAK(grp)) %>%
      ungroup() %>%
      arrange(year, cat, rank)

  })

  # . dl btn ####
  output$dlSurviveChg <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_by_chg.csv"
    },
    content = function(file) {
      write.csv(tabSurviveChg() %>% rename(arcYear = year,
                                           arcTopChg = grp),
                file, row.names = FALSE)
    }

  )

  # . hrzntl bar: most frq chgs by cat, yr####
  output$survChgFel13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2013)
  })

  output$survChgFel14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2014)
  })

  output$survChgFel15<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2015)
  })

  output$survChgFel16<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2016)
  })

  output$survChgFel17<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2017)
  })

  output$survChgFel18<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2018)
  })

  output$survChgFel19<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2019)
  })

  output$survChgFel20<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2020)
  })

  output$survChgFel21<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2021)
  })
  
  output$survChgFel22<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Felony', 2022)
  })

  output$survChgFel <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(tabSurviveChg, 'Felony')
  })

  output$survChgMisd13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2013)
  })

  output$survChgMisd14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2014)
  })

  output$survChgMisd15<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2015)
  })

  output$survChgMisd16<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2016)
  })

  output$survChgMisd17<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2017)
  })

  output$survChgMisd18<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2018)
  })

  output$survChgMisd19<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2019)
  })

  output$survChgMisd20<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2020)
  })

  output$survChgMisd21<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2021)
  })
  
  output$survChgMisd22<- renderPlotly({
    THEME_HORIZONTAL_BAR(tabSurviveChg, 'Misdemeanor', 2022)
  })

  output$survChgMisd <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(tabSurviveChg, 'Misdemeanor')
  })

  ### cases continuing past arraignment by release status ####

  # . table ####
  tabSurviveRelease <- reactive({

    dt() %>%
      # arc_data %>%
      filter(arcSurvive == 1) %>%
      group_by(arcYear, arcTopCat, releaseStatusCond) %>%
      summarize(cases = n_distinct(defendantId)) %>%
      group_by(arcYear, arcTopCat) %>%
      mutate(rateTotal = cases/sum(cases),
             rateLabel = PERCENT_OUTPUT(rateTotal),
             caseLabel = CLEAN_TEXT(cases),
             hoverText =
               STRING_BREAK(
                 paste0(rateLabel, ' of ', tolower(arcTopCat),
                        ' cases continuing past arraignment had a release status of ',
                        ifelse(releaseStatusCond %in%
                                 c('ROR', 'Supervised Release/Intensive Community Monitoring'),
                               releaseStatusCond, tolower(releaseStatusCond)),
                        ' in ', arcYear, ' (', caseLabel, ' cases).')))

  })

  # . dl btn ####
  output$dlSurviveRelease <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_by_release_status.csv"
    },
    content = function(file) {
      write.csv(tabSurviveRelease(), file, row.names = FALSE)
    }

  )

  # . vert stack bar: rel stat by cat, yr ####
  output$pSurviveReleaseFel <- renderPlotly({

    p <- tabSurviveRelease() %>%
      filter(arcTopCat=='Felony') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = releaseStatusCond,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent)

    LAYOUT_GEN(p, x = "Arraignment Year",
               y = "Percentage of Felony Cases Continuing Past Arraignment",
               legend = "Release<br>Status",
               legend_y = 1.4)

  })

  output$pSurviveReleaseMisd <- renderPlotly({

    p <- tabSurviveRelease() %>%
      filter(arcTopCat=='Misdemeanor') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = releaseStatusCond,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent)

    LAYOUT_NO_LEG_TITLE(
      p, x = "Arraignment Year",
      y = "Percentage of Misdemeanor Cases Continuing Past Arraignment",
      legend_y = 1.4)

  })

  output$pSurviveReleaseViol <- renderPlotly({

    p <- tabSurviveRelease() %>%
      filter(arcTopCat=='Violation/Infraction') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = releaseStatusCond,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = COLORS_NO_BLACK) +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED(percent)

    LAYOUT_GEN(p, x = "Arraignment Year",
               y = "Percentage of Violation/Infraction Cases Continuing Past Arraignment",
               legend = "Release<br>Status",
               legend_y = 1.4)

  })


  #### bail for cases continuing past arraignment ####

  # . table: no $1D bail set ####
  tabSurviveBail <- reactive({

    dt() %>%
      # arc_data %>%
      filter(arcSurvive == 1, dollarBail == 0) %>% # no dollar bail set
      group_by(arcYear) %>%
      summarize('Bail Requested' = n_distinct(defendantId[bailReq == 1]),
                'Bail Set' = n_distinct(defendantId[bailSet == 1]))

  })

  # . dl btn ####
  output$dlSurviveBail <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_bail.csv"
    },
    content = function(file) {
      write.csv(tabSurviveBail(), file, row.names = FALSE)
    }

  )

  # . box: bail set ####
  output$boxBailSet <- renderValueBox({

    d <- tabSurviveBail() %>%
      select(`Bail Set`) %>%
      sum() %>%
      format(big.mark = ",")

    valueBox(d, "Cases with bail set")

  })

  # . box: bail requested ####
  output$boxBailReq <- renderValueBox({

    d <- tabSurviveBail() %>%
      select(`Bail Requested`) %>%
      sum() %>%
      format(big.mark = ",")

    valueBox(d, "Cases with bail requested")

  })

  # . line: bail set/requested for cases continuing past arraignment ####
  output$pSurviveBail <- renderPlotly({

    p <- tabSurviveBail() %>%
      gather('Metric', 'cases', -arcYear) %>%
      mutate(caseLabel = CLEAN_TEXT(cases),
             hoverText = STRING_BREAK(paste0(caseLabel,
                                             ' cases continuing past arraignment had ',
                                             tolower(Metric), ' in ', arcYear, '.'))) %>%
      ggplot(aes(x = arcYear,y = cases, group = Metric, color = Metric,
                 shape = Metric, text = hoverText)
      ) +
      THEME_LINE_DISCRETE +
      COL_SCALE_BAIL_RS

    LAYOUT_GEN(p, x = 'Arraignment Year',
               y = 'Cases Continuing Past Arraignment', legend = 'Metric')

  })


  ### bail requested vs bail set for cases continuing past arraignment ####

  # . table ####
  tabBailReqVsSet <- reactive({

    merge(
      dt() %>%
        # arc_data %>%
        filter(arcSurvive == 1, dollarBail == 0) %>%
        group_by(arcYear, arcTopCat, bailReq, bailSet) %>%
        summarize(cases = n()) %>%
        ungroup(),
      dt() %>%
        # arc_data %>%
        filter(arcSurvive == 1, dollarBail == 0) %>%
        group_by(arcYear, arcTopCat) %>%
        summarize(totalCases = n()),
      by = c('arcYear', 'arcTopCat')
    ) %>%
      mutate(rateTotal = cases/totalCases,
             outcome =
               case_when(bailReq == 0 & bailSet == 0 ~
                           'No bail requested, no bail set',
                         bailReq == 0 & bailSet == 1 ~
                           'No bail requested, bail set',
                         bailReq == 1 & bailSet == 1 ~
                           'Bail requested, bail set',
                         bailReq == 1 & bailSet == 0 ~
                           'Bail requested, no bail set',
                         TRUE ~ 'Unknown') %>%
               as.factor() %>% fct_relevel('No bail requested, bail set',
                                           'Bail requested, bail set',
                                           'No bail requested, no bail set',
                                           'Bail requested, no bail set'),
             outcomeText = tolower(outcome),
             rateLabel = PERCENT_OUTPUT(rateTotal),
             caseLabel = CLEAN_TEXT(cases),
             hoverText =
               STRING_BREAK(
                 paste0(rateLabel,' of ',
                        tolower(arcTopCat),
                        ' cases continuing past arraignment had ',
                        outcomeText, ' in ', arcYear,  ' (', caseLabel, ' cases).')))

  })

  # . dl btn ####
  output$dlBailReqVsSet <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_bail_req_vs_set.csv"
    },
    content = function(file) {
      write.csv(tabBailReqVsSet(), file, row.names = FALSE)
    }

  )

  # . vert stack bar: bail set vs bail request ####
  output$pBailReqVsSetFel <- renderPlotly({

    p <- tabBailReqVsSet() %>%
      filter(arcTopCat=='Felony') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = outcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      COL_SCALE_FILL_4 +
      #  facet_wrap(vars(arcTopCat), ncol = 2, scales = 'free')+
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      theme(panel.spacing = unit(1, "lines")) +
      THEME_VERT_BAR_STACKED(labelType = percent)

    LAYOUT_GEN(p, x = 'Arraignment Year',
               y = 'Percentage of Felony Cases Continuing Past Arraignment',
               legend = 'Metric', legend_y = 1.30)

  })


  output$pBailReqVsSetMisd <- renderPlotly({

    p <- tabBailReqVsSet() %>%
      filter(arcTopCat=='Misdemeanor') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = outcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      COL_SCALE_FILL_4 +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      theme(panel.spacing = unit(1, "lines")) +
      THEME_VERT_BAR_STACKED(labelType = percent)

    LAYOUT_NO_LEG_TITLE(
      p, x = 'Arraignment Year',
      y = 'Percentage of Misdemeanor Cases Continuing Past Arraignment',
      legend_y = 1.30)

  })

  output$pBailReqVsSetViol <- renderPlotly({

    p <- tabBailReqVsSet() %>%
      filter(arcTopCat=='Violation/Infraction') %>%
      ggplot(
        aes(x = arcYear,
            y = rateTotal,
            fill = outcome,
            text = hoverText)
      ) +
      geom_bar(stat = "identity", position = "stack") +
      COL_SCALE_FILL_4 +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      theme(panel.spacing = unit(1, "lines")) +
      THEME_VERT_BAR_STACKED(labelType = percent)

    LAYOUT_GEN(p, x = 'Arraignment Year',
               y = 'Percentage of Violation/Infraction Cases Continuing Past Arraignment',
               legend = 'Metric', legend_y = 1.30)
  })

  ### median bail ####

  # . table ####
  tabMedianBail <- reactive({

    # tabMedianBail <-
    # bail request amount
    bind_rows(
      dt() %>%
        # arc_data %>%
        filter(arcSurvive == 1, dollarBail == 0, bailReqAmt > 1) %>%
        group_by(arcYear, arcTopCat) %>%
        summarise(MedAmt = median(bailReqAmt)) %>%
        mutate('Metric' = 'Median bail requested',
               MedAmt2 = dollar(MedAmt),
               hoverText =
                 STRING_BREAK(
                   paste0(MedAmt2, ' was the median bail requested for ',
                          tolower(arcTopCat), ' cases continuing past arraignment in ',
                          arcYear,'.'))) %>%
        rename('Alleged Offense' = arcTopCat),
      # bail set amount
      dt() %>%
        # arc_data %>%
        filter(arcSurvive == 1, dollarBail == 0, bailSetAmt > 1) %>%
        group_by(arcYear, arcTopCat) %>%
        summarise(MedAmt = median(bailSetAmt)) %>%
        mutate('Metric' = 'Median bail set',
               MedAmt2 = dollar(MedAmt),
               hoverText =
                 STRING_BREAK(
                   paste0(MedAmt2, ' was the median bail set for ',
                          tolower(arcTopCat),
                          ' cases continuing past arraignment in ', arcYear, '.'))) %>%
        rename('Alleged Offense' = arcTopCat)
    ) %>%
      mutate(
        MedAmt3 = ifelse(
          MedAmt < 1000, f_denom(MedAmt, relative = 1),
          case_when(
            MedAmt%%1000 == 0 ~ f_denom(MedAmt, relative = 0),
            MedAmt%%100 == 0 ~ f_denom(MedAmt, relative = 1),
            MedAmt%%10 == 0 ~ f_denom(MedAmt, relative = 2),
            TRUE ~ NA_character_))) %>%
      arrange(`Alleged Offense`, Metric) %>%
      filter(`Alleged Offense` != 'Unknown')

  })

  # . dl btn ####
  output$dlMedianBail <- downloadHandler(

    filename = function() {
      "cases_contd_past_arraign_median_bail.csv"
    },
    content = function(file) {
      write.csv(tabMedianBail(), file, row.names = FALSE)
    }

  )

  # . vert grp bar: median bail by category ####
  output$pMedianBailFel <- renderPlotly({

    p <- tabMedianBail() %>%
      filter(`Alleged Offense`=='Felony') %>%
      ggplot(
        aes(x = arcYear,
            y = MedAmt,
            fill = Metric,
            text = hoverText)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(y = MedAmt + 300, label = MedAmt3),
                position = position_dodge(width = 1),
                size = 3.5) +
      THEME_VERT_BAR_STACKED(labelType = dollar) +
      COL_SCALE_FILL_2

    LAYOUT_GEN(p, x = 'Arraignment Year',
               y = "Median Amount in Dollars",
               legend = 'Metric')
  })


  output$pMedianBailMisd <- renderPlotly({

    p <- tabMedianBail() %>%
      filter(`Alleged Offense`=='Misdemeanor') %>%
      ggplot(
        aes(x = arcYear,
            y = MedAmt,
            fill = Metric,
            text = hoverText)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(y = MedAmt + 50, label = MedAmt3),
                position = position_dodge(width = 1),
                size = 3.5) +
      THEME_VERT_BAR_STACKED(labelType = dollar) +
      COL_SCALE_FILL_2

    LAYOUT_NO_LEG_TITLE(p, x = 'Arraignment Year',
                        y = "Median Amount in Dollars")
  })


  output$pMedianBailViol <- renderPlotly({

    p <- tabMedianBail() %>%
      # tabMedianBail %>%
      filter(`Alleged Offense`=='Violation/Infraction') %>%
      ggplot(
        aes(x = arcYear,
            y = MedAmt,
            fill = Metric,
            text = hoverText)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(y = MedAmt + 20, label = MedAmt3),
                position = position_dodge(width = 1),
                size = 3.5) +
      THEME_VERT_BAR_STACKED (labelType = dollar) +
      COL_SCALE_FILL_2

    LAYOUT_GEN(p, x = 'Arraignment Year',
               y = "Median Amount in Dollars",
               legend = 'Metric')
  })

  ### dollar bail ####

  # . box ####
  output$boxDollarBail <- renderValueBox({

    d <- dt() %>%
      filter(arcSurvive == 1, dollarBail == 1) %>%
      summarize(N = n()) %>%
      format(big.mark = ",")

    valueBox(d, "Cases with dollar bail set")
  })
               }
  )
}


