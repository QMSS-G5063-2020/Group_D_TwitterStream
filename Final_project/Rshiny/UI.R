## UI- users interface
library(shiny)
library(leaflet)
library(shinythemes)


ui = fluidPage(
  theme = shinytheme("flatly"),
  #fluidRow(column(5, offset = 4, 
                  titlePanel(h1(strong("Hashtags sentiment  analysis"), align= "center")),
#)(), 
                br(),
  fluidRow(
  h4("  Gabriel Gillings, Lemon Reimer and Cecilia Cabello",
  br(),
  h5("  Provide a hashtag and the time you wish for the app to
     'listen' for tweets containing the hashtag. The text of each tweet is then 
      processed and put through NRC dictionaries for a sentiment analysis.
                                                     "))),
  br(),
      sidebarPanel(
        fluidRow(textInput(inputId = "hashtag",
                label = "Hashtag you would like to analyze:",
                value = "")),
        fluidRow(textInput(inputId = "timer",
                label = "Time in seconds to stream",
                value = "5")),
        fluidRow(submitButton("update")),
        style = "padding: 40px;"),
  br(),
    mainPanel(
      tabsetPanel(
        tabPanel(title="Overall sentiment", 
                 br(),
                 h4(strong("Sentiment composition of tweets")), 
                 p("A bar graph which displays what is the overall distribution and count of tweets given its coincidence with NRC dictionaries."),
                 br(),
                 plotOutput("barchart")),
        tabPanel(title="Timeline", 
                 br(),
                 h4(strong("Change of sentiments through time")), 
                 p("Line graph showing the evolution of sentiment through time."), 
                 br(),
                 plotOutput("linechart")),
        tabPanel(title="Location", 
                 br(),
                 h4(strong("Location of tweets")), 
                 br(),
                 leafletOutput("mymap"),
                 p("*This map depends on the check-ins made when publishing a tweet. Also, since tweets are limited to those written in english it
                    focuses on certain countries."),
                 #dataTableOutput('tbl')
                 )
       )
    )
  )

