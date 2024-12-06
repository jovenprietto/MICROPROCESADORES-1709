#=======================================================
# Importación de los módulos y librerías necesarias
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

i2c = SoftI2C(scl=Pin(19), sda=Pin(18))
oled_width = 128
oled_height = 64
oled = oled.SSD1306_I2C(oled_width, oled_height, i2c)

#=======================================================
# Configuración de la red WiFi
#=======================================================

SSID = 'TOTALPLAY78_2.4Gnormal_plus'  # Nombre de la red WiFi
PASSWORD = 'T4rgaryen88'  # Contraseña de la red WiFi

#=======================================================
# Inicialización de la red WiFi
#=======================================================

red = network.WLAN(network.STA_IF)
red.active(True)
red.connect(SSID, PASSWORD)

#=======================================================
# Espera hasta que la conexión sea exitosa
#=======================================================
while red.isconnected() == False:
  pass
oled.text('Conexion Wi-Fi', 0, 30)
oled.text('establecida ', 0, 45)
oled.show()
print('Conexion correcta')
print(red.ifconfig())
time.sleep(5)

#=======================================================
# Inicialización del bus I2C y el sensor BME280
#=======================================================

i2c = I2C(0, sda=Pin(20), scl=Pin(21))  # Cambiar pines según sea necesario


bme = bme280.BME280(i2c=i2c)

#=======================================================
# Configuración MQTT y ThingSpeak para publicación
#=======================================================

THINGSPEAK_MQTT_CLIENT_ID = b"JDErAQAKGzsiGygcNS4OIQ0" 
THINGSPEAK_MQTT_USERNAME = b"JDErAQAKGzsiGygcNS4OIQ0"  
THINGSPEAK_MQTT_PASSWORD = b"E30DsywKdTAuL9txJXykesqI"  
THINGSPEAK_CHANNEL_ID = b'2773559'  

#=======================================================
# Configuración del cliente MQTT para publicación
#=======================================================
client = MQTTClient(
    server=b"mqtt3.thingspeak.com",
    client_id=THINGSPEAK_MQTT_CLIENT_ID,
    user=THINGSPEAK_MQTT_USERNAME,
    password=THINGSPEAK_MQTT_PASSWORD,
    ssl=False
)

#=======================================================
# Configuración MQTT y ThingSpeak para suscripción
#=======================================================

THINGSPEAK_URL = b"mqtt3.thingspeak.com"  
THINGSPEAK_USER_ID = b'DBo7EyEcHC0JFwolCw4JBiQ'  
THINGSPEAK_MQTT_API_KEY = b'OREuqxHTberIfMXPQO9TEC36'  

#=======================================================
# Configuración del cliente MQTT para suscripción
#=======================================================
client2 = MQTTClient(
    client_id=b'DBo7EyEcHC0JFwolCw4JBiQ',
    server=THINGSPEAK_URL,
    user=THINGSPEAK_USER_ID,
    password=THINGSPEAK_MQTT_API_KEY,
    ssl=False
)

#=======================================================
# Definición de la función de callback para MQTT
#=======================================================

def cb(topic, msg):
    print((topic, msg))
    try:
        avg_temp = float(str(msg, 'utf-8'))
        print(f"Promedio de temperatura recibido: {avg_temp}")
        if avg_temp > 28:
            print("Calor intenso")
            oled.fill(0)
            oled.show()
            oled.text('Exceso de ', 0, 10)
            oled.text('Temperatura', 0, 30)
            oled.text('registrado . . .', 0, 50)
            oled.show()

    except ValueError:
        print("Error al convertir el mensaje a float.")

client2.set_callback(cb)  

#=======================================================
# Conexión a los servidores MQTT
#=======================================================

try:
    client.connect()
except Exception as e:
    print(f'Error al conectar al servidor MQTT de publicación: {type(e).__name__} {e}')
    sys.exit()

try:
    client2.connect()
except Exception as e:
    print(f'Error al conectar al servidor MQTT de suscripción: {type(e).__name__} {e}')
    sys.exit()
oled.fill(0)
oled.show()
oled.text('Conexion al ', 0, 10)
oled.text('servidor', 0, 30)
oled.text('establecida', 0, 50)
oled.show()
time.sleep(5)
#=======================================================
# Suscripción a un canal de ThingSpeak
#=======================================================

THINGSPEAK_CHANNEL_ID = b'2776651'  # ID del canal para suscripción
THINGSPEAK_CHANNEL_READ_API_KEY = b'TC790SJD93J7BEEM'  # Clave API para suscripción

#=======================================================
# Tópico de suscripción
#=======================================================
subscribeTopic = bytes(
    "channels/{:s}/subscribe/fields/field1/{:s}".format(THINGSPEAK_CHANNEL_ID, THINGSPEAK_CHANNEL_READ_API_KEY),
    'utf-8'
)

#=======================================================
# suscribirse al canal
#=======================================================

try:
    client2.subscribe(subscribeTopic)
except Exception as e:
    print(f"Error al suscribirse: {e}")

#=======================================================
# Bucle principal para publicación y recepción de datos
#=======================================================

PUBLISH_PERIOD_IN_SEC = 10  

while True:
    try:
        
        client2.wait_msg()

        # Leer datos del sensor BME280
        t = round(bme.temperature(), 1)
        p = round(bme.pressure(), 1)
        h = round(bme.humidity(), 1)

        # Formar los datos de publicación
        credentials = bytes("channels/{:s}/publish".format(THINGSPEAK_CHANNEL_ID), 'utf-8')
        payload = bytes(f"field1={t}&field2={p}&field3={h}\n", 'utf-8')

        # Publicar datos al canal de ThingSpeak
        client.publish(credentials, payload)
        oled.fill(0)
        oled.show()
        oled.text('Envio de ', 0, 10)
        oled.text('datos', 0, 30)
        oled.text('exitoso . . .', 0, 50)
        oled.show()
        # Esperar el siguiente ciclo de publicación
        time.sleep(PUBLISH_PERIOD_IN_SEC)
    except KeyboardInterrupt:
        print('Ctrl-C presionado...saliendo')
        client.disconnect()
        client2.disconnect()
        red.disconnect()
        break
#=======================================================
