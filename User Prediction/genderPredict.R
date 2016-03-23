library(sqldf);
library(rjson);
library(RCurl);
library(tm);
library(SnowballC);
setwd("/media/deepak/OS");
ds=read.csv("queries_5dnew1.csv",sep="|")
names(ds)=c('email','keyword');
user=read.csv("userpref.txt",sep="|",quote="");
remaining=read.csv("remaining.csv",sep=",");

comp=sqldf("select a.*,replace(b.keyword,' ,',',')as keyword from user a,ds1 b where a.email = b.cleanq");
comp1=sqldf("select a.*,case when b.inferred_gender == 'male' then 'm' when b.inferred_gender== 'female' then 'f' else 'NULL' end as inferred_gender from comp a left outer join remaining b on a.first_name = b.first_name")
comp2=sqldf("select *,case when gender != 'NULL' then gender when gender == 'NULL' and inferred_gender != 'NULL' then inferred_gender else 'NULL' end as clean_gender,case when birthday != 'NULL' then (date('now') - birthday) else null end as age from comp1");
search_cnt = sapply(comp2$keyword,function(x) getWordCount(paste(x)));
comp3=cbind(comp2,search_cnt);

#gender analysis
gndr=sqldf("select * from comp3 where clean_gender != 'NULL' ");
m=sqldf("select * from comp3 where clean_gender = 'm'");
f=sqldf("select * from comp3 where clean_gender = 'f'");

getWordCount = function(x) {   return(length((strsplit(x,','))[[1]]))  }
mfreq=sapply(m$keyword,function(x) getWordCount(paste(x)));
ffreq=sapply(f$keyword,function(x) getWordCount(paste(x)));

plot1=qplot(as.numeric(m$age), geom="histogram",fill=I("red"),col=I("black"),xlim=c(0,75)) ;
plot2=qplot(as.numeric(f$age), geom="histogram",fill=I("blue"),col=I("black"),xlim=c(0,75));
multiplot(plot1, plot2, cols=2)

plot1=qplot(as.numeric(m$search_cnt), geom="histogram",fill=I("red"),col=I("black"),xlim=c(0,75)) ;
plot2=qplot(as.numeric(f$search_cnt), geom="histogram",fill=I("blue"),col=I("black"),xlim=c(0,75));
multiplot(plot1, plot2, cols=2)

#age analysis


qplot(as.numeric(comp3$search_cnt), geom="histogram",fill=I("red"),col=I("black"),xlim=c(0,30))


names(ds)=c('email','keyword');
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
cleanq=sapply(ds$email,function(x) trim(gsub("\"","",x)));
ds1=cbind(ds,cleanq);

#read user data
user=read.csv("userpref.txt",sep="|",quote="");
i=0;
getGender <- function(name)
{
  name1=gsub(' ','/',name);
  url=paste("http://api.namsor.com/onomastics/api/json/gender/",name1,"/in",sep="");
  tmp=getURL(url);
  return(fromJSON(tmp)$gender);
}

sleep <- function(x)
{
  p1 <- proc.time()
  Sys.sleep(x)
  proc.time() - p1 # The cpu usage should be negligible
}
sleep(5)

inferred=sapply(user$first_name,function(x) getGender(x));

jon=sqldf("select a.gender,b.keyword from user a, ds1 b where a.email = b.cleanq and a.gender in ('m','f')")
#remaining=sqldf("select distinct a.cleanq from ds1 a left outer join user b on a.cleanq = b.email where b.email is null and b.gender = 'NULL'")
remaining=sqldf("select distinct email,first_name from user where gender = 'NULL' ")
m=sqldf("select keyword from jon where gender = 'm'");
f=sqldf("select keyword from jon where gender = 'f'");
m1=sample(m$keyword,size=10000)
f1=sample(f$keyword,size=10000)
write.csv(sample(m$keyword,size=10000),"msearches.csv",row.names=F);
write.csv(f,"fsearches.csv",row.names=F);

remaining['inferred_gender']='NULL';
#for(i in 6732:nrow(em)) { em[i,c('gender')] = getGender(paste(em[i,c('url')]));}
#4817
for(i in 317:nrow(remaining)) { remaining[i,c('inferred_gender')] = getGender(remaining[i,c('first_name')]);}


setwd("/media/deepak/OS/genderpred");
cname=file.path(".");
# dir(cname);
docs=Corpus(DirSource(cname));
doc.corpus <- tm_map(docs, tolower)
doc.corpus <- tm_map(doc.corpus, removePunctuation)
doc.corpus <- tm_map(doc.corpus, removeNumbers)
doc.corpus <- tm_map(doc.corpus, removeWords,stopwords("english"))
doc.corpus <- tm_map(doc.corpus, stemDocument)
doc.corpus <- tm_map(doc.corpus, stripWhitespace)
doc.corpus <- tm_map(doc.corpus, PlainTextDocument)
dtm <- TermDocumentMatrix(doc.corpus,control = list(dictionary=z));   
#dtmred = removeSparseTerms(dtm,0.8);
tfidf=weightTfIdf(dtm,normalize=TRUE);
a=data.frame(as.matrix(tfidf));
b=cbind(row.names(a),a);
names(b)=c('query','f','m');
c=sqldf("select * from b order by f desc limit 50");

tf=data.frame(inspect(dtm))
d=cbind(row.names(tf),tf)
names(d)=c('query','f','m');
tfidf=weightTfIdf(dtm,normalize=TRUE);
inspect(tfidf);
v=tfidf[1,];              

z=inspect(tfidf);
a=cbind(colnames(z),z[1,],z[2,])
b=data.frame(a);
names(b)=c('query','f','m')
c=sqldf("select max(")
write.csv(a,"../tfidf",row.names=F)

z=sqldf("select query from d where f > 10 union select query from d where m > 10")
names(z)=z
xyz=sqldf("select *,log(1+m)*(case when f > 0 then 1 else 2 end) as tm,log(1+f)*(case when m > 0 then 1 else 2 end) as tf  from d where query in (select query from z)");
sqldf("select * from xyz order by tf-tm desc limit 70")


xyz1=sqldf("select *,log(1+m) * log(1+m)*(case when f > 0 then 1 else 2 end) as tm,log(1+f) * log(1+f)*(case when m > 0 then 1 else 2 end) as tf  from d where query in (select query from z)");
xyz2=sqldf("select *,tf*(tf-tm) as imp,tf*1.00/(tf+tm) as prop from xyz1 order by tf*(tf-tm) desc");


fem=sqldf("select *,tf*(tf-tm) as imp,tf*tf*1.00/(tf+tm) as prop from xyz1 order by imp desc limit 20");
men=sqldf("select *,tm*(tm-tf) as imp from xyz1 order by imp desc limit 20");

z=sqldf("select distinct first_name from user where gender == 'NULL'");
remaining=z;
remaining['inferred_gender']='NULL';
#for(i in 663:nrow(em)) { em[i,c('gender')] = getGender(paste(em[i,c('url')]));}
#4817
for(i in 15402:nrow(remaining)) { xyz <- tryCatch({flag <- TRUE; if(eval(parse(text=paste(i,'%%50',sep=''))) == 0) write.csv(remaining,'/media/deepak/OS/remaining1.csv',row.names=F); remaining[i,c('inferred_gender')] = getGender(remaining[i,c('first_name')])},error=function(e){message(e);Sys.sleep(500);});
                                   if(inherits(xyz, "error")) next
}


getWordCount = function(x)
{
  #(tryCatch({return(length((strsplit(x,','))[[1]]))},error =function(e) {return(-1)}))
  return(length((strsplit(x,','))[[1]]))
  
}
mfreq=sapply(m$keyword[1:4],function(x) getWordCount(paste(x));
ffreq=sapply(f$keyword,function(x) getWordCount(x));



multiplot <- function(..., plotlist=NULL, cols) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # Make the panel
  plotCols = cols                          # Number of columns of plots
  plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols
  
  # Set up the page
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
  vplayout <- function(x, y)
    viewport(layout.pos.row = x, layout.pos.col = y)
  
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(plots[[i]], vp = vplayout(curRow, curCol ))
  }
  
}