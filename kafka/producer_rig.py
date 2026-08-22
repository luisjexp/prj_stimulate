# TEMPORARY FIX TO IMPORT LIBS FROM PARENT PATH
from pathlib import Path
import sys
PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

# IMPORT
import json
from confluent_kafka import Producer
from confluent_kafka.serialization import SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONSerializer
from Devices import device_info, arduino
from kafka.cluster_rig_config_env import config, sr_config


device_schema = device_info.load_schema()

def kafka_schema_from_device_schema(device_schema):
    payload_properties = device_schema["properties"]["payload"]["properties"]

    return {
        "$id": "http://example.com/myURI.schema.json",
        "$schema": "http://json-schema.org/draft-07/schema#",
        "description": "for joystick-v2",
        "properties": payload_properties,
        "title": "SampleRecord",
        "type": "object",
    }


def device_msg_to_kafka_record(msg):
    record = dict(msg["payload"])
    return record

kafka_schema = kafka_schema_from_device_schema(device_schema)
schema_str = json.dumps(kafka_schema,indent=4)


def delivery_report(err, event):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(f"Produced to {event.topic()} [{event.partition()}] offset {event.offset()}")

def record_to_dict(record, ctx):
    return record

def is_valid_record(record):
  for x in record: 
     if type(record[x]) != int:
         return False

  return True


if __name__ == '__main__':
    topic = 'joystick-v2'

    schema_registry_client = SchemaRegistryClient(sr_config)
    json_serializer = JSONSerializer(schema_str, schema_registry_client, record_to_dict)
    producer = Producer(config)

    A = arduino()

    k = 1
    num_reads = 5
    while True:
        t,x,y,b = A.read_once(print_result=False)
        record = {"time": t, "x": x,"y": y, "b": b}
        
        if is_valid_record(record):
            print(f"Good Record", end = " ")
            producer.produce(
                topic=topic,
                key="time",
                value=json_serializer(record, SerializationContext(topic, MessageField.VALUE)),
                on_delivery=delivery_report,
                )
        
        else:
            print("Bad  Record", end = " ")
            
        print(f"k = {k} | {record}")
        k = k+1
        if k > num_reads:
          A.myclose()    
          break


    producer.flush()
    # print(json_serializer)
    
    # for stick in data:
    #     producer.produce(
    #         topic=topic,
    #         key=str(stick.time),
    #         value=json_serializer(stick, SerializationContext(topic, MessageField.VALUE)),
    #         on_delivery=delivery_report,
    #     )

