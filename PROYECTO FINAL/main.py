#=======================================================
#importación de los modulos y librerias necearias para el programa.
#=======================================================

from machine import Pin, I2C, SoftI2C
import oled
import time
import network
import bme280
from umqtt.robust import MQTTClient
import sys

#=======================================================
#configuración de la pantalla
#=======================================================

i2c1 = SoftI2C(scl=Pin(19), sda=Pin(18))
oled_width = 128
oled_height = 64
oled = oled.SSD1306_I2C(oled_width, oled_height, i2c1)

#=======================================================
#configuración Wi-Fi
#=======================================================

SSID = 'TOTALPLAY78_2.4Gnormal_plus'
PASSWORD = 'T4rgaryen88'
red = network.WLAN(network.STA_IF)
red.active(False)
red.connect(SSID, PASSWORD)
while red.isconnected() == False:
  pass
oled.text('Conexion Wi-Fi', 0, 30)
oled.text('establecida ', 0, 45)
oled.show()
print('Conexion correcta')
print(red.ifconfig())
time.sleep(5)

#=======================================================
# Inicializar I2C
#=======================================================

i2c = I2C(0, sda=Pin(20), scl=Pin(21))  

# Crear instancia del sensor
bme = bme280.BME280(i2c=i2c)

#=======================================================
# Configuración MQTT y ThingSpeak
# Configuración de parametros
#=======================================================

THINGSPEAK_MQTT_CLIENT_ID = b"JDErAQAKGzsiGygcNS4OIQ0"
THINGSPEAK_MQTT_USERNAME = b"JDErAQAKGzsiGygcNS4OIQ0"
THINGSPEAK_MQTT_PASSWORD = b"E30DsywKdTAuL9txJXykesqI"
THINGSPEAK_CHANNEL_ID = b'2773559'
THINGSPEAK_MQTT_USERNAME = THINGSPEAK_MQTT_CLIENT_ID
#=======================================================
# 
#=======================================================
client = MQTTClient(server=b"mqtt3.thingspeak.com",
                    client_id=THINGSPEAK_MQTT_CLIENT_ID, 
                    user=THINGSPEAK_MQTT_USERNAME, 
                    password=THINGSPEAK_MQTT_PASSWORD, 
                    ssl=False)

#=======================================================
try:            
    client.connect()
except Exception as e:
    print('could not connect to MQTT server {}{}'.format(type(e).__name__, e))
    sys.exit()
oled.fill(0)
oled.show()
oled.text('Conexion al ', 0, 10)
oled.text('servidor', 0, 30)
oled.text('establecida', 0, 50)
oled.show()
time.sleep(5)
#=======================================================
# continually publish two fields to a Thingspeak channel using MQTT
PUBLISH_PERIOD_IN_SEC = 10 

while True:
    try:
        t = round(bme.temperature(),1)
        p = round(bme.pressure(),1)
        h = round(bme.humidity(),1)
        credentials = bytes("channels/{:s}/publish".format(THINGSPEAK_CHANNEL_ID), 'utf-8')  
        payload = bytes("field1={:.1f}&field2={:.1f}&field3={:.1f}\n".format(t, p ,h), 'utf-8')
        client.publish(credentials, payload)
        oled.fill(0)
        oled.show()
        oled.text('Envio de ', 0, 10)
        oled.text('datos', 0, 30)
        oled.text('exitoso . . .', 0, 50)
        oled.show()
        time.sleep(PUBLISH_PERIOD_IN_SEC)
    except KeyboardInterrupt:
        print('Ctrl-C pressed...exiting')
        client.disconnect()
        red.disconnect()
        oled.fill(0)
        oled.show()
        oled.text('Desconectado ', 0, 10)
        oled.text('datos', 0, 30)
        oled.text('exitoso . . .', 0, 50)
        oled.show()
        oled.fill(0)
        oled.show()
        break
#=======================================================