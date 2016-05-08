library(HMM)
library(wordnet)
states=c("S","X","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
symbols=c("S","X","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
startingProbabilities=c(1,  0,	0,	0,	0,	0,	0,	0,	0,	0,	0, 0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0);
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
setwd("/home/deepak/Documents/Projects/HMM")
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


query="mobile"
test=strsplit(as.character(paste("S",tolower(query),"X",sep="")),"")
out=exp(forward(h,test[[1]]))
ln=nchar(query)
prob_h = sum(out[,ln])
out=exp(forward(e,test[[1]]))
ln=nchar(query)
prob_e = sum(out[,ln])
prob_e
prob_h

predict=function(x)
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
    return(paste("English : Delta = ",prob_e - prob_h,sep=""));
  }
  else if( prob_e == prob_h)
  {
    return(paste("Sorry ! Unable to predict language for ",x,sep=""))
  }
  else
  {
    return(paste("Hindi  : Delta = ",prob_e - prob_h,sep=""))
  }
}

predict_prob=function(x,y)
{
  query=x
  test=strsplit(as.character(paste("S",tolower(query),"X",sep="")),"")
  out=exp(forward(h,test[[1]]))
  ln=nchar(query)
  prob_h = sum(out[,ln])
  out=exp(forward(e,test[[1]]))
  ln=nchar(query)
  prob_e = sum(out[,ln])
  if (y == 'E')
  {
    return(prob_e);
  }
  else{
    return(prob_h);
  }
}


predict_sentence=function(x) {
  words=strsplit(x,' ');
  #res_e = character(length(words[[1]]))
  #res_h = character(length(words[[1]]))
  res_e = 1
  res_h = 1
  for(i in words[[1]])
  {
    res_e = res_e * predict_prob(i,"E");
    res_h = res_h * predict_prob(i,"H");    
  }
  if (res_e > res_h)
  {
    return(paste("English",sep=""));
  }
  else if( res_e == res_h)
  {
    return(paste("Sorry ! Unable to predict language for ",x,sep=""))
  }
  else
  {
    return(paste("Hindi",sep=""))
  }
}


