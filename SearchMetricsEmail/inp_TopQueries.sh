base="/data/deepak/Analytics"
home="$base/Input"
dt=`date --date="1 days ago" +%Y%m%d`
mkdir -p $home/$dt
cd $home/$dt
fl1="vis_$dt.zip"	
fl2="clk_$dt.zip"
echo $pwd
HOST='54.254.156.41'
USER='top_search'
PASSWD='qtizwhlrwu'
ftp -n $HOST << %EOF%
quote USER $USER
quote PASS $PASSWD
cd /Deepak/TopQueries
binary
get $fl1
get $fl2
quit
%EOF%
pwd=`pwd`
unzip $fl1
rm -f $fl1
unzip $fl2
rm -f $fl2
#invoke R script
fl1="vis_$dt.csv"	
fl2="clk_$dt.csv"
Rscript $base/Code/getBadQueriesv1.R "$home/$dt/" $fl1 $fl2

#create 0-200
cat $home/header.txt > $base/Output/20151216_1.html
cat $home/$dt/top1.txt >> $base/Output/20151216_1.html
cat $home/tail1.txt >> $base/Output/20151216_1.html
#create 200-400
cat $home/header.txt > $base/Output/20151216_2.html
cat $home/$dt/top2.txt >> $base/Output/20151216_2.html
cat $home/tail2.txt >> $base/Output/20151216_2.html
#create 400-600
cat $home/header.txt > $base/Output/20151216_3.html
cat $home/$dt/top3.txt >> $base/Output/20151216_3.html
cat $home/tail3.txt >> $base/Output/20151216_3.html
#create trending searches
#echo "<h1 align='center'> Searches Trending this hour </h1><br><br><table align='center' ><tr><td>" > $base/Output/ts.html
#curl -v -X POST -HContent-Type:application/json --data-binary '{"responseProtocol":"PROTOCOL_JSON", "requestProtocol":"PROTOCOL_JSON", "queryCount":20}' http://30.0.251.183:8083/service/searchServer/getTrendingSearches  | jq -r '.queries | join("</td></tr><tr><td>")'  >> $base/Output/ts.html
#echo "</td></tr></table>" >> $base/Output/ts.html

#move to git local repo
#cd $base/SearchRelevance
#git checkout gh-pages
#cp $base/Output/20151216_1.html $base/SearchRelevance
#cp $base/Output/20151216_2.html $base/SearchRelevance
#cp $base/Output/20151216_3.html $base/SearchRelevance
#cp $base/Output/ts.html $base/SearchRelevance
#git status
#git add .
#git commit -am "refresh"
#git push origin gh-pages
#push to git

#mv $pwd/$fl1 $home/$dt
#mv $pwd/$fl2 $home/$dt

echo "Starting category mailer data"
Rscript $base/Code/CategoryMailerv3.R "$home/$dt/" $fl1 $fl2 "final_output.txt"


