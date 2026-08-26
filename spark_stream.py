import os
import sys
import json
from pathlib import Path
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, expr, from_json
from kafka.cluster_rig_config_env import config

# Forces PySpark to use the Python executable from your active virtual environment
os.environ["PYSPARK_PYTHON"] = sys.executable
os.environ["PYSPARK_DRIVER_PYTHON"] = sys.executable
os.environ.setdefault("HADOOP_HOME", r"C:\hadoop")
os.environ["PATH"] = r"C:\hadoop\bin;" + os.environ["PATH"]


TOPIC = "joystick-v2" 
KAFKA_SCHEMA_PATH = Path("protocol/device_api/device_api.schema.json")

def load_kafka_schema():
    with open(KAFKA_SCHEMA_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def spark_type_from_json_schema(field_schema):
    json_type = field_schema["type"]
    type_map = {
        "integer": "INT",
        "number": "DOUBLE",
        "string": "STRING",
        "boolean": "BOOLEAN",
    }
    return type_map[json_type]


def spark_payload_schema_from_kafka_schema(kafka_schema):
    payload_properties = kafka_schema["properties"]["payload"]["properties"]
    return ", ".join(
        f"{name} {spark_type_from_json_schema(field_schema)}"
        for name, field_schema in payload_properties.items()
    )


def payload_columns_from_kafka_schema(kafka_schema):
    payload_properties = kafka_schema["properties"]["payload"]["properties"]
    return list(payload_properties.keys())

def create_spark_session():

    print(f"Getting/Creating Apache Spark session\n")
    spark = SparkSession\
        .builder\
        .appName("test")\
        .master("local[*]")\
        .config("spark.ui.enabled", "true")\
        .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.13:4.2.0")\
        .getOrCreate()
    print(f"Apache Spark Session retrieved/created\n")

    return spark

def read_stream(spark, topic):

    print(f"******\n\nConsuming Kafka *{topic}* with Spark")

    df = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", config['bootstrap.servers']) \
    .option("kafka.security.protocol", config["security.protocol"]) \
    .option("kafka.sasl.mechanism", config["sasl.mechanisms"]) \
    .option(
        "kafka.sasl.jaas.config",
        'org.apache.kafka.common.security.plain.PlainLoginModule required '
        f'username="{config["sasl.username"]}" password="{config["sasl.password"]}";'
    ) \
    .option("subscribe", topic) \
    .option("startingOffsets", "earliest") \
    .load()

    print(f"\n\n{topic} topic consumed\n**********")

    print(df)
    df.printSchema()

    return df

def query_spark_df(df,topic, await_termination = 3):

    print(f"******\nQuerying Spark data frame\n")

    # Confluent JSON Schema messages have a 5-byte Schema Registry header:
    # 1 magic byte + 4 schema-id bytes. The remaining bytes are the JSON payload.   
    kafka_schema = load_kafka_schema()
    payload_schema = spark_payload_schema_from_kafka_schema(kafka_schema)
    payload_columns = payload_columns_from_kafka_schema(kafka_schema)

    decoded = df.select(
        col("key").cast("string").alias("key"),
        expr("CAST(substring(value, 6, length(value) - 5) AS STRING)").alias("json_value"),
        col("topic"),
        col("partition"),
        col("offset"),
        col("timestamp").alias("kafka_timestamp"),
    )

    df_query = decoded.select(
        "key",
        from_json(col("json_value"), payload_schema).alias("payload"),
        "topic",
        "partition",
        "offset",
        "kafka_timestamp",
    ).select(
        "key",
        *[col(f"payload.{name}").alias(name) for name in payload_columns],
        "topic",
        "partition",
        "offset",
        "kafka_timestamp",
    )
    print(df_query)

    # Write to console
    print('writing query to console...')
    query = (
        df_query.writeStream
        .format("console")
        .option("truncate", "false")
        .option("checkpointLocation", "data/spark/checkpoints/joystick_console")
        .start()
    )

    query.awaitTermination(await_termination)
    print("query status:", query.status)
    print("query exception:", query.exception())
    print("recent progress:", query.recentProgress)
    query.stop()


    print('done writing to console')

    # Write to file
    # print('writing query to file...')
    # query = (df.writeStream
    #     .format("json") # "json", "csv","parquet"
    #     .option("path", "/temporary")
    #     .trigger(processingTime="2 seconds")
    #     .start())
    # query.awaitTermination(5)
    # query.stop()
    # print('done writing to file')

    # print('write to kafka ()')
    # topic_transformed = f"{topic}-transformed"
    # query = (df.writeStream
    #         .format("kafka")
    #         .option("kafka.bootstrap.servers", "NEEDCONFIG")
    #         .option("topic", topic_transformed)
    #         .start()
    #     )
    # print('done writing to file')

if __name__ == "__main__":
    print(f"{"-" * 50}")
    print(f"Initialize processing Kafka'{TOPIC}' using Spark")

    print(f"{"-" * 50}")
    spark = create_spark_session()

    print(f"{"-" * 50}")
    df = read_stream(spark,TOPIC)

    print(f"{"-" * 50}")
    query_spark_df(df,TOPIC)

    spark.stop()


# import scratch as S 
# from pyspark.sql.functions import col

# print(f"{"-" * 50}")
# spark = S.create_spark_session()

# print(f"{"-" * 50}")
# TOPIC = 'joystick-v2'
# df = S.read_stream(spark,TOPIC)
# df_filtered = df.filter(col("TOPIC") == TOPIC)
# df_recent = df.filter(col("timestamp").isNotNull())

# df_keys = df.select(
#     col("key").cast("string").alias("key"),
#     col("timestamp")
# )


# print(f"{"-" * 50}")

# kafka_schema = S.load_kafka_schema()
# payload_schema = S.spark_payload_schema_from_kafka_schema(kafka_schema)
# payload_columns = payload_columns_from_kafka_schema(kafka_schema)

# print(f"{"-" * 50}")
# S.query_spark_df(df)

# spark.stop()
