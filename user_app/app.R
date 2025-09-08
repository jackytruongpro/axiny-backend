# app.R
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#    https://shiny.posit.co/

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    titlePanel("Old Faithful Geyser Data - Simplified Inputs"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 5,
                        max = 25,
                        value = 10,
                        step = 5),
            selectInput("color",
                        "Bar color:",
                        choices = c("darkgray", "steelblue", "forestgreen"),
                        selected = "steelblue")
        ),
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$distPlot <- renderPlot({
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x,
             breaks = bins,
             col    = input$color,
             border = 'white',
             xlab   = 'Waiting time to next eruption (in mins)',
             main   = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
