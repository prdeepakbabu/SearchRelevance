dt=`date --date="1 days ago" +%Y-%m-%d`
dt1=`date --date="1 days ago" +%Y%m%d`
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
home="/home/hduser/dashboard" #working dir
#src="/home/deepak/Documents/src" #code base
#src=`pwd`
SCRIPT=$(readlink -f $0)
src=`dirname $SCRIPT`
export loc="$home/log.txt"
export loc1="$home/cart.txt"
export loc2="$home/$dt1"
SPARK_HOME="/home/deepak/Downloads/spark-1.5.1-bin-hadoop2.6"

#copy from S3
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat01_pub/minerva-tomcat/server.log.$dt.bz2" "$home/A/"
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat02_pub/minerva-tomcat/server.log.$dt.bz2" "$home/B/"
bzcat "$home/A/server.log.$dt.bz2" > "$home/full_log.txt"
bzcat "$home/B/server.log.$dt.bz2" >> "$home/full_log.txt"


#create interim files
cat "$home/full_log.txt" | grep -E '(SEARCH_IMPRESSION|SEARCH_CLICK)' > "$loc"
cat "$home/full_log.txt" | grep 'ADD_TO_CART' > "$loc1"

$SPARK_HOME/bin/spark-submit   --class "SimpleApp"   --packages com.databricks:spark-csv_2.10:1.2.0   $src/simple-project_2.10-1.0.jar "$loc" "$loc1" "$loc2"

src="$home/$dt1"
tgt="$home/$dt1"
eval cat $src/part* > "$tgt/final.json"

#convert json(after preprocess) to csv"
cat "$loc2/final.json" | sed -e 's/" //g' | sed -e 's/"//g' > "$loc2/final1.json"
$src/csv2html.sh --head "$loc2/final1.json" > "$loc2/final2.html"
cat $src/header.txt > "$loc2/new.html"
cat "$loc2/final2.html" >> "$loc2/new.html"
mailx -a "Content-Type: text/html" -s "Daily Search Metrics - $dt" deepak.babu@snapdeal.com < "$loc2/new.html"

