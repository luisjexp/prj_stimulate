from confluent_kafka import Producer
from confluent_kafka.serialization import SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONSerializer
from kafka.cluster_rig_config_env import config, sr_config
import time


class joystickstate(object):
    def __init__(self, time, x, y, b):
        self.time = time
        self.x = x
        self.y = y
        self.b = b


schema_str = """{
  "$id": "http://example.com/myURI.schema.json",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "description": "This schema has been created from JSON messages.",
  "properties": {
    "b": {
      "type": "number"
    },
    "time": {
      "type": "string"
    },
    "x": {
      "type": "number"
    },
    "y": {
      "type": "number"
    }
  },
  "title": "SampleRecord",
  "type": "object"
}"""


def stick_to_dict(stick, ctx):
    return {"time":stick.time, 
            "x":stick.x,
            "y":stick.y, 
            "b":stick.b}




data = [joystickstate('1', 10, 10, 0),
        joystickstate('4', 10, 20, 0),
        joystickstate('5', 10, 30, 1),
        joystickstate('8', 20, 30, 0),
        joystickstate('11', 30, 30, 1)]


def delivery_report(err, event):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(f"Produced to {event.topic()} [{event.partition()}] offset {event.offset()}")


if __name__ == '__main__':
  topic = 'joystick'
  schema_registry_client = SchemaRegistryClient(sr_config)

  json_serializer = JSONSerializer(schema_str, schema_registry_client,stick_to_dict)

  producer = Producer(config)
  for temp in data:
      print(temp.x)
      messagefield_val = MessageField.VALUE
      print(messagefield_val)
      val = json_serializer(temp, SerializationContext(topic, messagefield_val))
      print(val)
      # print(delivery_report)
      
      producer.produce(topic=topic, key=str(temp.time),
                        value=json_serializer(temp, 
                        SerializationContext(topic, MessageField.VALUE)),
                        on_delivery=delivery_report)

  producer.flush()