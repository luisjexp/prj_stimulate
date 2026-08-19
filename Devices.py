import json
from pathlib import Path
import serial

class arduino:
    def __init__(self):
        import time
        
        D = device_info()
        self.arduino = serial.Serial(port=D.arduino_port, baudrate=9600, timeout=1)
        time.sleep(2)  
        self.arduino.reset_input_buffer()
        self.arduino.reset_output_buffer()
        self.schema = D.schema


    def readlines(self):
        from jsonschema import validate, ValidationError

        while True:
            line = self.arduino.readline().decode("utf-8", errors="replace").strip()

            if not line:
                continue

            try:
                msg = json.loads(line)

                validate(instance=msg, schema=self.schema)

                if msg["message_type"] == "arduino_joystick_1.sample":
                    payload = msg["payload"]

                    x = payload["x"]
                    y = payload["y"]
                    b = payload["b"]

                    print(f"x={x}, y={y}, b={b}")

                elif msg["message_type"] == "system.error":
                    print("Device error:", msg["payload"])

            except json.JSONDecodeError:
                print("Invalid JSON:", line)

            except ValidationError as e:
                print("Schema validation error:", e.message)
                print("Raw message:", line)

            except KeyboardInterrupt:
                print("Stopping...")
                break

        self.arduino.close()

    def send(self,cmd):
        import time

        self.arduino.write((cmd + "\n").encode())
        self.arduino.flush()

        reply = self.arduino.readline().decode().strip()
        time.sleep(1)
        if reply == "OK":
            print(f"Arduino Responded with desirably (with an 'OK'): {reply}")

        if reply != "OK":
            em = f"Arduino Responded with desirably (with an 'OK'): {reply}"
            raise RuntimeError(em)

        

class device_info:
    """A brief summary of what the class does."""

    isDebugging: bool = True    
    os: str = 'pc'
    ip_address: str = '192.168.1.201'
    udport_port: int  = 50003;   
    arduino_port: str = 'COM3';             

    def __init__(self) -> None:
        self.schema = self.load_schema()
        print('*Device info loaded*')

    def __str__(self):
        m = (f"Debug Mode = {self.isDebugging}\nOS = {self.os}\n"
            f"IP Address = {self.ip_address}\nUD Port ={self.udport_port}\n"
            f"Arduino Port = {self.arduino_port}\n")

        print(m)

    def load_schema(self):
        schema_path = Path(r"C:\Users\Luis\Dropbox\PROJECTS\prj_stimulate\protocol\device_api\device_api.schema.json")

        with open(schema_path, "r", encoding="utf-8") as f:
            schema = json.load(f) 

        return schema

