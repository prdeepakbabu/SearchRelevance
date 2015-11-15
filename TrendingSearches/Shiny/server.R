library(shiny);
library(DT);
library(shinythemes);
library(wordcloud);
require(rCharts);
#options(RCHART_WIDTH = 900)
library(googleVis);
library(reshape);

# Define server logic required to draw a histogram
shinyServer(function(input, output) {  
  # Expression that generates a histogram. The expression isgz
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  library(sqldf);
  #fn= reactive ({ sprintf("terms_H%02d.txt", input$hour); })
  #setwd("/home/deepak/Data Logs/Minerva/Approach2");
  #dt=reactive({ read.csv(fn(),header=FALSE,sep=",") })
  #reactive ({ names(dt())=c('session','query'); })
  #y=dt();
  #complete=read.csv(file=gzfile("keywords.csv.gz"))
  complete=read.csv(file=gzfile("keywords.csv.gz"))
  x<-reactive({    
    fn=sprintf("terms_H%02d.txt.gz", input$hour); 
  #setwd("/home/deepak/Data Logs/Minerva/Approach2");
  dt= read.csv(gzfile(fn),header=FALSE,sep=",");
  names(dt)=c('session','query');
  cnt=sqldf("select count(distinct session||query) from dt");
  str=paste("select lower(query) as query,count(*)*1.00/",cnt," as cnt from (select distinct query,session from dt) group by 1 order by (count(*)*1.00/",cnt,") desc limit 100");
  a=sqldf(str);
  str1=paste("select lower(query) as query,count(*) as cnt from (select distinct query,session from dt) group by 1 order by count(*) desc limit 100");
  a1=sqldf(str1);

  

  fn=sprintf("terms_H%02d.txt.gz", input$hour - 1); 
  dt=read.csv(gzfile(fn),header=FALSE,sep=",");
  names(dt)=c('session','query');
  cnt=sqldf("select count(distinct session||query) from dt");
  str=paste("select lower(query) as query,count(*)*1.00/",cnt," as cnt from (select distinct query,session from dt) group by 1 order by (count(*)*1.00/",cnt,")  desc limit 1000");
  b=sqldf(str);
  str1=paste("select lower(query) as query,count(*) as cnt from (select distinct query,session from dt) group by 1 order by count(*) desc limit 1000");
  b1=sqldf(str1);
  
  res=sqldf("select a.query,(a.cnt - ifnull(b.cnt,0)) as diff from a left outer join b on a.query = b.query order by (a.cnt - ifnull(b.cnt,0)) desc");
  res1=sqldf("select query,diff from res order by diff desc limit 10");
  out=sqldf("select a.query as Term,round(a.diff*100,3) as Diff,c.cnt as 'Prev Hour',b.cnt as 'Cur Hour' from res1 a,a1 b,b1 c where a.query = b.query and a.query = c.query");
  })

   #ggplot(interim,aes(x=hour,y=cnt,group=query))  +geom_line()
  


  algo2= reactive ({
    
    names(complete)=c('hour','user','query');
    
    top_this_hour=sqldf(paste("select lower(query) as query,count(distinct user) as cnt from complete where hour = ",input$hour," group by lower(query) order by count(distinct user) desc limit 100"));
    same_last_hour=sqldf(paste("select lower(query) as query,count(distinct user) as cnt from complete where hour = ",input$hour - 1," and lower(query) in (select query from top_this_hour) group by 1"));
    complete1=sqldf("select hour,lower(query) as query,count(distinct user) as cnt from complete where lower(query) in (select query from top_this_hour) group by 1,2 ");
    mean_sd=sqldf("select query,avg(cnt) as mean,stdev(cnt) as sd from complete1 group by 1 order by mean desc");
    
    top_this_hour_z=sqldf("select a.query, ((cnt - mean)/sd) as z from top_this_hour a left outer join mean_sd b on a.query = b.query");
    same_last_hour_z=sqldf("select a.query, ((cnt - mean)/sd) as z from same_last_hour a left outer join mean_sd b on a.query = b.query");
    top=sqldf("select a.query,a.z - b.z from top_this_hour_z a left outer join same_last_hour_z b on a.query = b.query where b.query is not null order by (a.z - b.z) desc limit 100");
    
    final=sqldf("select a.query, b.cnt as 'actual_11hr',c.cnt as 'actual_10hr',d.z as 'z_11hr', e.z as 'z_10hr', f.mean, f.sd, (d.z - e.z) as 'diff_z' 
      from top a
      left outer join top_this_hour b
      on a.query = b.query 
      
      left outer join same_last_hour c
      on a.query = c.query 
            
      left outer join top_this_hour_z d
      on a.query = d.query 

      left outer join same_last_hour_z e
      on a.query = e.query 

      left outer join mean_sd f
      on a.query = f.query 
            
      group by 1,2,3,4,5,6,7,8 order by (d.z -e.z) desc");
    ouot=sqldf("select query as 'Term', round(diff_z,2) as Diff, actual_10hr as 'Prev Hr Count',actual_11hr as 'Cur Hr Count' from final order by Diff desc");
    
  })
  
  wc=reactive ({
    names(complete)=c('hour','user','query');
    tp=sqldf(paste("select lower(query) as query,count(distinct user) as cnt from complete where hour = ",input$hour," group by lower(query) order by count(distinct user) desc limit 50"));
    
  })
  
  f=reactive({
    if (input$algo == 1)
      x()
    else
      algo2()
    
  })
  
  
  if(TRUE)
  {
    output$chart1=renderChart2({
    names(complete)=c('hour','user','query');
    if (input$algo ==1) {
      ou=x(); }
    else
      { ou=f() }
    interim=sqldf("select hour,lower(query) as query,count(distinct user) as cnt from complete where lower(query) in (select lower(Term) from ou order by Diff desc limit 5) group by 1,2")
    p2 <- rPlot(x='hour',y='cnt',color='query', type = 'line', data = interim);
    return(p2);  
  })
  
  }
  
  if(FALSE) {
  output$chart1 <- renderGvis({
    names(complete)=c('hour','user','query');
    if (input$algo ==1) {
      ou=x(); }
    else
    { ou=f() }
    interim=sqldf("select hour,lower(query) as query,count(distinct user) as cnt from complete where lower(query) in (select lower(Term) from ou order by Diff desc limit 5) group by 1,2")
    dr=cast(interim,hour  ~ query)
   dr[is.na(dr)] <- 0
    c=names(dr[,2:6]);
    myoptions =  list(legend="bottom",width="800",height="300");
    gvisLineChart(dr,xvar="hour",yvar=c,options=myoptions)
  })
  }
  
  output$wordcl= reactivePlot(function(){ 
    zz=wc();
    wordcloud(zz$query,zz$cnt,main="Top 50 Searches");
    
  });
  
  output$mytable=DT::renderDataTable(f(), options = list(
    pageLength = 5,
    initComplete = JS("
    function(settings, json) {
      $(this.api().table().header()).css({
        'background-color': '#000',
        'color': '#fff'
      });
    }")
  ));
  #DT::datatable(a1,pageLength = 5)    
  
})