# user_app/app.R
library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Analyse du jeu de données mtcars"),
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar", "Variable X :", 
                  choices = names(mtcars)[sapply(mtcars, is.numeric)], 
                  selected = "wt"),
      selectInput("yvar", "Variable Y :", 
                  choices = names(mtcars)[sapply(mtcars, is.numeric)], 
                  selected = "mpg"),
      sliderInput("points", "Nombre de points :", 
                  min = 10, max = nrow(mtcars), value = 20)
    ),
    mainPanel(
      plotOutput("scatterPlot"),
      verbatimTextOutput("summary")
    )
  )
)

server <- function(input, output, session) {
  sampled <- reactive({
    mtcars[sample(nrow(mtcars), input$points), ]
  })
  
  output$scatterPlot <- renderPlot({
    ggplot(sampled(), aes_string(x = input$xvar, y = input$yvar)) +
      geom_point(color = "steelblue", size = 3) +
      theme_minimal() +
      labs(title = paste("Nuage de points de", input$yvar, "vs", input$xvar))
  })
  
  output$summary <- renderPrint({
    summary(sampled()[, c(input$xvar, input$yvar)])
  })
}

shinyApp(ui = ui, server = server)
