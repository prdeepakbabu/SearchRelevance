library(tm);
library(SnowballC);
library(sqldf);
library(shiny);
library(DT);
library(rCharts);
library(shinythemes);
require(rCharts)
library(wordcloud)
library(googleVis);

shinyUI(fluidPage(
  tags$head(
    tags$style(
      HTML(
        "font-family: Courier"
      )
    )
  ),
  theme = shinytheme("flatly"),
  HTML("<img align='left' src='http://shopo.in/assets/sd_logo-4e7776c3694bee158049b03e5f6ed0996c1513c3fc39bc1e9f39a79f270de21a.png'  height='40px' />"),
  HTML("<h3 align='center'>Language Detection using Hidden Markov Models</align></h3>"),
  #titlePanel("Gender Inference Engine"),  
  
  fluidRow(
    column(8,textInput("search",label=h4("Type in your sentence/words"), value = "Machardani"))
  ),
  fluidRow(
    column(2,checkboxInput("hindi",label=h6("Highlight Hindi"), TRUE)),
    column(2,checkboxInput("english",label=h6("Highlight English"), TRUE))    
  ),
  fluidRow(  
    column(1,submitButton("Detect Language"))
  ),
  fluidRow(
    column(12,HTML(paste("<h4><table border=1><tr><td style = 'padding: 5px'>",htmlOutput('test'),"<br></tr></td></table></h4>",sep="")))
    #    column(8,offset=4,uiOutput('detail'))
  )
))