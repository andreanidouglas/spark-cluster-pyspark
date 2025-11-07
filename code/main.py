import sys
from pyspark.sql import SparkSession, udf
import pandas as pd
from pyspark.sql.functions import max, min, mean
from pyspark.sql.types import *


def to_fahrenheit(c):
    if c is None:
        return 0.0
    else:
        return (c * 1.8) + 32


spark = SparkSession.builder.remote("sc://127.0.0.1:15002").getOrCreate()

schema = StructType(
    [
        StructField("city", StringType(), True),
        StructField("temperature", DoubleType(), True),
    ]
)
dfs = (
    spark.read.option("delimiter", ";")
    .option("header", "false")
    .schema(schema)
    .csv("/opt/spark/data/weather_stations.csv")
)
print("INFO: Finish reading data", file=sys.stderr)


dfs = dfs.where(dfs.temperature.isNotNull())

dfs.groupby("city").agg(
    max("temperature"), min("temperature"), mean("temperature")
).sort("city").show()
