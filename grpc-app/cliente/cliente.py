import grpc
import ejemplo_pb2
import ejemplo_pb2_grpc

def ejecutar():
    with grpc.insecure_channel('localhost:50051') as canal:
        stub = ejemplo_pb2_grpc.ServicioEjemploStub(canal)
        
        # Llamada a Saludar
        respuesta_saludo = stub.Saludar(
            ejemplo_pb2.SolicitudSaludo(nombre="Mundo"))
        print("Respuesta del servidor:", respuesta_saludo.mensaje)
        
        # Llamada a Sumar
        respuesta_suma = stub.Sumar(
            ejemplo_pb2.SolicitudSuma(a=5, b=3))
        print("Resultado de la suma:", respuesta_suma.resultado)

if __name__ == '__main__':
    ejecutar()