contactPanel <- tabPanel(
  title = CONTACT_PAGE_TITLE, 
  value = CONTACT_PAGE_ID,
  fluidRow(class = "page-intro-row",
           column(width = 6,
                  class = "page-intro-text",
                  h3(toupper(CONTACT_PAGE_TITLE)),
                  h4(class = "regular", 
                     HTML("<br/>")   
                  )
           ),
           pageIntroIconUI(id = 'contact_intro', pageName = CONTACT_PAGE_TITLE)
  ),
  fluidRow(
    class = "main-row",
    br(),
    column(width = 6, offset = 3,
           HTML(
             "<p>If you have questions or feedback about the Manhattan D.A.'s Data Dashboard, please email us at datadashboard@dany.nyc.gov.<br/><br/>
      The Freedom of Information Law (\"FOIL\") pertains to the public's right to request government records. All requests made to the Manhattan D.A.'s Office pursuant to FOIL must be submitted in writing to the Records Access Officer via email (FOIL@dany.nyc.gov), fax (212-335-4390), or mail:<br/><br/>
      Special Litigation Bureau, New York County District Attorney's Office<br/>
      One Hogan Place, New York, NY 10013
      <br/><br/>
      For more information about how to contact the Manhattan D.A.'s Office, please visit our <a href='https://www.manhattanda.org/contact-us/'>website</a>.<p>"
           )
    )
  )
)