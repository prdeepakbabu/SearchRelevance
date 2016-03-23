library("tm");
#library("qdap"); #tricky
library("stringr");
library("SnowballC");
library(data.table);
library("sqldf");
library("R2HTML");
#args=c('/home/deepak/Documents/Projects/Analytics/Input/20160206/','vis_20160206.csv','clk_20160206.csv','final_output.txt')
#args=c('/home/deepak/Documents/P rojects/Analytics/Input/20160206/','vis_20160206.csv','clk_20160206.csv','final_output.txt');
#Rscript Leapv2.R "/data/deepak/Analytics/Input/20160314/" "vis_20160314.csv" "clk_20160314.csv" "final_output.txt"
#Rscript Leapv31.R "/data/deepak/Analytics/Input/20160316/" "vis_20160316.csv" "clk_20160316.csv" "LEAP_Query_Bucket_20160309-20160315.csv"
#set global parameters
n= 7 #no. of days
min_vis= 5 #threshold visits (daily)
top=150 #top queries to return

#read files for the last "n" days
args <- commandArgs(trailingOnly = TRUE);
path=args[1];
fl1=args[2];
fl2=args[3];
fl3=args[4];
setwd(path);
setwd("..");
temp = list.files(pattern="^201603.*");
z=sort(temp);
x1=z[(length(temp)-6):(length(temp)-0)]

#filter for min threshold and apply string transformations
print("Starting Reading raw data");
vis = do.call(rbind, lapply(x1, function(x) read.csv(paste(x,"/vis_",x,".csv",sep=""),sep=",",skip=1, header=F)));
clk = do.call(rbind, lapply(x1, function(x) read.csv(paste(x,"/clk_",x,".csv",sep=""),sep=",",skip=1, header=F)));
names(vis)=c('keyword','visits','orders');
names(clk)=c('keyword','clicks');
vis$visits = as.numeric(vis$visits)
vis1=sqldf("select trim(lower(replace(keyword,'wap:','')))  as keyword,sum(visits) as visits, sum(orders) as orders from vis group by trim(lower(replace(keyword,'wap:',''))) ");
clk1=sqldf("select trim(lower(replace(keyword,'wap:',''))) as keyword,sum(clicks) as clicks from clk group by trim(lower(replace(keyword,'wap:','')))");
ds3=sqldf("select a.keyword,visits,clicks,orders from vis1 a, clk1 b where a.keyword = b.keyword");
ds2=sqldf(paste("select keyword as cleanquery,visits as visitss,clicks,orders,((clicks*100.0)/visits) as CTR,((orders*100.0)/clicks) as CVR from ds3 where visits >",min_vis,sep=""));

#read query-bucket mapping
print("Starting to read query bucket mapping");
setwd(path);
qry_bckt = read.csv(fl3);
names(qry_bckt)=c('query','bucket','visits');
qry_bckt0 = sqldf("select * from qry_bckt where query != '' and bucket != '' ");
tmp1=sqldf("select query,max(visits) as max_visits from qry_bckt0 group by 1");
qry_bckt1=sqldf("select replace(lower(a.query),'&#x20;',' ') as query,a.bucket from qry_bckt0 a,tmp1 b where a.query = b.query and a.visits = b.max_visits group by 1");
#qry_bckt1= sqldf("select lower(query) as query,max(bucket) as bucket from qry_bckt where bucket != '' group by 1");
setwd(path);

#read lookup files
setwd("..");
print("Starting to read bucket and category mappings");
srch_bckt=read.csv("Search_Bucket_Order_Revenue_Visits_PDPVisits.csv",sep=",",skip=23);
names(srch_bckt)=c('Bucket','Orders','Revenue','Visits','Clicks');
bckt=read.csv("Bucket_Order_Revenue_Visits.csv",sep=",");
names(bckt)=c('Bucket','Orders','Visits','Revenue');
bckt_cat = read.csv("BucketCatMappingNew.csv",sep=",",header=T);
#bckt_cat1 = sqldf("select * from bckt_cat where bucket not in (select bucket from bckt_cat group by 1 having count(*) > 1) and bucket != ''")
bucket=sqldf("select a.Bucket,(1.0*a.Revenue)/a.Orders) as AOV,((1.0*b.Revenue)/b.Visits) as RPVb, ((1.00*a.Clicks)/a.Visits) as CTRsb,  ((1.00*b.Orders)/b.Visits) as CVRb , ((1.00*a.Orders)/a.Visits) as CVRsb, ((1.00*a.Revenue)/a.Visits) as RPVsb,c.Category from  srch_bckt a left outer join bckt b on a.Bucket = b.Bucket left outer join bckt_cat c on c.Bucket = b.Bucket")

#read other input data files (QUL)
print("Starting to read QUL");
setwd(path);
qul=read.csv("querycontext.tsv",sep="\t",header=FALSE);
names(qul)=c('query','attribute','context');
qul1=sqldf("select *,lower(trim(replace(query,',',''))) as cleanquery from qul where trim(context) != 'null' and trim(attribute) != 'null'");

#read cat poc mapping
print("Starting to read cat to SPOC mapping");
setwd("..");
catpoc=read.csv("catpoc.csv",header=T);
names(catpoc)=c('SuperCategory1','cclist','tolist');

#CVR q
#get all together
print("Starting merge/join job");
setwd(path);
year=gsub('.csv','',gsub('vis_','',fl1));
setwd(paste("../../Output/",year,sep=''));
comp=sqldf("select distinct a.query,'<a href=''http://www.snapdeal.com/search?keyword='||a.query||'''>http://www.snapdeal.com/search?keyword='||a.query||'</a>' as URL,a.bucket,b.visitss,b.orders,b.clicks,c.attribute,c.context from qry_bckt1 a inner join ds2 b on (a.query) = (b.cleanquery) left outer join qul1 c on (a.query) = (c.cleanquery)");
comp1=sqldf("select a.*,b.RPVb,b.CVRb,b.RPVsb,b.CVRsb,b.CTRsb,Category from comp a left outer join bucket b on a.bucket = b.bucket");
comp2=sqldf("select a.*,(1.00*clicks/visitss) as CTRq,(1.00*orders/visitss) as CVRq,(RPVb * (CVRsb - ((orders*1.0)/visitss)) * sqrt(visitss)) as pi, ((CTRsb*1.0)/(1.00*clicks/visitss)) as ctrratio from comp1 a");
#a.RPVb,a.CVRb,a.RPVsb,a.CVRsb,
comp2$ctrratio = as.numeric(comp2$ctrratio);
comp3=sqldf("select a.*, case when ctrratio > 2.0 then 'LEAP_P1_ToClassify' else 'LEAP_P2_ToClassify' end as ctrlablel, case when attribute is null or context is null then 'Generic' else 'Specific' end as typelabel,b.tolist,b.cclist as cc from comp2 a left outer join catpoc b on a.Category = b.SuperCategory1")
#comp4=comp3[,-c(3,4,5)]
output0=sqldf("select *,1 as isactive,'LEAP_'||Category as catlabel,((0.8*CVRsb)-CVRq)*AOV*visitss as Bounty from comp3 where cc is not null order by pi desc");
vt=data.table(output0);
vt$pi = as.numeric(vt$pi);
z=vt[,rank:=rank(-pi),by=Category];
output=sqldf(paste("select * from z where rank <= ",top," order by Category,pi desc",sep=""));
             
write.csv(output,"output.csv");
#comp3$pi=as.numeric(comp3$pi);
#comp4=sqldf("select query,bucket,visitss,context,topcat,CTRq,CVRq,pi,typelabel,cc,1 as isactive from comp3 where cc is not null  order by pi desc")
#comp4$pi = as.numeric(comp4$pi);







#HTML("<h1>testing</h1>","dummy.html");

#.tabler {   margin-top: 20px;   margin-bottom: 40px;   border-collapse: collapse;   border-spacing: 0;   width: 100%; }  .tabler, .tabler th, .tabler td {   border: none;   text-align: left;   padding: 8px; }  .tabler tbody tr:nth-child(even) {   background-color: #f2f2f2 }

#write.csv(final1,"topicsfinal.csv");


#sqldf("select query as Topic,supercategory as 'Super Category',Visits as 'Daily Visit',CTR,CVR,grpquery as 'Component Queries',Visits*(100-CTR)*0.01 as 'Priority' from final3 where ctr < 20 and supercategory = 'Electronics' order by Priority desc limit 20 ");



#QA
#temp=sqldf("select a.query,a.bucket,b.cleanquery,b.visitss from qry_bckt1 a left outer join ds2 b on a.query = b.cleanquery")
