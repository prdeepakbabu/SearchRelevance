name := "Simple Project"

version := "1.0"

scalaVersion := "2.10.4"

libraryDependencies ++= Seq(
"org.apache.spark" % "spark-sql_2.10" % "1.4.0",
"com.databricks" % "spark-csv_2.10" % "0.1"
)
