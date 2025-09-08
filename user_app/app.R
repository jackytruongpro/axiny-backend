# user_app/app.R
library(shiny)

ui <- fluidPage(
  titlePanel("Old Faithful Geyser Data"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins", "Number of bins:",
                  min = 1, max = 50, value = 30),
      selectInput("color", "Bar color:",
                  choices = c("darkgray", "steelblue", "forestgreen"),
                  selected = "steelblue")
    ),
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

server <- function(input, output, session) {
  output$distPlot <- renderPlot({
    x    <- faithful$eruptions
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = input$color,
         xlab = "Duration (minutes)", main = "Histogram of eruption durations")
  })
}
