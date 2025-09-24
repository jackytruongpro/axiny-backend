# user_app/app.R
library(shiny)

ui <- fluidPage(
  titlePanel("Dashboard Simple - Iris"),
  sidebarLayout(
    sidebarPanel(
      selectInput("species", "Espèce :", 
                  choices = c("setosa", "versicolor", "virginica"), 
                  selected = "setosa"),
      sliderInput("bins", "Nombre de bins :", 
                  min = 5, max = 20, value = 10)
    ),
    mainPanel(
      plotOutput("histogram")
    )
  )
)

server <- function(input, output, session) {
  output$histogram <- renderPlot({
    data_subset <- iris[iris$Species == input$species, ]
    hist(data_subset$Sepal.Length, 
         breaks = input$bins,
         col = "lightblue",
         main = paste("Histogramme -", input$species),
         xlab = "Longueur des sépales")
  })
}

shinyApp(ui = ui, server = server)
