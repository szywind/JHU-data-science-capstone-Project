
library(shiny)
shinyUI(pageWithSidebar(
  
  h1("Word Prediction with Simple Backoff Method"),
  
  sidebarPanel(
    h4("INPUT"),
    p("You need to click the button 'Start Predicion' to start the prediction process."),
    textInput(inputId="inputText", label="Please enter a phrase", "Please enter a phrase "),
    numericInput(inputId='numberOfPredictedWords', label='Please enter the upper bound of the number of predicted words', 5, min = 1, max = 10, step = 1),
    submitButton("Start Prediction"),
    p(em("Documentation:",a("Click Here for the Documentation of this Application",href="index.html"))),
    p(em("Codes:",a("Click Here for the Code of this Application in Github", href="https://github.com/szywind/JHU-data-science-capstone-Project")))
  ),
  mainPanel(
    h3('Results of prediction'),
    h4('You entered'),
    verbatimTextOutput("inputText"),
    h4('Which resulted in a prediction of '),
    verbatimTextOutput("predictedWords"),
    h4('Histogram of the most frequent candidates'),
    plotOutput('hist')
  )
))