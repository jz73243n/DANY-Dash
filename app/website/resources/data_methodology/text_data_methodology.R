dataIntroText <- "
<h3 class='red'>
    Introduction
</h3>
<p>
    Since the late 1970s, the Manhattan D.A.'s Office has collected and stored
    information about each case that comes through Manhattan's criminal courts.
    A court part specialist records data on the time and date of each event
    from arrest to sentencing, including the names of the presiding judge and
    the assigned Assistant D.A., the charged individual's custody status, and
    the court event's outcome. The Office also receives data relating to the
    arrested individual's demographics and the arrest incident from the New
    York City Police Department (\"NYPD\").
</p>"

dataCollectText <- "
<h3 class='red'>
    Data Collection
</h3>
<p>
    The Manhattan D.A.'s Office designates employees to record information at
    each court appearance and input this information into the Office's data
    collection applications. The data included on this website reflects court
    events and outcomes that occurred throughout the prior week. When an error
    is identified in the data, staff manually correct the error in the data
    collection application. Because the Office's data collection abilities,
    processes, and applications have changed over the years, there is
    variability in how information recorded at different points in time is
    stored.
</p>"

dataCleanText <- "
<h3 class='red'>
    Data Cleaning
</h3>
<p>
    The raw data collected is robust. Rather than present raw data, these
    dashboards utilize several intermediary tables that parse the raw data
    before feeding the cleaned data directly into the dashboards. This process
    allows the Office to provide more accurate case information at several key
    decision points, including arrest screening, criminal court arraignment,
    disposition, and sentencing. 
</p>
"

dataLocationText <-
  "
<h3 class='red'>
    Data on Arrest Locations
</h3>
<p>
    Arrest locations are grouped by neighborhood rather than police precinct.
    Manhattan neighborhoods are associated with police precincts as follows:
</p>
<table class = \"table-center\">
  <tr>
    <td> <p> Tribeca, Soho, and Financial District: </p> </td>
    <td> <p> 1st Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Lower East Side, Nolita, and Chinatown:</td>
    <td> <p> 5th and 7th Precincts </p> </td>
  </tr>
  <tr>
    <td> <p> West Village and Greenwich Village:</td>
    <td> <p> 6th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> East Village:</td>
    <td> <p> 9th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Midtown West and Chelsea:</td>
    <td> <p> 10th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Gramercy Park and Flatiron:</td>
    <td> <p> 13th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Midtown South:</td>
    <td> <p> Midtown South (14th) Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Midtown East:</td>
    <td> <p> 17th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Midtown North:</td>
    <td> <p> Midtown North (18th) Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Upper East Side:</td>
    <td> <p> 19th Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Central Park:</td>
    <td> <p> Central Park (22nd) Precinct </p> </td>
  </tr>
  <tr>
    <td> <p> Upper West Side:</td>
    <td> <p> 20th and 24th Precincts </p> </td>
  </tr>
  <tr>
  <tr>
    <td> <p> East Harlem:</td>
    <td> <p> 23rd and 25th Precincts </p> </td>
  </tr>
    <td> <p> Central and West Harlem:</td>
    <td> <p> 26th, 28th, and 32nd Precincts </p> </td>
  </tr>
  <tr>
    <td> <p> Sugar Hill, Washington Heights, and Inwood:</td>
    <td> <p> 30th, 33rd, and 34th Precincts </p> </td>
  </tr>
</table>
<p>A small number of arrests occur in other boroughs, or outside of New 
York City; these are identified as \"Outside Manhattan.\" Arrests outside 
Manhattan generally occur when a suspect residing in another borough, city, 
or state is arrested in compliance with a warrant issued after an alleged 
offense. Another small subset of cases are missing arrest precinct information; 
these are identified as having an \"Unknown/Unrecorded\" location. This 
information may be missing due to data entry errors or the age of the case, 
among other reasons.
</p>"

dataUpdateText <-
"
<h3 class='red'>
    Data Updates
</h3>
<p>
    The dashboard data will be updated weekly.
</p>"

dataLimitText <-
"
<h3 class='red'>
    Data Limitations
</h3>
<ol>
  <li>
    <p>
    Lack of self-identification:
    </p>
  </li>
    <ol style='list-style-type: lower-alpha;'>
      <li>
        <p>
        All demographic data is reported to the Office by the NYPD. The NYPD
          records an individual's gender and race/ethnicity based on how they
          physically appear, not by self-identification. Therefore, it is very common
          to see an arrested individual's race and ethnicity recorded differently at
          each arrest.
        </p>
      </li>
      <li>
        <p>
        Because of this lack of self-identification, the Manhattan D.A.'s Office 
        does not have data on transgender individuals.
        </p>
      </li>
    </ol>
  <li>
    <p>
    Evolving data collection methods:
    </p>
  </li>
  <ol style='list-style-type: lower-alpha;'>
    <li>
      <p>
      The Office's data collection applications and methods have changed and
        will continue to change over time, which may result in inconsistencies and
          gaps in the data presented on this dashboard.
      </p>
    </li>
  </ol>
    <li>
      <p>
      Dashboard data only goes back to 2013:
      </p>
    </li>
    <ol style='list-style-type: lower-alpha;'>
      <li>
        <p>
        The Office migrated to the latest data collection methods in 2013.
          Because this data is the cleanest and most accurate, the dashboards will,
          for the time being, only include data from 2013 to present.
        </p>
      </li>
    </ol>
   <li> 
    <p>
    Conviction data:
    </p>
  </li>
  <ol style='list-style-type: lower-alpha'>
  <li>
    <p>
    The Office can only share data on prior convictions in Manhattan due to New York State Division of Criminal Justice Services (DCJS) data-use restrictions. 
    DCJS maintains criminal history records for individuals prosecuted in New York State.
    </p>
  </li>
  </ol>
  <li>
    <p>
      Data fluctuations:
    </p>
  </li>
  <ol style='list-style-type: lower-alpha'>
  <li>
    <p>
    The data on the website may change as it gets updated in our system. The data in our system is updated when a data entry error is corrected or a case detail is updated. 
    </p>
  </li>
  </ol>
"