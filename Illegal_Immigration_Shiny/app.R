#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#Note: must run file Illegal_Immigration.R first for this script to work
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(
    title = "Illegal Immigration Arrests"),
  
  
  #sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Breakdown by Border", tabName = "borders", icon = icon("th")),
      menuItem("Breakdown by Sector", tabName = "sectors", icon = icon("th"))
    )
  ),
  
  #body content
  dashboardBody(
    tags$head(tags$style(HTML('
      .content-wrapper, .main-body {
       font-weight: normal;
       font-size: 18px;
       } '))),
    
    tabItems(
      
      #first tab content
      tabItem(tabName = "overview",
        fluidRow(
          box(title = "Project Goal", width = 12,
              "Illegal immigration has always been a controversial issue. This is especially true now with 
              our country's current politcal situation. Like everyone else, I have my own opinions on the topic, 
              but I will do my best to remain unbiased in my analysis and report only facts rather than opinions. 
              My goal is to explore trends in US illegal immigration arrests from 2000-2016 as 
              objectively as possible."
              ),
          box(title = "Notes About the Data Set", width = 12,
              "The dataset I used for this project can be found on the Kaggle website.

              Here is a link to the original dataset: https://www.kaggle.com/cbp/illegal-immigrants
              
              The original dataset was extremely messy so it required some cleaning before any analysis could be done. 
              I have uploaded the 'clean' dataset as a csv file as well. It contains information on two demographics: 
              Mexican Illegal Immigrants and All Illegal Immigrants.
              
              It is important to note that the numbers listed are only the illegal immigrants that were ARRESTED. 
              This means that there were almost certainly more illegal immigrants each year that managed to enter 
              the country unnoticed. As such I cannot claim that my analysis is an accurate representation of trends 
              in illegal immigration overall; it only extends to illegal immigrants that were arrested."
              ),
          fluidRow(
            box(plotlyOutput("totals", width = 1000, height = 626), width = 8),
            box(dataTableOutput("table"), width = 4)
          )
        )),
      
      #second tab content
      tabItem(tabName = "borders",
        fluidRow(
          box(plotlyOutput("coast", width = 1000, height = 626), width = 8)),
        fluidRow(  
          box(plotlyOutput("north", width = 1000, height = 626), width = 8)),
        fluidRow(
          box(plotlyOutput("southwest", width = 1000, height = 626), width = 8)
          )),
        
      #third tab content
      tabItem(tabName = "sectors",
        fluidRow(
          box(plotlyOutput("barplot", width = 1000, height = 626), width = 8),
          box(sliderInput("year",
                        "Year:",
                        min = 2000,
                        max = 2016,
                        value = 2016), width = 4)),
        fluidRow(
          box(plotlyOutput("mapplot", width = 1000, height = 626), width = 8)
          ))
      )
    )
  )


server <- function(input, output) { 
  output$totals <- renderPlotly({
    ggplotly(tot)
  })
  output$table <- renderDataTable({
    percentages
  })
  output$coast <- renderPlotly({
    ggplotly(coast)
  })
  output$north <- renderPlotly({
    ggplotly(north)
  })
  output$southwest <- renderPlotly({
    ggplotly(southwest)
  })
  output$barplot <- renderPlotly({
    yearPlot(input$year)
  })
  output$mapplot <- renderPlotly({
    mapPlot(input$year)
  })
  
  
  }

shinyApp(ui, server)



