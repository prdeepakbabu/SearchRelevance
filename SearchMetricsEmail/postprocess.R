######################################################
#Example run: postprocess.R "/home/deepak/run_dash/SearchRelevance/SearchMetricsEmail/" "20151115" "20151114"
######################################################
library(sqldf);

#input params
args <- commandArgs(trailingOnly = TRUE);
pth=args[1];
tod=args[2];
yest=args[3];
#pth="/home/deepak/run_dash/SearchRelevance/SearchMetricsEmail/";
#tod="20151115"
#yest="20151114"
ctr_target="55"

#build complete path
today=paste(pth,tod,"/final1.json",sep="");
yesterday=paste(pth,yest,"/final1.json",sep="");
tgt=paste(pth,tod,"/final2.json",sep="");
tgt1=paste(pth,tod,"/trend.csv",sep="");
tgt2=paste(pth,tod,"/chart.csv",sep="");


t=read.csv(today,sep=",");
y=read.csv(yesterday,sep=",");
t$row=rownames(t);
y$row=rownames(y);

a=sqldf("select a.query,a.Impressions,a.Clicks,a.Buys,a.CTR,  a.CVR, ifnull(((a.CTR - b.CTR)*100/b.CTR),'-') as '%Chng CTR(D/D)' from t a left outer join y b on a.query = b.query ");
#trending=sqldf("select group_concat(a.query||'(^'||(b.row - ifnull(a.row,0))||')') from t a,y b where a.query = b.query order by (b.row - ifnull(a.row,0))  desc limit 3");
trending=sqldf("select a.query,(b.row - ifnull(a.row,0)) as diff from t a,y b where a.query = b.query order by (b.row - ifnull(a.row,0))  desc limit 3");
trending_res=sqldf("select group_concat(query||'(^'||diff||')') as qry from trending");
t1=sqldf("select avg(a.ctr)||'%('||round(((avg(a.ctr) - avg(b.ctr))*100/avg(b.ctr)))||'%)' as 'ctr',avg(a.cvr)||'%('||round(((avg(a.cvr) - avg(b.cvr))*100/avg(b.cvr)))||'%)' as 'cvr' from t a,y b")
final=sqldf("select ctr as 'Average CTR', cvr as 'Average CVR', replace(qry,',','|') as 'Trending Today' from t1 a,trending_res b");

givecolor <- function(x)
{ 
if(strtoi(x) > 0 && strtoi(x) <= 20) 
 {tmp=(paste("<b><font color='red'>",(x),"</font></b>"))}
else if(as.numeric(x) > 20 && as.numeric(x) <= 60) 
{tmp=(paste("<font color='black'>",(x),"</font>")) }
else
{tmp=(paste("<b><font color='green'>",(x),"</font></b>"));}
 return(tmp);
} 

givecolorsimple <- function(x)
{ 
  if(strtoi(x) >= 0) 
  {tmp=(paste("<font color='green'>",(x),"</font>"))}
  else
  {tmp=(paste("<font color='red'>",(x),"</font>"));}
  return(tmp);
} 

givemorecolor <- function(x,y)
{ 
  if(strtoi(x) > 0 && strtoi(x) <= 20) 
  {tmp=(paste("<b><font color='red'>",(y),"</font></b>"))}
  else if(as.numeric(x) > 20 && as.numeric(x) <= 60) 
  {tmp=(paste("<font color='black'>",(y),"</font>")) }
  else
  {tmp=(paste("<b><font color='green'>",(y),"</font></b>"));}
  return(tmp);
} 

ctr=sqldf("select round(avg(ctr)) from t");

#https://chart.googleapis.com/chart?chs=300x175&cht=gom&chd=t:30,55&chxt=x,y&chxl=0:|Actual(40%),Target(50%)|1:|0%|100%&chtt=CTR%20(Actual%20vs.%20Target)
ax=paste("<div align='center'><img src='https://chart.googleapis.com/chart?chs=300x175&cht=gom&chd=t:",ctr,",",ctr_target,"&chxt=x,y&chxl=0:|Actual(",ctr,"%),Target(",ctr_target,"%)|1:|0%|100%&chtt=CTR'/></div>",sep='');

#a$CTR=givecolor(a$CTR);
len=length(a$CTR);
x=seq(1,len,1)
for(i in x)
{
  a[i,1]=givemorecolor(a[i,5],a[i,1]);
  a[i,5]=givecolor(a[i,5]);
  a[i,7]=givecolorsimple(a[i,7]);
}
write.csv(a,tgt,row.names=FALSE,quote=FALSE);
write.csv(final,tgt1,row.names=FALSE,quote=FALSE);
write.table(ax,tgt2,row.names=FALSE,col.names=FALSE,quote=FALSE);