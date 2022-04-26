source('resources/data_methodology/text_data_methodology.R')

dataMethodologyPanel <- tabPanel(
  title = METHODOLOGY_PAGE_TITLE,
  value = METHODOLOGY_PAGE_ID,
  fluidRow(class = "page-intro-row",
           column(width = 6,
                  class = "page-intro-text",
                  h3(toupper(METHODOLOGY_PAGE_TITLE)),
                  h4(class = "regular", "")
           ),
           pageIntroIconUI(id = 'methodology_intro', pageName = METHODOLOGY_PAGE_TITLE)
  ),
  fluidRow(
    class = "main-row",
    br(),
    column(width = 6, offset = 3,
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataIntroText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataCollectText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataCleanText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataLocationText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataUpdateText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(dataLimitText)
    )
  )
)