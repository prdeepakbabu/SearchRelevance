data <- read.csv("searchterms.dat",header=FALSE,col.names=c('terms'));
freq <- sqldf("select terms,count(*) as cnt from data group by 1 having count(*) > 50 order by count(*) desc");

#tdf
corpus=Corpus(VectorSource(data$terms));

library(tm);
library(sqldf);
setwd("/home/deepak/Downloads/Rplay");
data <- read.csv("1hr_2300.dat",header=FALSE,col.names=c('terms'));
freq <- sqldf("select replace(trim(terms),' ','_') as terms,count(*) as cnt from data group by 1 having count(*) > 10 order by count(*) desc");

#wordcloud
install.packages("wordcloud");
library("wordcloud");
install.packages("RColorBrewer");
library("RColorBrewer");

set.seed(1234);
wordcloud(words = freq$terms, freq = freq$cnt, min.freq = 1,
          max.words=50, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"));

#tdf    
corpus=Corpus(VectorSource(data$terms));
  
#create tdm                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
dtm <- DocumentTermMatrix(corpus);      
inspect(dtm[1:10, 0:10]);            
fr<-colSums(as.matrix(dtm));


###########################################
# FIND KEYWORDS(RARE) WORDS USING TF-IDF
##########################################

data <- read.csv("1hr_2300.dat",header=FALSE,col.names=c('terms'));
freq <- sqldf("select replace(trim(terms),' ','_') as terms,count(*) as cnt from data group by 1 order by count(*) desc limit 50");
freq1 <- sqldf("select replace(trim(terms),' ','_') from data where replace(trim(terms),' ','_') in (select terms from freq) ");
write.table(freq1,file="file_23H.csv",row.names=FALSE,quote=FALSE,col.names=FALSE);


cname=file.path(".","corpus");
dir(cname);
docs=Corpus(DirSource(cname));
dtm <- DocumentTermMatrix(docs);   

tfidf=weightTfIdf(dtm,normalize=TRUE);
inspect(tfidf);
v=tfidf[1,];              

            
################# VERSION 2 ###############
overall <- read.csv("cons.csv",header=FALSE,col.names=c('terms'));
oall <- sqldf("select distinct replace(trim(terms),' ','_') as terms from overall ");

data <- read.csv("1hr_2300.dat",header=FALSE,col.names=c('terms'));
#freq <- sqldf("select replace(trim(terms),' ','_') as terms,count(*) as cnt from data group by 1 order by count(*) desc limit 50");
freq1 <- sqldf("select replace(trim(terms),' ','_') from data where replace(trim(terms),' ','_') in (select terms from oall) ");
write.table(freq1,file="file_23H.csv",row.names=FALSE,quote=FALSE,col.names=FALSE);


cname=file.path(".","corpus");
dir(cname);
  docs=Corpus(DirSource(cname));
  dtm <- DocumentTermMatrix(docs);   
  
      tfidf=weightTfIdf(dtm,normalize=TRUE);
  inspect(tfidf);
  v=tfidf[1,];

