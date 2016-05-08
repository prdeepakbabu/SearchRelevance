library(HMM)
library(wordnet)
states=c("S","X","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
symbols=c("S","X","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
startingProbabilities=c(1,  0,  0,	0,	0,	0,	0,	0,	0,	0,	0, 0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0);
emissionProbabilities=diag(28)
colnames(emissionProbabilities)=states
rownames(emissionProbabilities)=symbols
calculateTransitionProbabilities = function(data,states)
{
  
  transitionProbabilities = matrix(0,length(states),length(states))
  colnames(transitionProbabilities) = states
  rownames(transitionProbabilities) = states
  
  for (index in 1:(length(data)-1)) {
    current_state = data[index]
    next_state = data[index+1]
    transitionProbabilities[current_state,next_state] = transitionProbabilities[current_state,next_state] + 1
  }
  
  transitionProbabilities = sweep(transitionProbabilities,1,rowSums(transitionProbabilities),FUN= "/")
  return(transitionProbabilities)
}

#read hindi
hindi=read.csv("hindiwords2.txt",header=F)
hindi=(hindi[,1])
hindi=strsplit(as.character(paste("S",tolower(hindi),"X",sep="")),"")
obs= Reduce(function(x,y) c(x,y), hindi,c())
transprobhindi=calculateTransitionProbabilities(obs,states)
h=initHMM(states,symbols,startProbs =startingProbabilities , transProbs= transprobhindi, emissionProbs = emissionProbabilities)

#read english
english=read.csv("englishwords2.txt",header=F)
english=(english[,1])
english=strsplit(as.character(paste("S",tolower(english),"X",sep="")),"")
obs= Reduce(function(x,y) c(x,y), english,c())
transprobeng=calculateTransitionProbabilities(obs,states)
e=initHMM(states,symbols,startProbs =startingProbabilities , transProbs= transprobeng, emissionProbs = emissionProbabilities)


predict=function(x,hlt_hindi,hlt_english)
{
  query=x
  test=strsplit(as.character(paste("S",tolower(query),"X",sep="")),"")
  out=exp(forward(h,test[[1]]))
  ln=nchar(query)
  prob_h = sum(out[,ln])
  out=exp(forward(e,test[[1]]))
  ln=nchar(query)
  prob_e = sum(out[,ln])
  if (prob_e > prob_h)
  {
    #return(paste("English : Delta = ",prob_e - prob_h,sep=""));
    if ( prob_e == 0) { prob_e = 0.000000000000001}
    if ( prob_h == 0) { prob_e = 0.000000000000001}
    if( hlt_english == TRUE)
    { return(list(prob_e,prob_h,paste("<font color='blue'>",x,"</font>",sep=""),"E")) }
    else
    { return(list(prob_e,prob_h,paste("<font color='grey'>",x,"</font>",sep=""),"E") )   }
  }
  else if( prob_e == prob_h)
  {
    #return(list(prob_e,prob_h,paste("Sorry ! Unable to predict language for ",x,sep="")) )
    prob_e = 1;
    prob_h = 1;
    return(list(prob_e,prob_h, paste("<font color='grey'>",x,"</font>",sep=""),"U"  ) )
  }
  else
  {
    #return(paste("Hindi  : Delta = ",prob_e - prob_h,sep=""))
    if ( prob_e == 0) { prob_e = 0.000000000000001}
    if ( prob_h == 0) { prob_e = 0.000000000000001}
    
    if( hlt_hindi == TRUE)
    { return(list(prob_e,prob_h,paste("<font color='red'>",x,"</font>",sep=""),"H") ) }
    else
    { return(list(prob_e,prob_h,paste("<font color='grey'>",x,"</font>",sep=""),"H") )  }
  }
}

shinyServer(function(input, output) {
  output$test = renderUI ({
    q=gsub("[^a-z ]","",tolower(input$search))
    words = strsplit(q,' ')[[1]] 
    ln = length(words);
    probe = 1
    probf = 1
    result = ""
    hindi =0
    english =0
    unknown = 0
    for (i in words)
    {        
        a = predict(i,input$hindi,input$english);
        probe = probe * a[[1]][1];
        probf = probf * a[[2]][1];
        result = paste(result,a[[3]][1],sep=" ");        
        if ( a[[4]][1] == 'E') { english = english + 1}
        if ( a[[4]][1] == 'H') { hindi = hindi + 1}
        if ( a[[4]][1] == 'U') { unknow = unknown + 1}
    }
    if ( probe > probf)
    {
      if ( hindi == 0){HTML(paste("That looks like English Text !<br>",result,sep="")) }
      else {HTML(paste("That looks mostly english text, but also has some hindi words !<br>",result,sep="")) }
        
    }
    else if (probf > probe) 
    {
      if ( english == 0){  HTML(paste("That looks like Hindi Text !<br>",result,sep="")) }
      else {HTML(paste("That looks mostly hindi text, but also has some english words !<br>",result,sep="")) }
    }      
    else
    {
      HTML(paste("Sorry ! Unable to detect language. Try something else!<br>",result,sep=""))
    }      
    
    if ( probe > probf)
    {
      if ( hindi == 0){HTML(paste("<br>Detected Language : English<br>",result,sep="")) }
      else {HTML(paste("<br>Detected Language : Mixed<br>",result,sep="")) }
      
    }
    else if (probf > probe) 
    {
      if ( english == 0){  HTML(paste("<br>Detected Language : Hindi<br>",result,sep="")) }
      else {HTML(paste("<br>Detected Language : Mixed<br>",result,sep="")) }
    }      
    else
    {
      HTML(paste("<br>Sorry ! Unable to detect language. Try something else!<br>",result,sep=""))
    }          
    
    
    
  })
})



