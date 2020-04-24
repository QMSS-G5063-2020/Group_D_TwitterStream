library(shiny)
library(ggplot2)
library(rtweet)
library(tm)
library(tidytext)
library(quanteda)
library(stringi)
library(jsonlite)

nrc <- get_sentiments("nrc")

countClass <- function(x){
   x <- removePunctuation(x)
   x <- gsub("[^A-Za-z0-9]+", " ", x)
   x <- tolower(x)
   x <- removeWords(x, stopwords("en"))
   x <- trimws(x)
   x <- stripWhitespace(x)
   try(
      #temp_sent <- table(nrc[nrc$word %in% as.list(unlist(strsplit(x, "\\s+")[[1]])), "sentiment"], decreasing = T)
      temp_sent <- names(table(nrc[nrc$word %in% as.character(quanteda::tokens(x)), "sentiment" ]))[1]
   )
   return(temp_sent)
}

streamTweet <- function(query){
   filename <- "teststream.json"
   streamtime <- 2 #number of seconds for each sampling from twitter
   timer <- 1 #initialize timer
   rt <- stream_tweets(q = query, timeout = streamtime, file_name = filename) #initialize dataframe
   rt <- rt[rt$lang == "en",] #remove non-english text
   class_list = c()
   
   repeat { #start repeat statement
      temp_rt <- stream_tweets(q = query, timeout = streamtime) #stream new data
      temp_rt <- temp_rt[temp_rt$lang == "en",] 
      rt <- rbind(rt, temp_rt) #add new data to dataframe
      timer <- timer + 1 #add loop to timer
      
      for (tweet in temp_rt$text){
         class_list <- c(class_list, countClass(tweet)) # clean and classify tweets
      }
      
      # the final dataframe as is just includes classification, needs time of tweet and lat/lon
      class_df <- data.frame("class" = matrix(unlist(class_list), nrow=length(class_list), byrow=T))
      #class_df <- reactiveValues(class = class_list)
      
      if (timer == 5){ #break statement, stream ends after 5 loops
         break
      }
   return(class_df) #only returns after repeat statement breaks which kinda ruins the point of the loop
      #really wish there was a yield statement/generators in R!!!! ugh
   }
}

shinyServer(function(input,output){
   terms <- reactive({.
      input$update # tried to make it so the stream doesn't freak out while typing the input
      isolate({
         streamTweet(input$hastag)
      })
   })

   output$barchart <-renderPlot({
      if (!stringi::stri_isempty(input$hastag)){ #checks if there's anything in the text field
         v <- terms()
         ggplot(data = v, aes(x = class)) + geom_bar()
         
         #below is still broken but the plan is that this will check for changes in the json
         #its 5 am so this code is all bad lol
         
         #data <- reactivePoll(intervalMillis = 1000, session = NULL, 
                      #checkFunc = function(){
                         #if (file.exists("teststream.json"))
                            #file.info("teststream.json")$mtime[1]
                         #else
                            #""
                      #}, 
                      #valueFunc = function() {
                         #jsonlite::read_json("teststream.json")
                      #})
         #data2 <- data()
         #ggplot(data2, aes(x = "class")) + geom_bar()
      #}
   })
})

#all of ceci's ggplot formatting, will add in once it runs
   
   #output$barplot <-renderPlot({
     #ggplot(data=dateRangeInput(), aes_string(x="Sentiment",y=database$count))  +
       #stat_summary(fun.y = mean, geom = "bar",colour="#56B4E9",fill="#56B4E9") +
       #geom_bar(stat="identity") +
       #labs(title=input$hashtag, y ="Average sentiment score", x= "Seentiment") +
       #theme_classic() +
       #theme(plot.title = element_text(hjust = 0.5)) })
   
   #output$barplot <-renderPlot({
   #})
#})

# output$barchart <-renderPlot({
#cuantos <-aggregate(database[, input$hastag] ~ Month, database, mean)
#barplot(cuantos[-2])
#
