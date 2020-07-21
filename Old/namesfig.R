library(tidyverse)
library(babynames)
library(ggrepel)
names <- (c("Caio", "Daniel", "Renee", "Jacob"))

babynames_clean <-  babynames %>% filter(name %in% names) %>% group_by(name,year) %>% 
  summarise(n=sum(n)) %>% ungroup() %>% 
  mutate(Jakey=case_when(year==1998 & name=="Jacob"~n))


ggplot(babynames_clean) + 
  geom_line(aes(x=year,y=n, color=name)) +
  geom_point(aes(x=year,y=Jakey), size=3, color="red") +
  geom_text_repel(aes(x = year, y= Jakey, label="My Birthyear..."),
                ylim = c(39000)) +
  theme_minimal() +
  coord_cartesian(ylim=c(0,45000)) +
  labs(title= "Frequency of Names by Year",
     caption = "Source: SSA Database, from Babynames Package V 1.0.0") +
  theme(axis.title = element_blank(),
      legend.title = element_blank(),
      legend.position = c(.1,.9))

ggsave("namesfig.png",dpi = 600)


