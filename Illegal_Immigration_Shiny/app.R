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
            box(plotlyOutput("totals", height = 625), width = 8, height = 650),
            box(dataTableOutput("table"), width = 4)
          )
        ),
      
      #second tab content
      tabItem(tabName = "borders",
        fluidRow(
          box(plotlyOutput("border", height = 625), width = 8, height = 650),
          box(selectInput("bor", 
                          label = "Choose from borders", 
                          choices = list("Coast", "North", "Southwest"), 
                          selected = "Coast"), width = 3))
          ),
      
        
        
      #third tab content
      tabItem(tabName = "sectors",
      fluidRow(
        box(plotlyOutput("mapplot", height = 625), width = 8, height = 650),
        
        box(sliderInput("year",
                        "Year:",
                        min = 2000,
                        max = 2016,
                        value = 2016), width = 4),
        fluidRow(
          box(plotlyOutput("barplot", height = 475), width = 4, height = 500))
        )
      )
    )
  )
)

  


server <- function(input, output) { 
  output$totals <- renderPlotly({
    ggplotly(tot)
  })
  output$table <- renderDataTable(
    percentages, {
        options = list(
          pageLength = 10, # Only outputs first 10 values to be more aesthetically pleasing
          scrollX = TRUE) 
  })
  output$border <- renderPlotly({
    choices <- switch(input$bor,
                      "Coast" = border("Coast", "Illegal Immigration Arrests Along the Coast"),
                      "North" = border("North", "Illegal Immigration Arrests at Northern Border") ,
                      "Southwest" = border("Southwest", "Illegal Immigration Arrests at Southwest Border"))
  })

  output$barplot <- renderPlotly({
    yearPlot(input$year)
  })
  output$mapplot <- renderPlotly({
    mapPlot(input$year)
  })
  
  
  }

shinyApp(ui, server)



