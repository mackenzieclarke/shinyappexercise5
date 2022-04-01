library(shiny)
library(tidyverse)
library(covid19)

covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

ui <- fluidPage(selectInput("state", 
                            "State", 
                            choices = covid19 %>% 
                              arrange(state) %>% 
                              distinct(state) %>% 
                              pull(state),
                            multiple = TRUE),
                sliderInput(inputId = "date",
                            label = "Date",
                            min = as.Date(min(covid19$date)),
                            max = as.Date(max(covid19$date)),
                            value = c(as.Date(min(covid19$date)), as.Date(max(covid19$date)))))

server <- function(input, output) {}
shinyApp(ui = ui, server = server)

