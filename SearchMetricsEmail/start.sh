dt=`date --date="1 days ago" +%Y-%m-%d`
dt1=`date --date="1 days ago" +%Y%m%d`
export JAVA_HOME="/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64"
home="/data/deepak/SearchRelevance/SearchMetricsEmail_v2" #working dir
#src="/home/deepak/Documents/src" #code base
#src=`pwd`
SCRIPT=$(readlink -f $0)
src=`dirname $SCRIPT`
export loc="$home/log.txt"
export loc1="$home/cart.txt"
export loc2="$home/$dt1"
export loc3="$home/cl.txt"
SPARK_HOME="/data/spark/spark-1.4.1-bin-hadoop2.6"
EMAIL="deepak.babu@snapdeal.com"

#copy from S3
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat01_pub/minerva-tomcat/server.log.$dt.bz2" "$home/A/"
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat02_pub/minerva-tomcat/server.log.$dt.bz2" "$home/B/"
bzcat "$home/A/server.log.$dt.bz2" > "$home/full_log.txt"
bzcat "$home/B/server.log.$dt.bz2" >> "$home/full_log.txt"


#create interim files
cat "$home/full_log.txt" | grep -E '(SEARCH_IMPRESSION|SEARCH_CLICK)' > "$loc"
cat "$home/full_log.txt" | grep 'ADD_TO_CART' > "$loc1"
cat "$home/full_log.txt" | grep 'SEARCH_CLICK' > "$loc3"

$SPARK_HOME/bin/spark-submit   --class "SimpleApp"   --packages com.databricks:spark-csv_2.10:1.2.0   $src/simple-project_2.10-1.0.jar "$loc" "$loc1" "$loc2" "$loc3"

src="$home/$dt1"
tgt="$home/$dt1"
eval cat $src/part* > "$tgt/final.json"

#convert json(after preprocess) to csv"
cat "$loc2/final.json" | sed -e 's/" //g' | sed -e 's/"//g' > "$loc2/final1.json"
#run R script
d0=`date --date="1 days ago" +%Y%m%d`
d1=`date --date="2 days ago" +%Y%m%d`
Rscript $home/postprocess.R "$home/" $d0 $d1


$home/csv2html.sh --head "$loc2/final2.json" > "$loc2/final2.html"
$home/csv2html.sh --head "$home/$dt1/trend.csv" > "$home/$dt1/trend.html"
cat $home/header.txt > "$loc2/new.html"
cat "$home/$dt1/trend.html" >>  "$loc2/new.html"
cat "$home/$dt1/chart.csv" >> "$loc2/new.html"
cat "$loc2/final2.html" >> "$loc2/new.html"
mail -s "$(echo -e "Daily Search Metrics - $dt\nContent-Type:text/html")"  $EMAIL < "$loc2/new.html"
