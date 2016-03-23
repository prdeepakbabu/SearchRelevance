                    library(sqldf);
library(ggplot2);
library(rgl);
library(plotrix);
library(RH2);
library(rworldmap);
library(plyr);
library(rjson);
library(RCurl);
setwd("/home/deepak/Documents/Work/Clustering");
dt=read.csv(file="Dump",sep="\t");
names(dt)=c('fullname','email','gender','age','tenure_mths','mobile','cat','subcat','weight','payment_mode','city','pincode','state','amount','del_time','ord_hr','url','order_dt');

#SRS of 50K customers
em=sqldf("select distinct email from dt");
srs=sample(em[,1],50000,replace=FALSE);
srsdf=data.frame(srs);
names(srsdf)=c('email');
dataset=sqldf("select * from dt where email in (select email from srsdf)");

#creating variable and derived attributes
#elevation API : https://developers.google.com/maps/documentation/elevation/intro
#District: To manually classify coastal/hill station
#District: Tourist destination/Non-tourist Destination( 392 distinct - sqldf("select distinct round(pincode/1000,0) from dataset"))
dataset1=sqldf("select email,cat,round(max(age)) as age,round(max(tenure_mths)) as tenure_mths, 
               max(case when payment_mode = 'cd' then 1 else 0 end) as cod,
               max(case when ord_hr between 0 and 12 then 1 else 0 end) as morning,
               max(case when ord_hr between 12 and 17 then 1 else 0 end) as afternoon,
               max(case when ord_hr between 17 and 20 then 1 else 0 end) as evening,
               max(case when ord_hr between 20 and 23 then 1 else 0 end) as night,
               max(case when strftime('%w',order_dt) in (0,6) then 1 else 0 end) as weekend,
               sum(amount) as amt,
               max(pincode) as pincode
               from dataset group by email,cat"); 
#dataset2=sqldf("select *,(case when cod = 1 then 0 else 1 end) as online, (case when weekend = 1 then 0 else 1 end) as weekday");
dataset1$cat=gsub("[^a-zA-Z0-9]","",dataset1$cat,perl=T);
dataset2=sqldf("select email,sum(amount) as total from dataset group by email");
dataset3=sqldf("select a.*,b.total from dataset1 a, dataset2 b where a.email = b.email");
dataset4=sqldf("select *,round(amt/total,1) as value from dataset3")
dataset4$amt<-NULL
dataset4$total<-NULL
save(dataset4,file="RawData.RData");
load("RawData.RData");
write.csv(dataset4,file="rawdata.csv")
catnorm=read.csv("categorynorm.csv",header=TRUE);
catnorm[is.na(catnorm)] =0
dataset4$cat <- NULL
dataset4$value <- NULL
#dataset4$pincode <- NULL
dataset5=sqldf("select distinct * from dataset4");
del=sqldf("select email,count(*) as cnt from dataset5 group by email having cnt > 1");
dataset6=sqldf("select * from dataset5 where email not in (select email from del)")
names(catnorm)[names(catnorm)=="email"] <- "email1"
final1=sqldf("select a.*,b.* from dataset6 a,catnorm b where a.email = b.email1");
final1$email1<-NULL
#commit1 - 42,391 customers
# yet to get geo attri and gender
save(final1,file="rawdata1.RData");
write.csv(final1,file="rawdata1.csv");


#infer gender based on first and last name using Third party API
tmp=sqldf("select distinct email as emil from final1");
em=sqldf("select a.email,a.url,a.gender from dt a,tmp b where a.email = emil and gender= 'u'");
em=sqldf("select email,max(url) as url,max(gender) as gender from em group by email");
getGender <- function(url)
{
  tmp=getURL(url);
  temp=fromJSON(tmp);
  return(temp$gender);
}
em['inferred_gender']='unknown';
#for(i in 6732:nrow(em)) { em[i,c('gender')] = getGender(paste(em[i,c('url')]));}
#4817
for(i in 5673:nrow(em)) { em[i,c('inferred_gender')] = getGender(paste(em[i,c('url')]));}
emf=sqldf("select email,case when inferred_gender in ('m','male') then 'm' when inferred_gender in ('f','female') then 'f' else 'u' end as gender from em");
gndr=sqldf("select email,max(gender) as gn from dt group by email");
x1=sqldf("select a.*,b.gn as gender from final1 a,gndr b where a.email = b.email");
final2=sqldf("select a.*, 
                     case when a.gender = 'u' then b.gender else a.gender end as gendr from x1 a left outer join emf b on a.email = b.email");
final3=sqldf("select * from final2 where gendr in ('m','f')");
final3$gender<-NULL
save(final3,file="final.RData")
write.csv(final3,file="final3.csv");



save.image();


#get all districts using pincodes
allpins=read.csv(file="IN.txt",sep="\t",quote = "");
names(allpins)=c('a','pincode','b','state','d','district','e','f','g','h');
districts=sqldf("select distinct round(pincode/1000),state from allpins");
write.csv(districts,file="districts.csv");


#District
d28=read.csv(file="district28m.txt",sep="\t");
d11=read.csv(file="district11m.txt",sep="\t");
names(d28)=c('c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','district','subdist','pop','elevation','c17','c18','c19');
set1=sqldf("select  * from d28 where c8 = 'ADM2'");
sqldf("select c2,c3,c11,c12,pop,c17 from set1 where c11 = 19 order by c12 asc");
set0=sqldf("select distinct c2,pop,c17 as elevation from set1");

names(d11)=c('c1','postalcode','c3','state','statecode','district','c7','c8','c9','c10','c11','c12');
set2=sqldf("select distinct round(postalcode/1000) as postalcode, state,district from d11 ");
jon=sqldf("select a.postalcode,pop,elevation,district from set2 a,set0 b where a.district = b.c2");
jon1=sqldf("select postalcode,sum(pop) as pop, avg(elevation) as elevation from jon group by postalcode")
dn=sqldf("select postalcode,district from set2");
dn1=sqldf("select postalcode,group_concat(district) as district from dn group by postalcode");
write.csv(jon1,"geo.csv",row.names=FALSE);
dist=read.csv("dist.csv")
geodb=sqldf("select a.*,elevation,pop,c.district from (select distinct pin,state from dist) a left outer join jon1 b on a.pin = b.postalcode left outer join dn c  on  a.pin = c.postalcode")
geodb0=sqldf("select a.*,district  from dist a left outer join (select distinct postalcode,district from set2) b on a.pin = b.postalcode")
geodb1=sqldf("select a.*,district,elevation,pop from dist a left outer join (select distinct postalcode,district from set2) b on a.pin = b.postalcode left outer join jon1 c on a.pin = c.postalcode")
write.csv(geodb1,file="geodb1.csv");

                                
load()
save.image();