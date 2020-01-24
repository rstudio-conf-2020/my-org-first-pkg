#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    titlePanel("Midgar reactor output"),

    sidebarLayout(
        sidebarPanel(
            selectInput(
                "sector_number",
                "Midgar Sector",
                choices = 1:8,
            )
        ),

        mainPanel(
            plotOutput("reactor_plot"),
            gt::gt_output("reactor_data")
        )
    )
))
