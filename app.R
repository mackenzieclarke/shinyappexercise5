library(shiny)
library(tidyverse)

covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")
census_pop_est_2018 <- read_csv("https://www.dropbox.com/s/6txwv3b4ng7pepe/us_census_2018_state_pop_est.csv?dl=1") 

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
                            value = c(as.Date(min(covid19$date)), as.Date(max(covid19$date)))),
                submitButton("Compare States"),
                plotOutput(outputId = "covidplot"))

server <- function(input, output) {
  output$covidplot <- renderPlot(
    covid19 %>% 
      filter(state %in% input$state) %>% 
      mutate(state_name = str_to_lower(state)) %>% 
      left_join(census_pop_est_2018, 
                by = c("state_name" = "state")) %>% 
      mutate(covid_100000 = (cases/est_pop_2018)*100000) %>% 
      mutate(state = str_to_title(state)) %>% 
      group_by(state) %>% 
      mutate(lag_cases = lag(cases, 1, replace_na(0))) %>% 
      mutate(new_cases = cases - lag_cases) %>% 
      mutate(daily = new_cases/est_pop_2018*100000) %>% 
      ggplot(aes(x = date, 
                 y = daily, 
                 color = state)) +
      geom_line() +
      scale_x_date(limits = input$date)
  )
}
shinyApp(ui = ui, server = server)
