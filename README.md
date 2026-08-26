# Project

Serves as a platform to execute a wide range of closed-loop, stimulus-response-stimulus experiments with live data streams. Compatible with a variety of devices for real-time sensing, stimulation, storage, processing and modeling. 

Goals
* End-to-end low-latency processing, or to make results available to the output device within milliseconds of the input data being available in the input device. [See Apache Spark continuous streaming.](https://spark.apache.org/docs/latest/streaming/performance-tips.html#continuous-processing)
* Unified language for serial device communication and data contracts [See Kafka schema registry.](https://docs.confluent.io/platform/current/schema-registry/index.html)
* Early and fast data integration: [See joining streamed data with Apache Spark](https://spark.apache.org/docs/latest/streaming/apis-on-dataframes-and-datasets.html#operations-on-streaming-dataframesdatasets])