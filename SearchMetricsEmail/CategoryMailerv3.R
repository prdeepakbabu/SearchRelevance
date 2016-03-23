library("tm");
#library("qdap");
library("stringr");
library("SnowballC");
library(data.table);
library("sqldf");
library("R2HTML");

#args=c('/home/deepak/Documents/Projects/Analytics/Input/20160206/','vis_20160206.csv','clk_20160206.csv','final_output.txt')
#args=c('/home/deepak/Documents/Projects/Analytics/Input/20160206/','vis_20160206.csv','clk_20160206.csv','final_output.txt');

#read files
args <- commandArgs(trailingOnly = TRUE);
path=args[1];
fl1=args[2];
fl2=args[3];
vis_path=paste(path,fl1,sep='');
clk_path=paste(path,fl2,sep='');
setwd(path);
clicks=read.csv(file=clk_path);
visits=read.csv(file=vis_path);
names(visits)=c("query","imp","ord");
names(clicks)=c("query","clk");

#source helper functions
source("../../Logic/Helper_functionsv1.R");

#process
top1000=sqldf("select lower(replace(query,'wap:','')) as query from visits group by 1 order by sum(imp) desc limit 25000");
top1000$signature = "";
for(i in 1:nrow(top1000)) { top1000[i,2] = signature(top1000[i,1]);}
v=sqldf("select lower(replace(query,'wap:','')) as query,sum(imp) as imp,sum(ord) as ord from visits where lower(replace(query,'wap:','')) in (select lower(replace(query,'wap:','')) from top1000) group by 1 order by sum(imp) desc");
v1=sqldf("select a.*,b.signature from v a, top1000 b where a.query = b.query");
vt=data.table(v1);
z=vt[,rank:=rank(-imp),by=signature];
qs=sqldf("select query,signature from z where rank=1");
v2=sqldf("select signature,sum(imp) as imp,sum(ord) as ord from v1 group by signature");
c=sqldf("select lower(replace(query,'wap:','')) as query,sum(clk) as clk from clicks where lower(replace(query,'wap:','')) in (select lower(replace(query,'wap:','')) from top1000) group by 1 order by sum(clk) desc ");
c1=sqldf("select a.*,b.signature from c a, top1000 b where a.query = b.query");
c2=sqldf("select signature,sum(clk) as clk from c1 group by 1");
final=sqldf("select a.signature,(clk*100.00/imp) as CTR,(ord*100.00/clk) as CVR, imp as Visits from v2 a,c2 b where a.signature = b.signature order by imp desc");
final1=sqldf("select a.*,b.query from final a,qs b where a.signature = b.signature order by ctr asc ");
allq=sqldf("select signature,group_concat(query) as grpquery from top1000 group by 1");
final2=sqldf("select a.*,b.grpquery from final1 a, allq b where a.signature = b.signature");

#enrich with category and super-category
fl3=args[4];
#path="../";
path="";
pogcat_path=paste(path,fl3,sep='');
catpog=read.csv(pogcat_path,sep="|");
#catpog1=sqldf("select query,supercategory, case when trim(supercategory) = 'Electronics' and trim(subcategory_name) = 'Mobile Phones' then 'Mobiles' when trim(supercategory) = 'Electronics' and trim(subcategory_name) != 'Mobile Phones' then 'RoE' else supercategory end as custom from catpog group by 1,2");
catpog1=sqldf("select query,supercategory, case when trim(supercategory) = 'Electronics' and trim(subcategory_name) in ('Mobile Phones','Mobile Cases & Covers','Mobile Screen Guards') then 'Mobiles' when trim(supercategory) = 'Electronics' and trim(subcategory_name) not in ('Mobile Phones','Mobile Cases & Covers','Mobile Screen Guards') then 'RoE' when trim(supercategory) = 'Fashion Core' and trim(category_name) in ('Men''s Clothing','Men''s Footwear') then 'Men''s Fashion' when trim(supercategory) = 'Fashion Core' and trim(category_name) in ('Women''s Clothing','Women''s Ethnic Wear','Women''s Footwear') then 'Women''s Fashion' when trim(supercategory) = 'Fashion Core' and trim(category_name) in ('Kids Apparel & Accessories','Kids Footwear') then 'Kids Fashion' when trim(supercategory) = 'Fashion Core' and trim(category_name) not in ('Kids Apparel & Accessories','Kids Footwear','Men''s Clothing','Men''s Footwear','Women''s Clothing','Women''s Ethnic Wear','Women''s Footwear') then 'RoF'  else supercategory end as custom from catpog group by 1,2");
catpog_sub=sqldf("select trim(query) as query,trim(supercategory) as supercategory,trim(custom) as custom from catpog1 where trim(query) in (select query from final2) ");
final3=sqldf("select a.*,case when b.custom is null then 'Unclassified' else b.custom end as supercategory from final2 a left outer join catpog_sub b where a.query = b.query");
z=sqldf("select distinct custom from catpog_sub");
sc=as.vector(z$custom);
sc[length(sc)+1]='Unclassified';
write.csv(final3,"ds1.csv");

#YESTERDAY DATA
tmp=args[1];
x=substr(tmp,nchar(tmp)-8,nchar(tmp)-1);
today=x;
year=substr(x,1,4);
mon=substr(x,5,6);
day=substr(x,7,8);
final_date=paste(year,mon,day,sep="-");
strvar=paste("select date('",final_date,"','-1 day')",sep="")
yest1=sqldf(strvar);
yest2=yest1[1,1];
yest=gsub("-","",yest2);
base_path=substr(args[1],0,nchar(args[1])-9);
yest_path=paste(base_path,yest,sep="");
yest_data=read.csv(paste(yest_path,"ds1.csv",sep="/"))
final4=sqldf("select a.*,b.CTR as yest_CTR,(a.CTR - b.CTR)/b.CTR as delta_ctr from final3 a, (select distinct signature,CTR from yest_data) b where a.signature = b.signature");

#set the output folder
dt=sqldf("select date('now','-1 day') as dt");
x=dt[1,1];
tmp=args[1];
x=substr(tmp,nchar(tmp)-8,nchar(tmp)-1);
yes=gsub('-','',x);
path=paste("../../Output/",yes,sep="");
dir.create(path, showWarnings = FALSE)
setwd(path);

header="<ul style='font: 12px arial, sans-serif;'><li>Queries shown below includes those with CTR < 20%. Data Source: Omniture</li><li>Topic is a normalized version of search query entered by the user. It takes care of stemming, case-variations and word ordering. For example: sport shoes, Sport Shoes and Shoes Sport, sport shoe all will be treated as a bundle and assigned top searched query as its topic.</li><li>Daily Visits is total searches made, CTR aka click-through-rate indicates ratio of clicks to impressions, CVR aka conversion rate indicates ration of orders to clicks</li>         <li>Component Queries indicates list of similar queries which makes the topic.</li><li>Priority = Visits * (1-CTR) indicates one possible ranking strategy for poor-performing queries.</li><li>The data shown below covers all platforms (web/app/wap)</li><li>Category is inferred based on category of top clicked product for the search term</li></ul>";


#html formatting and output
for(i in 1:length(sc))
{
sc[i]=gsub("'","''",sc[i])
filename=paste(gsub(" ","",sc[i]),".html",sep="");
newfl=paste("raw_",filename,".csv",sep="");
HTML("<head><style>.customers {     font-family: 'Trebuchet MS', Arial, Helvetica, sans-serif;  font-size:small;   border-collapse: collapse;     width: 100%; }  .customers td, #customers th {     border: 1px solid #ddd;     text-align: left;     padding: 8px; }  .customers tr:nth-child(even){background-color: #f2f2f2}  .customers tr:hover {background-color: #ddd;}  .customers th {     padding-top: 12px;     padding-bottom: 12px;     background-color: #4CAF50;     color: white; }</style></head><body>",filename);
#out1=sqldf("select query,CTR,CVR,Visits,supercategory,grpquery from final3 where ctr < 20 order by Visits desc limit 20 ");
out2=sqldf(paste("select query as Topic,Visits as '  Daily Visits  ',CTR as 'CTR<br>",today,"(%)',yest_CTR as 'CTR<br>",yest,"(%)',delta_ctr * 100 as '%Chng in <br>CTR(D/D)(%)',grpquery as 'Component<br>Queries',-1*Visits*delta_CTR as 'Priority' from final4 where ctr < 20 and supercategory = '",sc[i],"' and delta_ctr <  -0.5 order by ( delta_ctr * visits) limit 20 ",sep=""));
out3=sqldf(paste("select query as Topic,Visits as '  Daily Visits  ',CTR as 'CTR<br>",today,"(%)',yest_CTR as 'CTR<br>",yest,"(%)',delta_ctr * 100 as '%Chng in <br>CTR(D/D)(%)',grpquery as 'Component<br>Queries',-1*Visits*delta_CTR as 'Priority' from final4 where supercategory = '",sc[i],"' and delta_ctr >  0.5 order by (delta_ctr * visits) desc limit 20 ",sep=""));
out1=sqldf(paste("select query as Topic,Visits as '  Daily Visits  ',CTR as 'CTR<br>(%)',CVR as 'CVR<br>(%)',grpquery as 'Component<br>Queries',Visits*(100-CTR)*0.01 as 'Priority' from final3 where ctr < 20 and supercategory = '",sc[i],"' order by Priority desc limit 20 ",sep=""));
out4=sqldf(paste("select  case when CTR between 0 and 5 then '00-05' when CTR between 5 and 10 then '05-10' when CTR between 10 and 15 then '10-15' when CTR between 15 and 20 then '15-20' else 'Unclassified' end as CTRBucket, count(distinct signature) as Count from final3 where supercategory = '",sc[i],"' and CTR < 20 group by 1  union select 'Total' as CTRBucket,count(distinct signature) as Count from final3 where supercategory = '",sc[i],"' and CTR < 20 ",sep=""));
outcomplete=sqldf(paste("select query as Topic,Visits as '  Daily Visits  ',CTR as 'CTR<br>(%)',CVR as 'CVR<br>(%)',grpquery as 'Component<br>Queries',Visits*(100-CTR)*0.01 as 'Priority' from final3 where ctr < 20 and supercategory = '",sc[i],"' order by Priority desc",sep=""));
write.csv(outcomplete,newfl);
#out1$Topic=apply(out1$Topic,1,sdsearch_href);
#HTML(paste("<h1>",sc[i],"</h1>",sep=""),"dummy.html");
tryCatch({out1$Topic=sdsearch_href(out1$Topic)},error=function(e) {e});
HTML(paste("<h3 align='left'  style='font: 18px arial, sans-serif;'><b>",paste("Poor-Performing Search Queries - ",sc[i],sep=""),"</b></h2>",sep=""),filename);
HTML(header,filename);
HTML("<h3>(1) Top Losers Today (Based on %Chng CTR D/D) </h3>",filename);
tryCatch({out2$Topic=sdsearch_href(out2$Topic)},error=function(e) {e});
tryCatch(HTML(out2,filename,border=0,innerBorder=1,digits=2,align="left",
              big.mark = getOption("R2HTML.format.big.mark"),
              big.interval = getOption("R2HTML.format.big.interval"),
              decimal.mark = ".",
              nsmall = getOption("R2HTML.format.nsmall"), captionalign = "top",
              classcaption = "customers",classtable="customers"),error=function(e) {e})

HTML("<h3>(2) Top Gainers Today (Based on %Chng CTR D/D) </h3>",filename);
tryCatch({out3$Topic=sdsearch_href(out3$Topic)},error=function(e) {e});
tryCatch(HTML(out3,filename,border=0,innerBorder=1,digits=2,align="left",
              big.mark = getOption("R2HTML.format.big.mark"),
              big.interval = getOption("R2HTML.format.big.interval"),
              decimal.mark = ".",
              nsmall = getOption("R2HTML.format.nsmall"), captionalign = "top",
              classcaption = "customers",classtable="customers"),error=function(e) {e})

HTML("<h3>(3) Poor-Performing Queries </h3>",filename);
tryCatch(HTML(out1,filename,border=0,innerBorder=1,digits=2,align="left",
     big.mark = getOption("R2HTML.format.big.mark"),
     big.interval = getOption("R2HTML.format.big.interval"),
     decimal.mark = ".",
     nsmall = getOption("R2HTML.format.nsmall"), captionalign = "top",
     classcaption = "customers",classtable="customers"),error=function(e) {e})
HTML("<h3>(4) Tracking - Query Improvements </h3>",filename);
tryCatch(HTML(out4,filename,border=0,innerBorder=1,digits=2,align="left",
              big.mark = getOption("R2HTML.format.big.mark"),
              big.interval = getOption("R2HTML.format.big.interval"),
              decimal.mark = ".",
              nsmall = getOption("R2HTML.format.nsmall"), captionalign = "top",
              classcaption = "customers",classtable="customers"),error=function(e) {e})

HTML("</body>",filename);
}
















#HTML("<h1>testing</h1>","dummy.html");

#.tabler {   margin-top: 20px;   margin-bottom: 40px;   border-collapse: collapse;   border-spacing: 0;   width: 100%; }  .tabler, .tabler th, .tabler td {   border: none;   text-align: left;   padding: 8px; }  .tabler tbody tr:nth-child(even) {   background-color: #f2f2f2 }

#write.csv(final1,"topicsfinal.csv");


#sqldf("select query as Topic,supercategory as 'Super Category',Visits as 'Daily Visit',CTR,CVR,grpquery as 'Component Queries',Visits*(100-CTR)*0.01 as 'Priority' from final3 where ctr < 20 and supercategory = 'Electronics' order by Priority desc limit 20 ");

