# ================================================================
# VI DU, CU THE VOI BAI TOAN SALES DATA
# (Day la code mau huong dan, hoc vien can tuy chinh theo
#  bai toan va schema cua minh)
# ================================================================
# AWS Glue ETL Job - Bronze to Silver
# Project III: AWS DWH & Data Lake
# ================================================================

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.types import *

# Initialize Glue context
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_INPUT_PATH', 'S3_OUTPUT_PATH'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# ============================================================
# CONFIGURATION
# ============================================================
INPUT_PATH = args['S3_INPUT_PATH']    # s3://bucket/raw/sales/
OUTPUT_PATH = args['S3_OUTPUT_PATH']  # s3://bucket/cleaned/sales/

# ============================================================
# EXTRACT - Read from S3 Raw Zone
# ============================================================
print(f"Reading raw data from: {INPUT_PATH}")

# TODO: Read raw CSV/JSON data
raw_df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv(INPUT_PATH)

print(f"Total raw records: {raw_df.count()}")
raw_df.printSchema()

# ============================================================
# TRANSFORM - Data Cleansing & Standardization
# ============================================================
print("Applying transformations...")

# Step 1: Remove duplicates
deduped_df = raw_df.dropDuplicates()
print(f"After dedup: {deduped_df.count()}")

# Step 2: Handle NULL values
# TODO: Customize based on your schema
cleaned_df = deduped_df \
    .filter(F.col("order_id").isNotNull()) \
    .filter(F.col("amount").isNotNull()) \
    .filter(F.col("amount") > 0)

# Step 3: Type casting & standardization
transformed_df = cleaned_df \
    .withColumn("order_date", F.to_date("order_date_str", "yyyy-MM-dd")) \
    .withColumn("amount", F.col("amount").cast("decimal(18,2)")) \
    .withColumn("quantity", F.col("quantity").cast("int")) \
    .withColumn("year", F.year("order_date")) \
    .withColumn("month", F.month("order_date")) \
    .withColumn("day_of_week", F.dayofweek("order_date")) \
    .withColumn("is_weekend", F.when(F.dayofweek("order_date").isin(1, 7), True).otherwise(False))

# Step 4: Data quality checks
# TODO: Add more quality checks
total_records = transformed_df.count()
null_amounts = transformed_df.filter(F.col("amount").isNull()).count()
print(f"Quality Check - Total: {total_records}, Null amounts: {null_amounts}")

# ============================================================
# LOAD - Write to S3 Cleaned Zone (Parquet)
# ============================================================
print(f"Writing cleaned data to: {OUTPUT_PATH}")

transformed_df.write \
    .mode("overwrite") \
    .partitionBy("year", "month") \
    .parquet(OUTPUT_PATH)

print("Bronze to Silver ETL completed successfully!")

job.commit()
