library("tm");
library("qdap"); #tricky
library("stringr");
library("SnowballC");
library(data.table);
library("sqldf");
library("R2HTML");

setwd("/home/deepak/Documents/Projects/Analytics/Input");
library(sqldf)
temp = list.files(pattern="20160.*");
z=sort(temp);
x1=z[(length(temp)-13):(length(temp)-7)]
x2=z[(length(temp)-6):(length(temp)-0)]
week0 = do.call(rbind, lapply(x1, function(x) read.csv(paste(x,"/Top10k.csv",sep=""), header=T)));
week1 = do.call(rbind, lapply(x2, function(x) read.csv(paste(x,"/Top10k.csv",sep=""), header=T)));
agg_w0 = sqldf("select replace(query,'&#x20;',' ') as query,avg(CTR) as CTR,avg(CVR) as CVR, sum(Visits) as Visits from week0 group by 1");
source("../Logic/Helper_functions.R");
agg_w0$signature = "";
for(i in 1:nrow(agg_w0)) { agg_w0[i,5] = signature(agg_w0[i,1]);}
agg_w1 = sqldf("select replace(query,'&#x20;',' ') as query,avg(CTR) as CTR,avg(CVR) as CVR, sum(Visits) as Visits from week1 group by 1");
agg_w1$signature = "";
for(i in 1:nrow(agg_w1)) { agg_w1[i,5] = signature(agg_w1[i,1]);}

agg_w00 = sqldf("select signature,group_concat(query) as query ,avg(CTR) as CTR,avg(CVR) as CVR, sum(Visits) as Visits from agg_w0 group by 1");
agg_w11 = sqldf("select signature,group_concat(query) as query ,avg(CTR) as CTR,avg(CVR) as CVR, sum(Visits) as Visits from agg_w1 group by 1");

z=sqldf("select case when a.query != substr(a.query,0,100) then substr(a.query,0,100)||'...' else a.query end as query,a.Visits,a.CTR,a.CVR from (agg_w11) a left outer join (agg_w00) b on a.signature = b.signature where b.signature is null order by a.Visits desc limit 20");
#=========================================================================================
query,no.of.words,pog,rank,clickshare

if no. of words > 4 then rank =1 clickshare < 50% | bad
if b/n two days - pog in rank(1,2,3) not in rank(1,2,3 next day) with clickshare(1) > 50% | bad

