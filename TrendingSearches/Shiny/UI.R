library(shiny);
library(DT);
library(rCharts);
library(shinythemes);
require(rCharts)
library(wordcloud)
library(googleVis);

shinyUI(fluidPage(
  theme = shinytheme("cosmo"),
  responsive = TRUE,
  #theme = "bootstrap.min.css",
  
  # Application title
  titlePanel("Trending Searches"),
  
  # Sidebar with a slider input for the number of bins
  #sidebarLayout(
  #  sidebarPanel(
  fluidRow(
    
    column(4,
           wellPanel(
      numericInput("hour", "Enter Hour", value=12 , min = 1,max = 23),
      
      sliderInput("bins",                  "Top n results",                  min = 5,                  max = 20,                  value = 10),      
      selectInput("algo", "Choose Algorithm", choices = c('24hr z-score based'=2,'Rank Variation H/H'=1)),
      submitButton("Submit")
    )),
    
    
    column(8,
           #h4("Tabular - Trending Searches"),
           DT::dataTableOutput('mytable')
           )
    
    
    ),
  
  fluidRow(
    
    column(4,#h4("Top 50 Searches"),
           plotOutput("wordcl")),
    #helpText("Trending searches compares the selected hour with previous hour for searches which changed with high velocity and has good volume.")
    column(8,
           #h4("Timeline View of Trending Searches"),
           #htmlOutput("chart1")
           showOutput("chart1", "polycharts")
           #plotOutput("chart1",width="600",height="300")
    )
  )
           
    
    
    # Show a plot of the generated distribution
    #mainPanel(
      
     # DT::dataTableOutput('mytable'),
      # showOutput("chart1", "polycharts")
      #htmlOutput("chart1")
      

    #)
  #)
))