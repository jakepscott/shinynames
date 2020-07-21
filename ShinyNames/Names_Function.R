library(ggplot2)
library(tidyverse)
library(babynames)
themes <- list("Light" = theme_light(),"Minimal" = theme_minimal(), "Grey" = theme_grey(), 
               "Gray" = theme_gray(), "Bw" = theme_bw(), "Linedraw" = theme_linedraw(), 
               "Dark" = theme_dark(), "Classic" = theme_classic(), "Void" = theme_void(), 
               "Test" = theme_test(), "Economist" = theme_economist(), "HC" = theme_hc(), 
               "Calc" = theme_calc(), "Wall Street" = theme_wsj(), "Stata" = theme_stata(), 
               "Tufte"= theme_tufte())

common_names <- babynames %>% group_by(name) %>% dplyr::summarise(total=sum(n)) %>% dplyr::filter(total>100000)


babynames <- semi_join(babynames, common_names, by="name")
unique_names <- babynames %>% dplyr::select(name) %>% distinct(name) %>% arrange(name) %>% pull()

#Setting Up Function
names_generator <- function(names, measure="Frequency", min=1880,max=2020, theme=theme_minimal()) {
  if (measure=="Frequency") {
    names <- babynames %>% dplyr::filter(name %in% names) %>% 
      dplyr::filter(year>=min, year<=max) %>% 
      group_by(name,year) %>% 
      dplyr::summarise(n=sum(n)) %>% ungroup()
    
    ggplot(names) + 
      geom_line(aes(x=year,y=n, color=name), lwd=1) +
      scale_x_continuous(breaks = seq(min, max, by = 10)) +
      scale_y_continuous(expand = c(0,0)) +
      theme +
      labs(title= "Frequency of Names by Year",
           caption = "Plot: @jakepscott2020 | Data: SSA Database, from Babynames V 1.0.0") +
      theme(axis.title = element_blank(),
            legend.title = element_blank(), 
            legend.position = "bottom", 
            plot.title.position = "plot")
  } else { 
    if (measure=="Proportion") {
      names <- babynames %>% dplyr::filter(name %in% names) %>% 
        dplyr::filter(year>=min, year<=max) %>% 
        group_by(name,year) %>%
        dplyr::summarise(prop=sum(prop)) %>% 
        ungroup()
      
      ggplot(names) + 
        geom_line(aes(x=year,y=prop, color=name)) +
        scale_x_continuous(breaks = seq(min, max, by = 10)) +
        scale_y_continuous(expand = c(0,0)) +
        theme +
        labs(title= "Proportion of Children with Given Name by Year",
             caption = "Plot: @jakepscott2020 | Data: SSA Database, from Babynames V 1.0.0") +
        theme(axis.title = element_blank(),
              legend.title = element_blank(), 
              legend.position = "bottom", 
              plot.title.position = "plot")
    } else {
      if (measure=="Normalized") {
        names <- babynames %>% dplyr::filter(name %in% names) %>% 
          dplyr::filter(year>=min, year<=max) %>% 
          group_by(name,year) %>%
          dplyr::summarise(prop=sum(prop)) %>% 
          mutate(mean=mean(prop), sd=sd(prop), 
                 diff=(prop-mean)/sd)
        
        ggplot(names) + 
          geom_line(aes(x=year,y=diff, color=name)) +
          scale_x_continuous(breaks = seq(min, max, by = 10)) +
          geom_hline(yintercept = 0, color="grey", linetype="dashed") +
          theme +
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

