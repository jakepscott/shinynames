library(shiny)
library(ggplot2)
library(tidyverse)
library(babynames)
library(ggthemes)
library(shinythemes)
source("Names_Function.R")

ui <- fluidPage(
  ##Setting Theme
  theme = shinytheme("flatly"),
  headerPanel("Names Over Time"),
  
  sidebarPanel(
    #Customize Theme ---
    h5("Select Names"),
    selectInput("names", "Name(s)", choices = unique_names,
                selected = "Jacob", multiple = T),
    h5("Select Measure"),
    selectInput("measure", "Measures", 
                choices = c("Frequency", "Proportion", "Normalized"),
                selected = "Frequency"),
    h5("Choose Year Range"),
    sliderInput(inputId = "yearrange", label = "Year Range",
                min = 1880, max = 2020, value = c(1880,2020),
                dragRange = TRUE, sep=""),
    h5("Plot Theme"),
    selectInput("theme", "Background theme", choices = sort(names(themes)),selected = "Minimal"),
    downloadButton('downloadPlot')
  ),
  mainPanel(
    plotOutput("plot", height = 600)
  ))

#--------------------------------------------
#-------------     Server    ----------------
#--------------------------------------------

server <- function(input, output, session) {
  
  
  #Plotting---
  output$plot <- renderPlot({
    names_generator(names=input$names, measure=input$measure,
                    min = input$yearrange[1], max=input$yearrange[2],
                    theme = themes[[input$theme]])
  })
  
  plotInput <- function() {
    names_generator(names=input$names, measure=input$measure)
  }
  #Downloading---
  output$downloadPlot <- downloadHandler(
    filename = function() { paste('Names_Figure.png', sep='') },
    content = function(file) {
      ggsave(file, plot = plotInput(), device = "png")
    }
  )
}
shinyApp(ui, server)


