#Daily Search Metrics
**Daily email report of key search metrics for previous day, involves top 100 keywords imp,click,buy and CTR,CVR along with max positions clicked and browsed.**

###Pre-Requisites (Unix Only)
* aws setup for S3 search
* Apache Spark 1.4 and above
* csv2html.sh (provided here)
* setup for mailx

###Steps to run:
* Setup the parameter variables in start.sh ie. directory to create outputs, email ids of users who recieve the report,etc.
* sh start.sh 
