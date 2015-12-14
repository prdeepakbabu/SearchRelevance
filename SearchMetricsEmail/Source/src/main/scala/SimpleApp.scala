import org.apache.spark.sql.SQLContext
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf	


object SimpleApp {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("Get Search Metrics");
    val sc = new SparkContext(conf)
val sqlContext = new SQLContext(sc);
val fl_loc=args(0);
val fl_clk=args(3);
val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "false") .option("inferSchema", "true") .load(fl_loc);

val dt=df.toDF("time","datetime","event","cookie","email","query","pogs","pos");
dt.registerTempTable("dtl");

val df1 = sqlContext.read.format("com.databricks.spark.csv").option("header", "false") .option("inferSchema", "true") .load(fl_clk);

val dt1=df1.toDF("time","datetime","event","cookie","email","query","pogs","pos","ispartial");
dt1.registerTempTable("cl");

var clk =sqlContext.sql("select query as query,count(distinct cookie) as cnt,max(cast(pos as integer)) as pos from cl where event = ' SEARCH_CLICK' group by query order by cnt desc limit 250 ");
clk.registerTempTable("clk");

var imp =sqlContext.sql("select a.query,count(distinct a.cookie) as imp_cnt, max(b.cnt) as clk_cnt,  max(b.cnt) * 100/count(distinct a.cookie) as ctr, max(cast(b.pos as integer)) as clk_max_pos, max(cast(a.pos as integer)) as imp_max_pos from dtl a,clk b  where a.query = b.query and event = ' SEARCH_IMPRESSION' group by a.query order by imp_cnt desc limit 250 ");

val fl_loc1=args(1);
val cart = sqlContext.read.format("com.databricks.spark.csv").option("header", "false") .option("inferSchema", "true") .load(fl_loc1);

val cartdt=cart.toDF("time","datetime","event","cookie","email","session","pogs","misc");
cartdt.registerTempTable("cartdt");
val clk_set=sqlContext.sql("select distinct query,cookie,pogs from dtl where event = ' SEARCH_CLICK'");
clk_set.registerTempTable("clk_set");
val cartdl=sqlContext.sql("select a.query,count(distinct b.cookie) as cnt from clk_set a left outer join cartdt b on a.cookie = b.cookie and a.pogs = b.pogs group by a.query order by cnt desc");

cartdl.registerTempTable("cartdl");
imp.registerTempTable("imp");
val fnl=sqlContext.sql("select a.query as Query,a.imp_cnt as Impressions, a.clk_cnt as Clicks,b.cnt as Buys,cast(a.ctr as integer) as CTR, cast((b.cnt * 100/a.clk_cnt) as integer) as CVR,imp_max_pos as max_pos_imp, clk_max_pos as max_pos_clk from imp a left outer join cartdl b on a.query = b.query order by cast(imp_cnt as integer) desc limit 100");

val fl_loc2=args(2);

fnl.write.format("com.databricks.spark.csv").option("header", "true").save(fl_loc2);
}}
