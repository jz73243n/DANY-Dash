howToIntro <- "<p>This website aims to provide the public with accessible and comprehensive data on the Manhattan D.A.'s prosecutorial activities, with the goal of increasing transparency about the Office's operations. <br/> <br/>From the website homepage, you can access a series of data \"dashboards\". The dashboards are intended to help you easily access a broad spectrum of aggregated data in one place. Each dashboard highlights a major event in the prosecution of a case. </p>"

howToDashText <-
"
<h3 class='red'>
    Analyze Data (Dashboards dropdown)
</h3>
<img class='how-to-img' src='images/how_to/dashboard_dropdown.png' />
<p>
    The dashboards include:
</p>
<ul>
    <li>
        Arrests
    </li>
    <li>
        Arraignments
    </li>
    <li>
        Dispositions
    </li>
    <li>
        Sentences
    </li>
    <li>
        Cohorts by Race/Ethnicity
    </li>
</ul>
<p>
    Each dashboard includes:
</p>
<ul>
    <li>
        <u>Major Event Narrative:</u>
        A description of each major event. <u></u>
    </li>
    <li>
        <u>Subgroups</u>
: Several subtopics relating to the major event. Each subgroup has:
<img class='how-to-img' src='images/how_to/tab.png'/>
    </li>
    <li>
        <u>Each subgroup has: </u>
    </li>
    <ul>
      <li>
            <u>Filters:</u> By selecting filters, users can highlight the specific
            cases they would like to see in the current subgroup. 
<img class='how-to-img' src='images/how_to/filters.png'/>
             Filters include:
      </li>
      <ul>
        <li>
              <u>Major Event:</u> These are specific to the current mini
              dashboard. Examples include arrest type (DAT vs. an online arrest), offense
              category (felony, misdemeanor, violation/ infraction), and release status
              (e.g., bail set vs. Released on Recognizance).
        </li>
        <li>
              <u>Demographics:</u> These include race/ethnicity, age at the time of
              alleged offense, and gender of the arrested or charged individual, as
              reported by the NYPD. It is important to note that the NYPD records an
              individual's gender and race/ethnicity based on how they physically appear,
              not by self-identification.
        </li>
        <li>
              <u>Prior Manhattan Convictions:</u> These are based on the arrested or
              charged individual's prior convictions in Manhattan. A prior conviction is
              any case that resulted in a guilty plea or trial conviction before the
              current arrest.
        </li>
      </ul>
      <li>
            <u>Graphs:</u> Interactive graphs display trends over time and include
            summaries communicating case information at each major event. Applying
            filters will change the data you see in each graph.
<img class='how-to-img' src='images/how_to/line.png'/>
            Below are descriptions of graphs you may be less familiar with.
      </li>
      <ul>
        <li>
              Treemap graphs represent each category by a rectangle area proportional
              to its value. For example, the treemap below shows that roughly 82% of
              individuals arrested are male.
<img class='how-to-img' src='images/how_to/treemap.png'/>
        </li>
        <li>
              Bubble charts break down a population of cases into subgroups. Each
              bubble represents a subgroup and the size of the bubble reflects the
              relative size of that subgroup. For example, the bubble chart below
              provides information about arrests the Manhattan D.A.'s Office declined to
              prosecute. Each bubble represents a decline to prosecute reason and the
              largest bubble, \"Cannot Prove Element of a Crime,\" represents the most
              common reason.
<img class='how-to-img' src='images/how_to/bubble.png'/>
        </li>
      </ul>
<li>
    <u>Dynamic Value Boxes:</u>
</li>
<ul>
  <li>
        Dynamic counts change as filters are applied. These are meant to show how
        many cases are in the underlying, filtered data cohort.<u></u>
<img class='how-to-img' src='images/how_to/dynamic_boxes.png'/>
  </li>
</ul>
<li>
    <u>Downloadable Graphs:</u> Users can download the data and a png (image) 
      of each graph (except for bubble charts). Please note that the text in the 
      downloaded data may include the following symbol: \"< br >\". 
      This indicates that there was a line break in the text on the website. 
<img class='how-to-img' src='images/how_to/download_data.png'/>
</li>
      
    </ul>
</ul>
"

howToResourceText <- paste0(
"<h3 class='red'>
    Learn More (Resources dropdown)
</h3>
<img class='how-to-img' src='images/how_to/resource_dropdown.png'/>
<p>
    The Resource pages provide additional information on the prosecutorial
    process in Manhattan, and how the Manhattan D.A.'s Office collects,
    processes, and presents case-specific data.
</p>
<ul>
    <li>",
as.character(actionLink(inputId = 'how_to_link_pros_proc', 
label = 'Prosecution Process:')),
" Provides an overview of the arrest to sentencing process, and answers
        common questions surrounding case processing.
    </li>
    <li>",
as.character(actionLink(inputId = 'how_to_link_glossary', 
label = 'Glossary of Key Terms:')),
" Defines key terms and legal phrases that are commonly used throughout
        this site.
    </li>
    <li>",
as.character(actionLink(inputId = 'how_to_link_data_methodology', 
label = 'Data and Methodology:')),
" Summarizes how the data was collected, processed, and presented, along
        with data limitations.
    </li>
</ul>")