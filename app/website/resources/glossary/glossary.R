# Glossary page (tabPanel)

glossaryPanel <- tabPanel(
  title = GLOSSARY_PAGE_TITLE,
  value = GLOSSARY_PAGE_ID,
  # page intro
  fluidRow(class = "page-intro-row",
           HTML("<a name='glossary_top'></a>"),
           column(width = 6,
                  class = "page-intro-text",
                  h3(toupper(GLOSSARY_PAGE_TITLE)),
                  h4(class = "regular", 
                     "This page provides definitions of key terms and legal phrases that are commonly used throughout this site."
                  )
           ),
           pageIntroIconUI(id = 'glossary_intro', pageName = GLOSSARY_PAGE_TITLE)
  ),
  # page body
  fluidRow(
    class = "main-row",
    br(),
    column(width = 6, offset = 3,
           div(class = "glossary-tab-text",
               includeHTML('resources/glossary/tab_glossary.html')
           ),
           div(class = "glossary-text",
               includeHTML('resources/glossary/text_glossary.html')
           )
    ),
  )
)