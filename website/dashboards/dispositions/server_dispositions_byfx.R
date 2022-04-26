library(shiny); library(tidyverse); library(plotly); library(gt)
library(scales); library(packcircles); library(ggplot2); library(viridis)
library(ggiraph)

# setwd('~/dany_dashboard/app/website/')

dispositionServer <- function(input, output, session) {
  
  
  dispos <- reactive({
    
    dispo_data %>% 
      filter(instTopCat %in% input$category,
             race %in% input$race,
             gender %in% input$gender,
             dispoType %in% input$dispoType,
             dispoYear %in% input$dispoYear,
             ageAtOffGrp %in% input$age,
             arrestLocation %in% input$pct,
             priorFelConvGrp %in% input$priorFelConv,
             priorMisdConvGrp %in% input$priorMisdConv,
             yrSinceLastConvGrp %in% input$yrSinceConv
      )
    
  })
  
  
  #  _____________________________________________
  #  Tab 1: Cases Disposed                        ####
  
  # . line: total cases disposed ####
  output$plot0 <- renderPlotly({
    
    dTable0 <- 
        baseByYear(dispos(), dispoYear) %>% 
          arrange(year)
    
    dPlot0 <- dTable0 %>% 
      ggplot(aes(x = year, 
                 y = cases,
                 group = 1,
                 text = paste0('In ', year, ', ', caseLabel, 
                               ' cases were disposed.'))
      ) + 
      geom_point() +
      geom_line() 
    
    dPlot0 <- THEME_LINE_DISCRETE(dPlot0)
    
    LAYOUT_GEN(dPlot0, x = 'Disposition Year', y = 'Cases Disposed')
    
  })
  
  
  # . tab: dTable2 ####
  dTable2 <- reactive({
     
    baseByYearGrp(dispos(), dispoYear, dispoType) %>% 
      arrange(year, group)
    
  })
  
  # . line: d by d type ####
  output$plot2 <- renderPlotly({
    
    dPlot2 <- dTable2() %>%
      # dPlot2 <- dTable2 %>%
      ggplot(aes(x = year, 
                 y = cases, 
                 group = group,
                 color = group,
                 shape = group,
                 text = paste0('In ', year, ', ', caseLabel, 
                               ' cases were disposed by ', 
                               tolower(group),'.'))
      )  + 
      geom_point() +
      geom_line()
    
    dPlot2 <- THEME_LINE_DISCRETE(dPlot2) + COL_SCALE_DSP_TYPE
    
    LAYOUT_GEN(dPlot2, x = 'Disposition Year', y = 'Cases Disposed', 
                legend = 'Disposition Type')
    
  })
  
  # . vert stack bar: pct d by d type ####
  output$plot2.2 <- renderPlotly({    
    
    dPlot2.2 <- dTable2() %>%
      # dPlot2.2 <- dTable2 %>%
      ggplot(aes(x = year, 
                 y = rate, 
                 fill = group,
                 text = paste0(rateLabel,' of cases disposed in ', year, 
                               'resulted in a(n) ', tolower(group)))
      ) + 
      geom_bar(stat = 'identity', position = 'stack') +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED() +
      scale_y_continuous(label = percent)
    
    dPlot2.2 <- dPlot2.2 + COL_SCALE_DSP_TYPE
    
    LAYOUT_NO_LEG_TITLE(dPlot2.2, x = 'Disposition Year', y = 'Percentage of Cases Disposed')
    
  })
  
  
  # . tab: t3 ####
  dTable3 <- reactive({
    
    baseByYearCatGrp(dispos(), dispoYear, instTopCat, dispoType) %>% 
      mutate(hoverText1 = paste0('In ', year, ', ', caseLabel, 
                                 ' cases were disposed by ', 
                                 tolower(group),'.'),
            hoverText2 = paste0(rateLabel, ' of ', tolower(category), 
                                 ' cases <br> disposed in ', year,
                                 ' resulted in a(n) ', tolower(group))) %>% 
      arrange(year, category, group) 
    
  })
  
  # . line: d by d type, cat facet stack ####
  output$plot3 <- renderPlotly({  
    
    dPlot3 <- dTable3() %>% 
      #dPlot3 <- dTable3 %>%
      ggplot(aes(x = year, 
                 y = cases,
                 group = group,
                 color = group,
                 shape = group,
                 text = hoverText1)
      ) + 
      geom_point() +
      geom_line()
    
    dPlot3 <- THEME_LINE_DISCRETE(dPlot3) + 
      facet_grid(rows = vars(paste(category, 'Case')),
                 scales = "free") + 
      COL_SCALE_DSP_TYPE
    
    LAYOUT_GEN(dPlot3, x = 'Disposition Year', 
                y = 'Cases Disposed', legend = 'Disposition Type')
  })
  
  # . vert stack bar: d by type, cat facet stack ####
  output$plot3.2 <- renderPlotly({  
    
    dPlot3.2 <- dTable3() %>%
      # dPlot3.2 <- dTable3 %>%
      ggplot(aes(x = year, 
                 y = rate, 
                 fill = group,
                 text = hoverText2)
      ) + 
      geom_bar(stat = 'identity', position = 'stack') +
      facet_grid(rows = vars(category), 
                 scales = "free") + 
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      scale_y_continuous(label = percent) +
      THEME_VERT_BAR_STACKED()
    
    dPlot3.2 <- dPlot3.2 + COL_SCALE_DSP_TYPE
    
    LAYOUT_NO_LEG_TITLE(dPlot3.2, x = 'Disposition Year', y = 'Percentage of Cases Disposed')
    
  })
  
  
  # . tab: dTable4 ####
  dTable4 <- reactive({
    
    baseByYearCatGrp(dispos() %>% 
                       filter(isPleaConvict ==1,
                              !is.na(dispoTypeDetail),
                              ifelse(instTopCat=='Violation/Infraction' 
                                     & !grepl('Violation/Infraction', 
                                              dispoTypeDetail), 0,1)==1),
                     dispoYear, instTopCat, dispoTypeDetail) %>%
      mutate(hoverText = paste0('In ', year, ', ', caseLabel, ' ', 
                                tolower(category), ' cases were disposed by ', 
                                tolower(group),'.')) %>% 
      arrange(year, category, group)
    
  })
  
  # Pleas/Trial Convictions by Alleged Offense
  # . line: d detail cvct v plea, cat facet ####
  output$plot4 <- renderPlotly({
    
    dPlot4 <- dTable4() %>% 
      #dTable4 %>%
      ggplot(aes(x = year, 
                 y = cases, 
                 color = group,
                 group = group,
                 shape = group,
                 text = hoverText)
      ) + 
      geom_point() +
      geom_line() 
    
    dPlot4 <- THEME_LINE_DISCRETE(dPlot4) + 
      facet_grid(rows = vars(paste(category, 'Case')),
                 scales = "free")+ 
      COL_SCALE_DSP_CAT
    
    LAYOUT_GEN(dPlot4, x = 'Disposition Year', 
                y = 'Cases Convicted', legend = 'Outcome')
  })
  
  # . tab: dTable5 charge changes ####
  dTable5 <- reactive({
    
    baseByYearCatGrp(dispos() %>% 
                       filter(isPleaConvict==1,
                              instTopCat!='Violation/Infraction'),
                     dispoYear, instTopCat, chargeChangeDetail) %>% 
     mutate(hoverText1 = ifelse(grepl(' to ', group), 
                               paste0('In ', year, ', ', caseLabel, ' ', 
                                      tolower(category),
                                      ' cases were convicted<br>and the charge ', 
                                      tolower(group),'.'),
                               paste0('In ', year, ', ', caseLabel, ' ', 
                                      tolower(category), 
                                      ' cases were convicted of a ', 
                                      tolower(group),'.')),
            hoverText2 = ifelse(grepl(' to ', group), 
                                paste0('In ', year, ', ', rateLabel, ' of ',
                                       tolower(category), 
                                       ' cases convicted<br>were ', 
                                       tolower(group)),
                                paste0('In ', year, ', ', rateLabel, ' of ',
                                       tolower(category), 
                                       ' cases convicted<br>were to a(n) ', 
                                       tolower(group))
                                )
            ) %>% 
      arrange(year, category, group)

    
  })
  
  # . line: chg change fel ####
  output$plotFel5 <- renderPlotly({
    
    dPlotFel5 <- dTable5() %>% 
      #dTable5 %>%
      filter(category=='Felony') %>% 
      ggplot(aes(x = year, 
                 y = cases, 
                 group = group,
                 color = group,
                 shape = group,
                 text = hoverText1
                  )
      ) + 
      geom_point() +
      geom_line() 
    
    dPlotFel5 <- THEME_LINE_DISCRETE(dPlotFel5) +  
      COL_SCALE_CHG_CHNG
    
    LAYOUT_GEN(dPlotFel5, x = 'Disposition Year', 
                y = 'Cases Convicted', legend = 'Charge<br>Changes')
  })
  
  # Charge changes: Felony, percent
  # . vert bar: chg change pct, felony ####
  output$plotFel5.2 <- renderPlotly({
    
    dPlotFel5.2 <- dTable5() %>%
      # dPlotFel5.2 <- dispo_data %>%
      filter(category=='Felony') %>% 
      ggplot(aes(x = year, 
                 y = rate,
                 fill = group,
                 text = hoverText2
                   )
      ) + 
      geom_bar(stat = 'identity', position = 'stack') +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED() +
      scale_y_continuous(label = percent)
    
    dPlotFel5.2 <- dPlotFel5.2 + COL_SCALE_CHG_CHNG
    
    LAYOUT_NO_LEG_TITLE(dPlotFel5.2, x = 'Disposition Year', 
                            y = 'Percentage of Cases Convicted')
    
  })
  
  
  # . line: chg change msds ####
  output$plotMisd5 <- renderPlotly({
    
    dPlotMisd5 <- dTable5() %>% 
      #dTable5 %>%
      filter(category=='Misdemeanor') %>% 
      ggplot(aes(x = year, 
                 y = cases, 
                 group = group,
                 color = group,
                 shape = group,
                 text = hoverText1
      )
      ) + 
      geom_point() +
      geom_line() 
    
    dPlotMisd5 <- THEME_LINE_DISCRETE(dPlotMisd5) +  
      COL_SCALE_CHG_CHNG
    
    LAYOUT_GEN(dPlotMisd5, x = 'Disposition Year', 
                y = 'Cases Convicted', legend = 'Charge<br>Changes')
    
  })
  
  
  # Charge changes: Misdemeanor, Percent
  # . vert bar: chg change pct, msd ####
  output$plotMisd5.2 <- renderPlotly({
    
    dPlotMisd5.2 <- dTable5() %>% 
      #dTable5 %>%
      filter(category=='Misdemeanor') %>% 
      ggplot(aes(x = year, 
                 y = rate,
                 fill = group,
                 text = hoverText2
      )
      ) + 
      geom_bar(stat = 'identity', position = 'stack') +
      MOD_GEOM_TEXT(minRate = MIN_RATE_10) +
      THEME_VERT_BAR_STACKED() +
      scale_y_continuous(label = percent)
    
    dPlotMisd5.2 <- dPlotMisd5.2 + COL_SCALE_CHG_CHNG
    
    LAYOUT_NO_LEG_TITLE(dPlotMisd5.2, x = 'Disposition Year',
                            y = 'Percentage of Cases Convicted')
    
    
  })
  
  #  _____________________________________________
  #  Tab 2: Disposition Charges                   ####
  
  # Major Group
  # . bubble: d by major group ####
  output$plot6 <- renderGirafe({
    
    dTable6 <-  baseByGrp(dispos() %>% 
                      filter(isPleaConvict==1), dispoTopMg) %>% 
                mutate(hoverText = paste0(caseLabel, ' cases were convicted on a top charge of ',
                                          tolower(group), ' (', rateLabel,').'))
    
    mgPacking <- circleProgressiveLayout(dTable6$cases, sizetype='area')
    mgPacking$radius <- 0.95*mgPacking$radius
    mgPackData <- cbind(dTable6, mgPacking)
    mgPack.gg <- circleLayoutVertices(mgPacking, npoints=50)
    
    # Make the plot with a few differences compared to the static version:
    dPlot6 <- ggplot() +
      geom_polygon_interactive(data = mgPack.gg, aes(x, y, group = id, 
                                                     fill=id, 
                                                     tooltip = dTable6$hoverText[id], 
                                                     data_id = id), 
                               colour = "white") +
      scale_fill_viridis() +
      geom_text(data = mgPackData, 
                aes(x, y, label = gsub('[ ]', '\n', group),
                size = cases,
                family='proxima'
                )) +
      theme_void() +
      theme(legend.position="none", plot.margin=unit(c(0,0,0,0),"cm") ) +
      coord_equal()
    
    # Turn it interactive
    ggiraph(ggobj = dPlot6)
    
  })
  
  # . tab: dTable7 frq conviction chgs ####
  dTable7 <- reactive({
    
   chargeRank(dispos() %>% 
                filter(dispoType=='Conviction'), dispoYear, instTopCat, paste0(dispoTopCat, ' ', dispoTopTxt)) %>% 
      mutate(hoverText = paste0('In ', year, ', ', caseLabel, ' ', tolower(category), 
                                ' cases were convicted<br>to a ', tolower(group), 
                                '.')) 
  })
  
  # . hrzntl bar: frq fel cvct chgs by yr ####
  output$convChgFel13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2013)
  })
  
  output$convChgFel14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2014)
  })
  
  output$convChgFel15<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2015)
  })
  
  output$convChgFel16<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2016)
  })
  
  output$convChgFel17<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2017)
  })
  
  output$convChgFel18<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2018)
  })
  
  output$convChgFel19<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2019)
  })
  
  output$convChgFel20<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Felony', 2020)
  })
  
  output$convChgFel <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(dTable7, 'Felony')
  })
  
  #  . hrzntl bar: frq msd cvct chgs by yr ####
  output$convChgMisd13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2013)
  })
  
  output$convChgMisd14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2014)
  })
  
  output$convChgMisd15<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2015)
  })
  
  output$convChgMisd16<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2016)
  })
  
  output$convChgMisd17<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2017)
  })
  
  output$convChgMisd18<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2018)
  })
  
  output$convChgMisd19<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2019)
  })
  
  output$convChgMisd20<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable7, 'Misdemeanor', 2020)
  })
  
  output$convChgMisd <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(dTable7, 'Misdemeanor')
  })
  
  
  # . tab: dTable8 frq acd chgs####
  dTable8 <- reactive({
    
    chargeRank(data = dispos() %>% 
                        filter(dispoType=='ACD'), 
               year = dispoYear, 
               category = instTopCat, 
               group = paste0(dispoTopCat, ' ', dispoTopTxt)) %>% 
    mutate(hoverText = paste0('In ', year, ', ', caseLabel, ' ', tolower(category), 
                              ' cases charged with<br>', tolower(group), 
                              '<br>received an ACD')) 
    
  })
  
  
  # . hrzntl bar: msd acds ####
  output$acdChgMisd13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2013)
  })
  
  output$acdChgMisd14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2014)
  })
  
  output$acdChgMisd15<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2015)
  })
  
  output$acdChgMisd16<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2016)
  })
  
  output$acdChgMisd17<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2017)
  })
  
  output$acdChgMisd18<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2018)
  })
  
  output$acdChgMisd19<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2019)
  })
  
  output$acdChgMisd20<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Misdemeanor', 2020)
  })
  
  output$acdChgMisd <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(dTable8, 'Misdemeanor')
  })
  
  # . hrzntl bar: violation acds ####
  output$acdChgVio13 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2013)
  })
  
  output$acdChgVio14 <- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2014)
  })
  
  output$acdChgVio15<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2015)
  })
  
  output$acdChgVio16<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2016)
  })
  
  output$acdChgVio17<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2017)
  })
  
  output$acdChgVio18<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2018)
  })
  
  output$acdChgVio19<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2019)
  })
  
  output$acdChgVio20<- renderPlotly({
    THEME_HORIZONTAL_BAR(dTable8, 'Violation/Infraction', 2020)
  })
  
  output$acdChgVio <- renderPlotly({
    THEME_HORIZONTAL_BAR_FACET(dTable8, 'Violation/Infraction')
  })
  
}


