library(shiny)
library(magrittr)
library(stringr)
library(ggplot2)
library(RSQLite)
library(tm)

dict <- dbConnect(SQLite(), dbname="dictionary.db")

dataProcess <- function(inputText){
  badwords <- readLines("./main-bad-words-list-txt-file_2013_11_26_04_55_56_086.txt")
  text <- removeWords(str_trim(stripWhitespace(removeNumbers(removePunctuation(tolower(inputText))))), badwords)
  text <- strsplit(text, split=" ")
  return(unlist(text))
}

predictNextWord <- function(inputText, number=5) {
  
  n_max = 4
  text <- dataProcess(inputText)
  
  for (i in min(n_max, length(text)):0) {
    sql <- paste("SELECT cur_word, frequency FROM TERM_FREQUENCY WHERE pre_word=='", 
                 paste(tail(text, i), collapse=" "), "'",
                 " AND n==", i + 1, " LIMIT ", number, sep='')
    res <- dbSendQuery(conn=dict, sql)
    predicted <- dbFetch(res)
    names(predicted) <- c("Predicted_Word", "Frequency")

    if (nrow(predicted) > 0)
      return(predicted)
  }
}


shinyServer(function(input, output) {
  predicted_word <- reactive({predictNextWord(input$inputText, input$numberOfPredictedWords)})
  output$inputText <- renderText({input$inputText})
  output$predictedWords <- renderText({unlist(predicted_word())[1]})
#   output$predictedWords <- renderText({
#     result <- predicted_word()
#     if(!is.null(result)) return(unlist(result)[1])
#     else return("Cannot predict the next word!")
#   })

  output$hist <- renderPlot({
    result <- predicted_word()
    if(!is.null(result)){
    # barplot(table(result$'Predicted_Word'), col="wheat", main=paste("top", input$numberOfPredictedWords,"word"), width = 0.2)   
      p <- (ggplot(result, aes(x = factor(Predicted_Word, rev(Predicted_Word)) , y = Frequency)) 
         + geom_bar(stat = "identity", fill = "blue", width = .6) + coord_flip()
         + geom_text(label=result$Frequency, colour = "white", size = 10, hjust=2)
         + theme(axis.text.y = element_text(size = 14, angle = 0, hjust = 1), plot.title = element_text(vjust = 1))
        #+ theme(plot.title = element_text(size = 14, face = "bold"))
        #+ xlab("Frequency") + ylab('Predicted Word')
         + theme(panel.grid=element_blank(), axis.title=element_blank()))
        #+ ggtitle(paste("top", input$numberOfPredictedWords, "word", sep = " "))) 
      print(p)
    }
  })
})