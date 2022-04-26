library(ggplot2);
library(plotly);
library(lubridate);
library(tidyverse);
library(scales);
library(shinycssloaders);

#  _____________________________________________
#  Colors                                  ####

# individual color variables
DARK_BLUE <- "#2b316f"
DARK_PURPLE <- "#52347a"
NEON_RED <- "#ff5850"
SEA_BLUE <- "#50a0ff"
YELLOW <- "#ffb050"
DARK_GREEN <- "#316f2b"
TURQUOISE <- "#8db3d5"
PURPLE <- "#c9b0ff"
MAGENTA <- "#ba337b"
BLACK <- "#231f20"
ORANGE <- "#f47321"
LIGHT_GREEN <- "#50ffb0"


# . colors: general palettes
COL_SCALE_FILL_2 <- scale_fill_manual(values = c(SEA_BLUE, YELLOW))
COL_SCALE_FILL_4 <- scale_fill_manual(values = c(DARK_GREEN, TURQUOISE,
                                                 ORANGE, LIGHT_GREEN))
COLORS_NO_BLACK <- c(
  DARK_BLUE, 
  DARK_PURPLE,
  NEON_RED,
  SEA_BLUE, 
  YELLOW, 
  DARK_GREEN, 
  TURQUOISE, 
  PURPLE, 
  MAGENTA,
  ORANGE,
  LIGHT_GREEN,
  "#ff0000", 
  "#ff8c00")

# . colors: charge change detail (arrest, disposition)
values_charge_change <- c(
  "Change was Unknown" = BLACK,
  "Downgraded Felony" = DARK_PURPLE,
  "Downgraded Misdemeanor" = DARK_BLUE,
  "Downgraded to a Misdemeanor" = SEA_BLUE,
  "Downgraded to a Violation or Infraction" = DARK_GREEN,
  "Equivalent Felony" = MAGENTA,
  "Equivalent Misdemeanor" = NEON_RED,
  "Equivalent Violation or Infraction" = LIGHT_GREEN,
  "Upgraded Felony" = TURQUOISE,
  "Upgraded Misdemeanor" = ORANGE,
  "Upgraded to a Felony" = PURPLE, 
  "Upgraded to a Misdemeanor" = YELLOW)
COL_SCALE_CHG_CHNG <- scale_colour_manual(values = values_charge_change) 
COL_SCALE_FILL_CHG_CHNG <- scale_fill_manual(values = values_charge_change)

#  _____________________________________________
# Import data for dashboards, create color palettes used in dashboards ####

DATA_PATH <- "data/"

# arrest data -----------------------

arr_data <- readRDS(paste0(DATA_PATH, 'arrests.RDS'))

# . filter options: arrest type
arrestTypeOptions <- readRDS(paste0(DATA_PATH,'arrestTypeOpt.RDS'))

# . filter options: screen outcome
screenOutcomeOptions <- readRDS(paste0(DATA_PATH,'screenOutcomeOpt.RDS'))

# colors: arrest type
COL_SCALE_ARR_TYPE <- scale_colour_manual(values = c("Live Arrest" = YELLOW,
                                                     "DAT" = SEA_BLUE))
# colors: screen outcome
COL_SCALE_SCR_OUT <- scale_colour_manual(values = c("Prosecute" = YELLOW, 
                                                    "Decline to Prosecute" = SEA_BLUE,
                                                    "Deferred Prosecution" = DARK_BLUE))

# arraignment data --------------------

arc_data <- readRDS(paste0(DATA_PATH, 'arraignments.RDS'))

# . filter options: release status
relStatOpt <- readRDS(paste0(DATA_PATH, 'relStatOpt.RDS'))

# . filter options: arraignment disposition
ARC_DISPO_OPT <- list("Yes" = 1, "No" = 0)
ARC_DISPO_SELECT <- c(1,0)

# . colors: arraignment disposition 
COL_SCALE_FILL_ARC_DISPO <- scale_fill_manual(values = c("Disposed at Arraignment" = SEA_BLUE,
                                                         "Continued Past Arraignment" = YELLOW))
# . colors: bail requested and bail set
values_bail_req_set <- c("Bail Set" = YELLOW,
                         "Bail Requested" = SEA_BLUE)
COL_SCALE_BAIL_RS <- scale_colour_manual(values = values_bail_req_set)
COL_SCALE_FILL_BAIL_RS <- scale_fill_manual(values = values_bail_req_set)


# disposition data ---------------------

dispo_data <- readRDS(paste0(DATA_PATH,'dispos.RDS'))

# . filter options: disposition type
dispoTypeOptions <- readRDS(paste0(DATA_PATH, 'dispoTypeOptions.RDS'))

# . colors: disposition type 
values_dispo_type <- c("Conviction" = ORANGE,
                       "ACD" = MAGENTA,
                       "Dismissal" = DARK_PURPLE,
                       "Acquittal" = TURQUOISE,
                       "Other" = NEON_RED)
COL_SCALE_DSP_TYPE <- scale_colour_manual(values = values_dispo_type) 
COL_SCALE_FILL_DSP_TYPE <- scale_fill_manual(values = values_dispo_type)

# . colors: disposition category
values_dispo_cat <- c("Plea to Felony" = MAGENTA,
                      "Plea to Misdemeanor"  = NEON_RED,
                      "Plea to Violation/Infraction" = LIGHT_GREEN,
                      "Plea to Unknown" = ORANGE,
                      "Trial Conviction on Felony" = PURPLE,
                      "Trial Conviction on Misdemeanor" = DARK_PURPLE,
                      "Trial Conviction on Violation/Infraction" = DARK_GREEN,
                      "ACD" = SEA_BLUE,
                      "Dismissal" = TURQUOISE,
                      "Acquittal" = YELLOW,
                      "Other" = BLACK)
COL_SCALE_DSP_CAT <- scale_colour_manual(values = values_dispo_cat) 
COL_SCALE_FILL_DSP_CAT <- scale_fill_manual(values = values_dispo_cat)


# sentence data -----------------------

sen_data <- readRDS(paste0(DATA_PATH, 'sentences.RDS'))
fines_data <- readRDS(paste0(DATA_PATH, 'fines.RDS'))

# . filter options: sentence type
sentenceTypeOptions <- readRDS(paste0(DATA_PATH, 'sentenceTypeOptions.RDS'))

# . colors: sentence type 
values_sentence_type <- c("Conditional Discharge" = NEON_RED,
                          "Incarceration" = MAGENTA,
                          "Monetary Payment" = TURQUOISE,
                          "Other" = BLACK,
                          "Probation" = DARK_GREEN,
                          "Time Served" = PURPLE)
COL_SCALE_SEN_TYPE <- scale_colour_manual(values = values_sentence_type)
COL_SCALE_FILL_SEN_TYPE <- scale_fill_manual(values = values_sentence_type)

# . colors: incarceration type
COL_SCALE_INC_TYPE <- scale_colour_manual(values = c("Jail" = PURPLE,
                                                     "Prison" = NEON_RED,
                                                     "Unknown" = ORANGE))

# . colors: jail time
values_jail_len <- c("1-3 Months" = PURPLE,
                     "3-6 Months" = NEON_RED,
                     "6-9 Months" = ORANGE,
                     "9-12 Months" = MAGENTA,
                     "Less than One Month" = TURQUOISE,
                     "Unknown" = DARK_GREEN)
COL_SCALE_JAIL_LEN <- scale_colour_manual(values = values_jail_len)
COL_SCALE_FILL_JAIL_LEN <- scale_fill_manual(values = values_jail_len)

# . colors: prison time
values_prison_len <- c("1-3 Years" = LIGHT_GREEN, 
                       "3-5 Years" = PURPLE,
                       "5-7 Years" = TURQUOISE,
                       "7-10 Years" = DARK_GREEN,
                       "10-15 Years" = DARK_PURPLE,
                       "15-20 Years" = DARK_BLUE,
                       "20-25 Years" = ORANGE, 
                       "Over 25 Years" = NEON_RED,
                       "Life in Prison" = MAGENTA)
COL_SCALE_PRIS_LEN <- scale_colour_manual(values = values_prison_len)
COL_SCALE_FILL_PRIS_LEN <- scale_fill_manual(values = values_prison_len)

# . colors: fine amount
values_fine <- c("Under $50" = LIGHT_GREEN,
                 "$50-$100" = TURQUOISE, 
                 "$100-$500" = PURPLE,
                 "$500-$1,000" = DARK_PURPLE,
                 "$1,000-$5,000" = ORANGE,
                 "$5,000-$10,000" = NEON_RED,
                 "Over $10,000" = MAGENTA,
                 "Unknown" = BLACK)
COL_SCALE_FINE <- scale_colour_manual(values = values_fine)
COL_SCALE_FILL_FINE <- scale_fill_manual(values = values_fine)


# cohort data ---------------------------

coh_data <- readRDS(paste0(DATA_PATH, 'cohort.RDS'))

# year data -------------------------------

# . filter options: year
YEAR_OPT <- seq(year(Sys.Date()), 2013, by = -1)
names(YEAR_OPT) <- YEAR_OPT
names(YEAR_OPT)[1] <- paste(names(YEAR_OPT)[1], 'YTD')

YR_LABELS <- names(YEAR_OPT)
YR_LABELS[1] <- gsub( ' ', '<br>', YR_LABELS[1] )
YR_LABELS <- rev(YR_LABELS)

# . filter options: cohort year
COH_YEAR_OPT <- seq(year(Sys.Date())-1, 2013, by = -1)
names(COH_YEAR_OPT) <- COH_YEAR_OPT

COH_YR_LABELS <- names(COH_YEAR_OPT)
COH_YR_LABELS[1] <- gsub( ' ', '<br>', COH_YEAR_OPT[1] )
COH_YR_LABELS <- rev(COH_YEAR_OPT)


# charge category data ---------------------

# . filter options: charge category (arrest dashboard)
CAT_OPT <- c('Felony', 'Misdemeanor', 'Violation/Infraction', 'Unknown')

# . filter options: charge category 2 (non-arrest dashboards) 
# including violent/non-violent felony
# arrest charges cannot be parsed into violent/non-violent so N/A
CAT_OPT2 <- c('Violent Felony', 'Non-Violent Felony', 'Misdemeanor', 
             'Violation/Infraction', 'Unknown')

# . colors: charge category
COL_SCALE_CHG_CAT <- scale_colour_manual(values = c("Felony" = MAGENTA,
                                                    "Misdemeanor" = NEON_RED,
                                                    "Violation/Infraction" = LIGHT_GREEN,
                                                    "Unknown" = ORANGE,
                                                    "Total Cases" = DARK_PURPLE))


# charge major group data ---------------------

# . filter options: charge major group data 
MG_OPT <- c(
  'Admin. Code',
  'Arson',
  'Assault',
  'Bribery',
  'Burglary',
  'Conspiracy',
  'Disorderly Conduct',
  'Drugs',
  'Escape/Custody',
  'Forgery',
  'Gambling',
  'Grand Larceny',
  'Homicide',
  'Judicial Offense',
  'Kidnapping/Coercion',
  'Marijuana',
  'Mischief',
  'Obscenity',
  'Other Felony',
  'Other Fraud',
  'Other Misdemeanor',
  'Other Unknown',
  'Other Violation/Infraction',
  'Petit Larceny',
  'Prostitution/Patronizing',
  'Public Order',
  'Resisting Arrest',
  'Robbery',
  'Sex Offense',
  'Stolen Property',
  'Theft',
  'Trespass',
  'VTL',
  'Weapons',
  'Unknown')




# age data -------------------

# . filter options: age
AGE_OPT <- c('Under 18',
             '18-26',
             '27-35',
             '36-45',
             '46-55',
             '56-65',
             '65+',
             'Unknown')


# gender data -------------------

# . filter options: gender
GENDER_OPT <- c('Male', 'Female', 'Other/Unknown')


# race data ---------------------

# . colors: race
values_race <- c("American Indian/Alaskan Native" = NEON_RED,
                 "Asian/Pacific Islander" = TURQUOISE,
                 "Black" = MAGENTA,
                 "Black-Hispanic" = DARK_PURPLE,
                 "Hispanic" = DARK_GREEN,
                 "White" = ORANGE,
                 "White-Hispanic" = LIGHT_GREEN,
                 "Other/Unknown" = PURPLE)
COL_SCALE_RACE <- scale_colour_manual(values = values_race)
COL_SCALE_FILL_RACE <- scale_fill_manual(values = values_race)

# . filter options: race
RACE_OPT <- names(values_race)
RACE_OPT <- RACE_OPT[RACE_OPT != 'Hispanic']


# prior convictions data -----------------
# . filter options: prior convictions
PRIOR_FEL_OPT <- c("No prior convictions",
                   "1-2 prior convictions", 
                   "3+ prior convictions",
                   "Criminal history unknown")
PRIOR_MISD_OPT <- c("No prior convictions", 
                    "1-2 prior convictions",
                    "3-4 prior convictions",
                    "5+ prior convictions",
                    "Criminal history unknown")
YR_SINCE_CONV_OPT <- c("No prior convictions", "Under 1 year",
                       "1-2 years", "2-5 years", "5-10 years",
                       "10+ years", "Criminal history unknown")
PCT_OPT <- c("Central and West Harlem",
             "Central Park",
             "East Harlem",
             "East Village",
             "Gramercy Park and Flatiron",
             "Lower East Side, Nolita, and Chinatown",
             "Midtown East",
             "Midtown North",
             "Midtown South",
             "Midtown West and Chelsea",
             "Outside Manhattan",
             "Sugar Hill, Washington Heights, and Inwood",
             "Tribeca, Soho, and Financial District",
             "Unknown/Unrecorded",
             "Upper East Side",
             "Upper West Side",
             "West Village and Greenwich Village")


#  _____________________________________________
#  Site style options                      ####
HEIGHT <- "650px"
HEIGHT_VERT_STACK <- "650px"
HEIGHT_VERT_GRP <- "650px"
HEIGHT_750 <- "775px"

MAIN_PANEL_WIDTH <- 10
MAIN_SUBPANEL_WIDTH <- 10
MAIN_SUBPANEL_OFFSET <- 1
SIDEBAR_PANEL_WIDTH <- 2


#  _____________________________________________
#  Text options                            ####

TREEMAP_CAPTION <- function(id) {
  h5(HTML(paste0(
    "The \"treemap\" graphs below represent each category by a rectangle area proportional to its value. To read more about how to interpret this type of graph, see ",
    as.character(actionLink(inputId = id, label = 'How to Use Our Site')),
    ".")))
}

# one asterisk
DEMO_DISCLAIMER_1 <- h6("* Gender and race/ethnicity are not based on self-identification. This information comes from the NYPD.")

# two asterisks (used when single asterisk is already in use, currently for violent felony offense)
DEMO_DISCLAIMER_2 <- h6("** Gender and race/ethnicity are not based on self-identification. This information comes from the NYPD.")

# disclaimer for violent felony offense defintion
VFO_DISCLAIMER <- h6("* Violent felony offenses are defined by Penal Law 70.02.")

MAJOR_GROUP_CAPTION <- function(id) {
  paste0("To read more about the major groups of offenses below, see the ",
         as.character(actionLink(inputId = id, label = 'Glossary')),
         ".")
}


#  _____________________________________________
#  Global graph functions and variables    ####

# constant: angle for x axis labels
ANGLE <- 45

# function: spinner on graph load
SPINNER <- function(p) {
  p %>% 
    withSpinner(color = SEA_BLUE)
}


# function; clean text
CLEAN_TEXT <- function(text) {
  str_squish(format(text, nsmall = 0, big.mark = ','))
}

# function: determine percent output
PERCENT_OUTPUT <- function(x) {
  ifelse(x < .01, 
         # percentage numbers under 1, one decimal place
         sprintf("%.1f%%", x*100), 
         # percentage numbers over 1, no decimal places
         sprintf("%.0f%%", x*100)
  )
}

# function: break up string every 40 characters
STRING_BREAK <- function(s) { 
  gsub('(.{1,40})(\\s|$)', '\\1<br>', s)
}

# function: error message handling
VALIDATE <- function(df) {
  validate(need(df!=0, "No data due to filters.")) 
}

#  _____________________________________________
#  Global graph theme functions             ####

GRAPH_FONT_LARGE <- list(
  family = 'proxima',
  size = 16,
  color = '#2b316f'
)


GRAPH_FONT_SMALL <- list(
  family = 'proxima',
  size = 15,
  color = '#2b316f'
)

GRAPH_FONT_SMALL_WHITE <- list(
  family = 'proxima',
  size = 15,
  color = 'white'
)

HOVER_LABEL <- list(
  font = list(
    family = 'proxima',
    size = 15
  )
)

HOVER_LABEL_WHITE <- list(
  font = list(
    family = 'proxima',
    size = 15,
    color = "white"
  )
)

# function: hide label if percentage below certain rate and unreadable
MIN_RATE_10 <- .1
MIN_RATE_5 <- .05

MOD_GEOM_TEXT <- function(minRate) {
  
  geom_text(aes(label = ifelse(rateTotal < minRate, '', rateLabel)),
            position = position_stack(vjust = .5),
            size = 3.5,
            fontface = "bold")
  
}


# list: theme for line graph 
THEME_LINE_DISCRETE <- list(
  scale_x_discrete(breaks = c(2013:year(Sys.Date())), label = YR_LABELS),
  scale_y_continuous(label = comma),
  theme_minimal(),
  geom_line(size = 1.2),
  geom_point(size = 3),
  theme(axis.text.x = element_text(angle = ANGLE), #angled axis
        axis.title.x = element_blank(), #xaxis title through ggplotly
        axis.title.y = element_blank(), #yaxis title through ggplotly
        legend.title = element_blank() #legened title through ggplotly
  ) 
)


# list: horizontal lollipop theme ggplotly
THEME_HORIZONTAL_LOLLI <- list(
  coord_flip(),
  theme_minimal(),
  theme(legend.position = "none",
        axis.title = element_blank(),
        axis.text.x = element_text(angle = ANGLE))
)

# function: getting the max value in a data set
fx_get_max_y <- function(d) {
  
  if(nrow(d) > 0){
    max_y <- d %>% 
      select(cases) %>% 
      max()
    
    extra <- max_y/10
    
    max_y <- max_y + extra
  } else { 
    max_y <- 0
  }
  
}

# function: getting the legend vertical height based on number of categories in legend
fx_get_legend_y <- function(d) {
  
  #  category character count
  cat_char_ct <- d %>% select(grp) %>% unique %>% nchar
  
  if (cat_char_ct < 200) {
    legend_y <- 1.2
  } else if(cat_char_ct < 300) {
    legend_y <- 1.3
  } else if (cat_char_ct < 400) {
    legend_y <- 1.4
  } else if (cat_char_ct < 500) {
    legend_y <- 1.5
  } else if (cat_char_ct < 600) {
    legend_y <- 1.6
  } else if (cat_char_ct < 700) {
    legend_y <- 1.7
  } else {
    legend_y <- 1.8
  }
  
}

# . colors: all blue used in horizontal bars
DARK_BLUE_ALL <- c(DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE,
                   DARK_BLUE)


# function: theme for horizontal bars 
THEME_HORIZONTAL_BAR <- function(d, catvar, yearvar) {
  
  d <- d() %>%
    filter(cat == catvar, year == yearvar)
  
  VALIDATE(d)  
  
  MAX_Y <- fx_get_max_y(d)
  MARGIN <- case_when(MAX_Y < 500 ~ .5,
                      MAX_Y < 5000 ~ 10,
                      MAX_Y > 5000 ~ 30)
  
  p <- 
    ggplot(d,
           aes(x = reorder(grp, -rank), y = cases, fill = grp, 
               text = hoverText)
    ) +
    geom_bar(stat = 'identity', position = "dodge")+
    scale_y_continuous(limits = c(0, MAX_Y)) +
    scale_fill_manual(values = DARK_BLUE_ALL) + 
    geom_text(aes(y = cases + MARGIN, label = caseLabel),  
              size = 3.5) +
    scale_colour_manual(DARK_BLUE) +
    coord_flip() + 
    theme(panel.background = element_rect(fill = NA, color = 'black'),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.text.x = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          legend.title = element_blank(),
          text = element_text(family = 'proxima'), # font for geom_text
          legend.position = "none")
  
  ggplotly(p, tooltip = "text") %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE,
           modeBarButtonsToRemove = c("pan2d", "select2d","lasso2d", 
                                      "zoomIn2d","autoScale2d","hoverClosestCartesian")) %>% 
    layout(yaxis = list(tickfont = GRAPH_FONT_SMALL)) %>%
    style(textposition = "right",
          hoverlabel = HOVER_LABEL)
  
}


# function: theme for faceted horizontal bars 
THEME_HORIZONTAL_BAR_FACET <- function(d, catvar) {
  
  d <- d() %>% filter(cat == catvar) %>% 
    mutate(grp = gsub('<br>', ' ', grp))
  
  VALIDATE(d)
  
  # max_y helps determine what the max y limit should be in order for 
  # the biggest number to not be cut off (pre-flip)
  MAX_Y <- fx_get_max_y(d)
  
  # margin add a little to the bar label (geom_text)
  MARGIN <- if_else(MAX_Y < 5000, 10, 30)
  
  LEGEND_Y <- fx_get_legend_y(d) 
  
  
  # cat(file=stderr(), "in THEME_HORIZONTAL_BAR_FACET", LEGEND_Y, "\n") 
  
  p <- ggplot(
    d,
    # d %>% filter(cat == catvar),
    aes(x = -rank, y = cases, fill = grp, text = hoverText)
  ) +
    geom_bar(stat = 'identity', position = position_dodge(width = .7)) +
    scale_y_continuous(limits = c(0, MAX_Y)) +
    scale_fill_manual(values = COLORS_NO_BLACK) +
    geom_text(aes(y = cases + MARGIN, label = caseLabel), 
              color = DARK_BLUE, 
              size = 3.5) +
    facet_wrap(~year, ncol = 2) +
    coord_flip() +
    theme(panel.background = element_rect(fill = NA, color = 'black'),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing = unit(1, "lines"),
          axis.text = element_blank(),
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          legend.title = element_blank(),
          text = element_text(family = 'proxima'), # font for geom_text
          strip.text = element_text(size = 12)
    )
  
  ggplotly(p, tooltip = "text",
           height = 750) %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE,
           modeBarButtonsToRemove = c("pan2d", "select2d","lasso2d", 
                                      "zoomIn2d","autoScale2d","hoverClosestCartesian")) %>% 
    layout(legend = list(title = list(text = 'Charge:', font = GRAPH_FONT_LARGE), 
                         font = GRAPH_FONT_LARGE, 
                         orientation = "h", x = 0, y = LEGEND_Y),
           yaxis = list(tickfont = GRAPH_FONT_SMALL)) %>%
    style(textposition = "right",
          hoverlabel = HOVER_LABEL)
}

# function returning list: theme for stacked vertical bars 
THEME_VERT_BAR_STACKED <- function(labelType) {
  
  list(
    scale_x_discrete(breaks=c(2013:year(Sys.Date())), label = YR_LABELS),
    scale_y_continuous(labels = labelType),
    theme_minimal(),
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.text.x = element_text(angle = ANGLE),
          legend.title = element_blank(),
          axis.title = element_blank(),
          text = element_text(family = "proxima")
    ) 
  )
  
}

# . colors: treemap
TREEMAP_COLORS <- c(
  DARK_BLUE, 
  DARK_PURPLE,
  DARK_GREEN, 
  MAGENTA,
  BLACK
)

# function: theme for treemaps
PLOTLY_TREEMAP <- function(d, x, y, hoverText){
  
  VALIDATE(d)
  
  p <- plot_ly(
    d,
    labels = d[[x]],
    parents = NA,
    values = d[[y]],
    hovertext = d[[hoverText]],
    textinfo = "label+value+percent root+percent",
    type = "treemap",
    marker = list(colors = TREEMAP_COLORS),
    textfont = GRAPH_FONT_SMALL_WHITE
  ) %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE) %>% 
    layout(uniformtext = list(minsize = 15, mode = 'hide', color = 'white')) %>% 
    style(hoverlabel = HOVER_LABEL_WHITE)
  
}

# function: theme for bubble graph (part 1)
# https://davidgohel.github.io/ggiraph/articles/offcran/customizing.html
GIRAFE_BUBBLE <- function(p) {
  
  girafe(ggobj = p,
         options = list(
           opts_tooltip(
             css = "font-family: 'proxima'; font-size: 15px; padding: 2px; 
                         opacity: 1; background-color: white; color: black;
                         border: 1px solid; border-color: black;"
           )
         )
  )
  
}

# function returning list: theme for bubble graph (part 2)
THEME_BUBBLE <- function(discrete = FALSE) {
  
  list(
    scale_fill_viridis(discrete = discrete, begin = .3, end = 1, direction = -1),
    theme_void(),
    theme(legend.position = "none", plot.margin = unit(c(0,0,0,0),"cm") ),
    coord_equal()
  )
  
}


# function: layout used generally
# legend, if null, removes the legend entirely
# legend y (vertical distance above graph) if empty, has a default of 1.2
LAYOUT_GEN <- function(p, x, y, legend = NA, legend_y = 1.2) {
  
  # empty list for graphs that do not need a legend
  legObj <- list() 
  
  # create legend list for graphs that need a legend
  if (!is.na(legend)) {
    legObj <- list(title = list(text = paste0(legend, ': ' ),
                                font = GRAPH_FONT_LARGE),
                   font = GRAPH_FONT_LARGE,
                   orientation = "h", x = 0, y = legend_y
    )
  }
  
  # create ggplotly object
  ggplotly(p, tooltip = "text") %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE,
           modeBarButtonsToRemove = c("pan2d", "select2d","lasso2d", 
                                      "zoomIn2d","autoScale2d","hoverClosestCartesian")) %>% 
    layout(
      legend = legObj,
      xaxis = list(title = list(text = x, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL),
      yaxis = list(title = list(text = y, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL)
    ) %>%  
    style(hoverlabel = HOVER_LABEL)
}

# function: layout without legend title 
LAYOUT_NO_LEG_TITLE <- function(p, x, y, legend_y = 1.2) {
  
  ggplotly(p, tooltip = "text") %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE,
           modeBarButtonsToRemove = c("pan2d", "select2d","lasso2d", 
                                      "zoomIn2d","autoScale2d","hoverClosestCartesian")) %>% 
    layout(
      legend = list(orientation = "h", x = 0, y = legend_y,
                    title = list(font = GRAPH_FONT_LARGE),
                    font = GRAPH_FONT_LARGE),
      xaxis = list(title = list(text = x, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL),
      yaxis = list(title = list(text = y, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL)) %>%  
    style(hoverlabel = HOVER_LABEL)
  
}

LAYOUT_NO_LEG_TITLE <- function(p, x, y, legend_y = 1.2) {
  
  # # empty list for graphs that do not need a legend
  # legObj <- list() 
  # 
  # # create legend list for graphs that need a legend
  # if (!is.na(legend)) {
    legObj <- list(title = list(text = '',
                                font = GRAPH_FONT_LARGE),
                   font = GRAPH_FONT_LARGE,
                   orientation = "h", x = 0, y = legend_y
    )
  #}
  
  # create ggplotly object
  ggplotly(p, tooltip = "text") %>% 
    config(displaylogo = FALSE,
           displayModeBar = TRUE,
           modeBarButtonsToRemove = c("pan2d", "select2d","lasso2d", 
                                      "zoomIn2d","autoScale2d","hoverClosestCartesian")) %>% 
    layout(
      legend = legObj,
      xaxis = list(title = list(text = x, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL),
      yaxis = list(title = list(text = y, font = GRAPH_FONT_LARGE),
                   tickfont = GRAPH_FONT_SMALL)
    ) %>%  
    style(hoverlabel = HOVER_LABEL)
}

