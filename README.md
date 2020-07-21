# Shiny Names
![image](https://user-images.githubusercontent.com/56490913/88090684-ed2f8b80-cb5b-11ea-871b-130aaedb35fb.png)

Shiny Names is a very simple [Shiny app](https://jake-scott.shinyapps.io/shinynames) that allows a user to explore the evolution of names over time in the US. It uses the [Babynames](https://cran.r-project.org/web/packages/babynames/babynames.pdf) package, which includes  names provided by the SSA, including all names used for 5 or more children since 1880. I built this app simply as a refresher on Shiny, it is not meant to be stunningly gorgeous or groundbreakingly insightful. But it is good for a couple minutes of fun!

## Getting Started

The easiest way to *use* the app is just to go to the [website](https://jake-scott.shinyapps.io/shinynames). To run the app locally on your own computer, simply download the code from the Names_Function.R and app.R files and run it.

### Prerequisites

You don't need anything if you run it on the website! To run it on your computer you need R and the following packages installed and loaded:

```
library(shiny)
library(ggplot2)
library(tidyverse)
library(babynames)
library(ggthemes)
library(shinythemes)

```

## Author

* **Jake Scott** - [Twitter](https://twitter.com/jakepscott2020), [Medium](https://medium.com/@jakepscott16)
