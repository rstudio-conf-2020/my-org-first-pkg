#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(avalanchr)
library(dplyr)
library(ggplot2)
library(gt)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    reactor_data <- reactive({
        filter(hack_shinra_data(), reactor == input$sector_number)
    })

    output$reactor_plot <- renderPlot({
        ggplot(reactor_data(), aes(x = day, y = output)) +
            geom_line() +
            theme_avalanche()
    })

    output$reactor_data <- render_gt({
        reactor_data() %>%
            top_n(10, output) %>%
            gt() %>%
            tab_header(title = "Top 10 Output days")
    })

})
