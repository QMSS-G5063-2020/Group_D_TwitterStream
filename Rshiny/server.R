library(shiny)
shinyServer(function(input,output){
#  x <- input$
   output$barplot <-renderPlot({
     ggplot(data=dateRangeInput(), aes_string(x="Sentiment",y=database$count))  +
       stat_summary(fun.y = mean, geom = "bar",colour="#56B4E9",fill="#56B4E9") +
       geom_bar(stat="identity") +
       labs(title=input$hashtag, y ="Average sentiment score", x= "Seentiment") +
       theme_classic() +
       theme(plot.title = element_text(hjust = 0.5)) })
   
   output$barplot <-renderPlot({
   })
})

# output$barchart <-renderPlot({
#cuantos <-aggregate(database[, input$hastag] ~ Month, database, mean)
#barplot(cuantos[-2])
#
