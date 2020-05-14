library(babynames)
library(tidyverse)


names_generator <- function(names, measure="frequency") {
  if (measure=="frequency") {
    names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
      summarise(n=sum(n)) %>% ungroup()
    
    ggplot(names) + 
      geom_line(aes(x=year,y=n, color=name)) +
      theme_minimal() +
      scale_y_continuous(expand = c(0,0)) +
      labs(title= "Frequency of Names by Year",
           caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
      theme(axis.title = element_blank(),
            legend.title = element_blank())
  } else { 
    if (measure=="proportion") {
      names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
        summarise(prop=sum(prop)) %>% ungroup()
      
      ggplot(names) + 
        geom_line(aes(x=year,y=prop, color=name)) +
        theme_minimal() +
        labs(title= "Proportion of Names by Year",
             caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
        theme(axis.title = element_blank(),
              legend.title = element_blank())
    } else {
      if (measure=="normalized") {
        names <- babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
          summarise(prop=sum(prop)) %>% 
          mutate(mean=mean(prop), sd=sd(prop), diff=(prop-mean)/sd)
        
        ggplot(names) + 
          geom_line(aes(x=year,y=diff, color=name)) +
          geom_hline(yintercept = 0, color="grey", linetype="dashed") +
          theme_minimal() +
          labs(title= "Standard Deviations from Full Period Mean Proportion",
               caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
          theme(axis.title = element_blank(),
                legend.title = element_blank())
      }
    }
  }
}

test <- names_generator(c("Jacob", "Samuel"), measure = "frequency")
