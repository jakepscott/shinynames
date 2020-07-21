library(shiny)
library(ggplot2)
library(tidyverse)
library(babynames)
library(ggthemes)
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
      h4("Select Names"),
      selectInput("names", "Name(s)", choices = unique_names,
                  selected = "Jacob", multiple = T),
      h4("Select Measure"),
      selectInput("measure", "Measures", 
                  choices = c("Frequency", "Proportion", "Normalized"),
                  selected = "Frequency"),
      h4("Plot Theme"),
      selectInput("theme", "Background theme", choices = sort(names(themes)),selected = "Minimal"),
      downloadButton('downloadPlot')
    ),
    mainPanel(
      plotOutput("plot", height = "500", width = "850")
  ))

#--------------------------------------------
#-------------     Server    ----------------
#--------------------------------------------

server <- function(input, output, session) {

  #Setting Up Function
  names_generator <- function(names, measure="Frequency") {
    plot_theme <- themes[[input$theme]]
    if (measure=="Frequency") {
      names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
        summarise(n=sum(n)) %>% ungroup()
      
      ggplot(names) + 
        geom_line(aes(x=year,y=n, color=name)) +
        scale_x_continuous(breaks = seq(1880, 2020, by = 10)) +
        plot_theme +
        labs(title= "Frequency of Names by Year",
             caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
        theme(axis.title = element_blank(),
              legend.title = element_blank())
    } else { 
      if (measure=="Proportion") {
        names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
          summarise(prop=sum(prop)) %>% ungroup()
        
        ggplot(names) + 
          geom_line(aes(x=year,y=prop, color=name)) +
          scale_x_continuous(breaks = seq(1880, 2020, by = 10)) +
          plot_theme +
          labs(title= "Proportion of Names by Year",
               caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
          theme(axis.title = element_blank(),
                legend.title = element_blank())
      } else {
        if (measure=="Normalized") {
          names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
            summarise(prop=sum(prop)) %>% 
            mutate(mean=mean(prop), sd=sd(prop), diff=(prop-mean)/sd)
          
          ggplot(names) + 
            geom_line(aes(x=year,y=diff, color=name)) +
            scale_x_continuous(breaks = seq(1880, 2020, by = 10)) +
            geom_hline(yintercept = 0, color="grey", linetype="dashed") +
            plot_theme +
            labs(title= "Standard Deviations from Full Period Mean Proportion",
                 caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
            theme(axis.title = element_blank(),
                  legend.title = element_blank())
        }
      }
    }
  }
  #Plotting---
  output$plot <- renderPlot({
    names_generator(names=input$names, measure=input$measure)
  })
  
  plotInput <- function() {
    names_generator(names=input$names, measure=input$measure)
  }
  #Downloading---
  output$downloadPlot <- downloadHandler(
    filename = function() { paste('Names_Figure', sep='') },
    content = function(file) {
      ggsave(file, plot = plotInput(), device = "png")
    }
  )
}
shinyApp(ui, server)