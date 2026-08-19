# Device API

This protocol defines newline-delimited JSON messages for communication between
Python, Arduino/microcontrollers, MATLAB sessions, and future tools.

First link:

```text
Arduino joystick -> serial -> Python
```

## Transport

One JSON object per line.

```text
{"protocol":"device-api","version":"0.1",...}\n
```

## Top-Level Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `protocol` | string | yes | Must be `device-api`. |
| `version` | string | yes | Protocol version. |
| `message_type` | string | yes | Allowed message type. |
| `source` | string | yes | Sender id. |
| `timestamp_ms` | integer | optional | Sender-local timestamp in milliseconds. |
| `payload` | object | yes | Message-specific data. |

## Schema Validation

| Keyword | Purpose |
| --- | --- |
| `$schema` | JSON Schema standard. |
| `title` | Schema name. |
| `type` | Requires a JSON object. |
| `additionalProperties` | Rejects fields not listed in `properties`. |
| `required` | Required fields. |
| `properties` | Field names and basic types. |
| `allOf` | Message-specific payload rules. |

Required fields:

```text
protocol
version
message_type
source
payload
```

## Device Names

Allowed `source` values:

```text
arduino_joystick_1
python_session_1
matlab_session_1
arduino_sensor_1
```

## Message Types

Allowed `message_type` values:

```text
arduino_joystick_1.sample
system.error
```

## Joystick Sample

```json
{
  "protocol": "device-api",
  "version": "0.1",
  "message_type": "arduino_joystick_1.sample",
  "source": "arduino_joystick_1",
  "timestamp_ms": 123456,
  "payload": {
    "x": 512,
    "y": 488,
    "b": 0
  }
}
```

Payload fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `x` | integer | yes | Raw joystick X reading. |
| `y` | integer | yes | Raw joystick Y reading. |
| `b` | integer | yes | Button state. |

## Error

```json
{
  "protocol": "device-api",
  "version": "0.1",
  "message_type": "system.error",
  "source": "python_session_1",
  "timestamp_ms": 1780000000000,
  "payload": {
    "code": "invalid_payload",
    "message": "arduino_joystick_1.sample payload missing x"
  }
}
```

Payload fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `code` | string | yes | Error code. |
| `message` | string | yes | Error description. |
