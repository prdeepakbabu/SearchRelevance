setwd("/home/deepak/Documents/Projects/QUL Labeling Model/NER")
library(sqldf);
a=read.csv("vis_20160422.csv");
colnames(a)=c('query','vis','ord');
b=sqldf("select lower(replace(replace(query,'WAP:',''),'wap:','')) as query,vis  from a")
c=sqldf("select query,sum(vis) as vis from b group by 1")
d=sqldf("select query from c where vis > 5 order by vis desc")
write.csv(d$query,"queries.txt")
write.csv(d$query,"queries.txt",row.names=F)
