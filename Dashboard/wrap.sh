dt=`date --date="1 days ago" +%Y-%m-%d`
dt1=`date --date="1 days ago" +%Y%m%d`

#set these variables
home="/home/hduser/dashboard"
spark_loc="/home/hduser/spark-1.4.1-bin-hadoop2.6/bin"
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
email="deepak.babu@snapdeal.com"

#copy from S3
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat01_pub/minerva-tomcat/server.log.$dt.bz2" "$home/A/"
aws s3 cp  "s3://sd-logarchive/minerva-logging/minerva-tomcat02_pub/minerva-tomcat/server.log.$dt.bz2" "$home/B/"
bzcat "$home/A/server.log.$dt.bz2" "$home/B/server.log.$dt.bz2" > "$home/full_log.txt"

#create interim files
cat "$home/full_log.txt" | grep -E '(SEARCH_IMPRESSION|SEARCH_CLICK)' > "$home/log.txt"
cat "$home/full_log.txt" | grep 'ADD_TO_CART' > "$home/cart.txt"
export loc="$home/log.txt"
export loc1="$home/cart.txt"
export loc2="$home/$dt1"
$spark_loc/spark-shell  --packages com.databricks:spark-csv_2.10:1.0.3 < "$home/processlog.spark"
src="$home/$dt1"
tgt="$home/$dt1"
eval cat $src/part* > "$tgt/final.json"
#rm -rf "$tgt"

#convert json(after preprocess) to csv"
cat $home/$dt1/final.json | sed -e 's/" //g' | sed -e 's/"//g' > $home/$dt1/final1.json
$home/csv2html.sh --head $home/$dt1/final1.json > $home/$dt1/final2.html

#mail the generated html
mailx -a "Content-Type: text/html" -s "Daily Search Metrics - $dt" $email < $home/$dt1/final2.html

