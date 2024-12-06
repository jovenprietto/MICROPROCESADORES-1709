#=======================================================
#importacion de modulos para manejo de temporizadores y clase basica de mqtt client
#=======================================================
import utime
from . import simple

#=======================================================
# Definición de constantes: 
#=======================================================
class MQTTClient(simple.MQTTClient):
    DELAY = 2
    DEBUG = False

#=======================================================
# Método para agregar retraso (sleep) entre intentos de reconexión
#=======================================================

    def delay(self, i):
        utime.sleep(self.DELAY)

#=======================================================
    # Método para registrar los errores de conexión y reconexión (usado para depuración)
#=======================================================
    def log(self, in_reconnect, e):
        if self.DEBUG:
            if in_reconnect:
                print("mqtt reconnect: %r" % e)
            else:
                print("mqtt: %r" % e)

#=======================================================
# Método para reconectar al servidor MQTT en caso de desconexión
#=======================================================
    def reconnect(self):
        i = 0
        while 1:
            try:
                return super().connect(False)
            except OSError as e:
                self.log(True, e)
                i += 1
                self.delay(i)

#=======================================================
# Método para publicar un mensaje en un tópico
#=======================================================
    def publish(self, topic, msg, retain=False, qos=0):
        while 1:
            try:
                return super().publish(topic, msg, retain, qos)
            except OSError as e:
                self.log(False, e)
            self.reconnect()

#=======================================================
# Método para esperar por mensajes del servidor
#=======================================================
    def wait_msg(self):
        while 1:
            try:
                return super().wait_msg()
            except OSError as e:
                self.log(False, e)
            self.reconnect()

#=======================================================
# Método para verificar si hay mensajes, con intentos limitados
#=======================================================
    def check_msg(self, attempts=2):
        while attempts:
            self.sock.setblocking(False)
            try:
                return super().wait_msg()
            except OSError as e:
                self.log(False, e)
            self.reconnect()
            attempts -= 1