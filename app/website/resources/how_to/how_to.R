source('resources/how_to/text_how_to.R')

howToPanel <- tabPanel(
  title = HOW_TO_PAGE_TITLE,
  value = HOW_TO_PAGE_ID,
  fluidRow(class = "page-intro-row",
           column(width = 6,
                  class = "page-intro-text",
                  h3(toupper(HOW_TO_PAGE_TITLE)),
                  h4(class = "regular", "")
           ),
           pageIntroIconUI(id = 'how_to_intro', pageName = HOW_TO_PAGE_TITLE)
  ),
  fluidRow(
    class = "main-row",
    br(),
    column(width = 6, offset = 3,
           HTML(howToIntro),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(howToDashText),
           img(src = 'images/normal_line_u3766.svg', width = "100%"),
           HTML(howToResourceText)
    )
  )
)