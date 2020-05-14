#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(ggplot2)
library(tidyverse)
library(babynames)
library(ggthemes)
library(shinythemes)

#--------------------------------------------
#-----------  ggplot themes    --------------
#--------------------------------------------
themes <- list("Light" = theme_light(),"Minimal" = theme_minimal(), "Grey" = theme_grey(), 
               "Gray" = theme_gray(), "Bw" = theme_bw(), "Linedraw" = theme_linedraw(), 
               "Dark" = theme_dark(), "Classic" = theme_classic(), "Void" = theme_void(), 
               "Test" = theme_test(), "Economist" = theme_economist(), "HC" = theme_hc(), 
               "Calc" = theme_calc(), "Wall Street" = theme_wsj(), "Stata" = theme_stata(), 
               "Tufte"= theme_tufte())

common_names <- babynames %>% group_by(name) %>% summarise(total=sum(n)) %>% filter(total>100000)


babynames <- semi_join(babynames, common_names, by="name")
unique_names <- babynames %>% select(name) %>% distinct(name) %>% arrange(name) %>% pull()


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
  
  #Setting Up Function
  names_generator <- function(names, measure="Frequency", min=1880,max=2020) {
    plot_theme <- themes[[input$theme]]
    if (measure=="Frequency") {
      names <- babynames %>% filter(name %in% names) %>% 
        filter(year>=min, year<=max) %>% 
        group_by(name,year) %>% 
        summarise(n=sum(n)) %>% ungroup()
      
      ggplot(names) + 
        geom_line(aes(x=year,y=n, color=name), lwd=1) +
        scale_x_continuous(breaks = seq(min, max, by = 10)) +
        scale_y_continuous(expand = c(0,0)) +
        plot_theme +
        labs(title= "Frequency of Names by Year",
             caption = "Plot: @jakepscott2020 | Data: SSA Database, from Babynames V 1.0.0") +
        theme(axis.title = element_blank(),
              legend.title = element_blank(), 
              legend.position = "bottom", 
              plot.title.position = "plot")
    } else { 
      if (measure=="Proportion") {
        names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
          summarise(prop=sum(prop)) %>% ungroup()
        
        ggplot(names) + 
          geom_line(aes(x=year,y=prop, color=name)) +
          scale_x_continuous(breaks = seq(min, max, by = 10)) +
          scale_y_continuous(expand = c(0,0)) +
          plot_theme +
          labs(title= "Proportion of Children with Given Name by Year",
               caption = "Plot: @jakepscott2020 | Data: SSA Database, from Babynames V 1.0.0") +
          theme(axis.title = element_blank(),
                legend.title = element_blank(), 
                legend.position = "bottom", 
                plot.title.position = "plot")
      } else {
        if (measure=="Normalized") {
          names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
            summarise(prop=sum(prop)) %>% 
            mutate(mean=mean(prop), sd=sd(prop), diff=(prop-mean)/sd)
          
          ggplot(names) + 
            geom_line(aes(x=year,y=diff, color=name)) +
            scale_x_continuous(breaks = seq(min, max, by = 10)) +
            geom_hline(yintercept = 0, color="grey", linetype="dashed") +
            plot_theme +
            labs(title= "Standard Deviations from Full Period Mean Proportion",
                 caption = "Plot: @jakepscott2020 | Data: SSA Database, from Babynames V 1.0.0") +
            theme(axis.title = element_blank(),
                  legend.title = element_blank(), 
                  legend.position = "bottom", 
                  plot.title.position = "plot")
        }
      }
    }
  }
  #Plotting---
  output$plot <- renderPlot({
    names_generator(names=input$names, measure=input$measure,
                    min = input$yearrange[1], max=input$yearrange[2])
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

