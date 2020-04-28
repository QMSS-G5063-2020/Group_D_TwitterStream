library(shiny)
library(ggplot2)
library(rtweet)
library(tm)
library(tidytext)
library(quanteda)
library(stringi)
library(jsonlite)



nrc <- get_sentiments("nrc")

#rt <- stream_tweets(timeout = 1)
#rt <- rt[FALSE, ] #empty df with correct cols and coltypes 4 stream
class_df <- data.frame("class" = character()) #empty df 4 output

countClass <- function(x){
   x <- removePunctuation(x)
   x <- gsub("[^A-Za-z0-9]+", " ", x)
   x <- tolower(x)
   x <- removeWords(x, stopwords("en"))
   x <- trimws(x)
   x <- stripWhitespace(x)
   try(
      temp_sent <- names(table(nrc[nrc$word %in% as.character(quanteda::tokens(x)), "sentiment" ]))[1]
   )
   return(temp_sent)
}

streamTweet <- function(query){
   #filename <- "teststream.json"
   streamtime <- 1 #number of seconds for each sampling from twitter
   timer <- 1 #initialize timer
   rt <- stream_tweets(q = query, timeout = streamtime) #initialize dataframe
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
      class_df <<- rbind(class_df, matrix(unlist(class_list))) #data.frame("class" = matrix(unlist(class_list), nrow=length(class_list), byrow=T))
      #class_df <- reactiveValues(class = class_list)
      #class_df
      write.table(x = class_df,file = paste("~/stream",Sys.Date(),".csv",sep = ''), row.names = FALSE, col.names = FALSE)
      
      if (timer == 5){ #break statement, stream ends after 5 loops
         break
      }
   }
}

#streamTweet("covid")

shinyServer(function(input,output){
   
   test <- reactive(streamTweet(input$hashtag))
   
   #data <- reactiveFileReader(intervalMillis = 1000, session = NULL, filePath = paste("~/stream_", query ,".csv",sep = ''), readFunc = read.csv, header = F)
   data <- reactiveFileReader(intervalMillis = 1000, session = NULL, filePath = paste("~/stream",Sys.Date(),".csv",sep = ''), readFunc = read.csv, header = F)

   output$barchart <-renderPlot({
      if (!stringi::stri_isempty(input$hashtag)){ #checks if there's anything in the text field
            ggplot(data = data(), aes(x = data()$V1)) + geom_bar()
      }
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
