import grpc
from concurrent import futures
import ejemplo_pb2
import ejemplo_pb2_grpc

class ServicioEjemplo(ejemplo_pb2_grpc.ServicioEjemploServicer):
    def Saludar(self, request, context):
        mensaje = f"Hola, {request.nombre}!"
        return ejemplo_pb2.RespuestaSaludo(mensaje=mensaje)
    
    def Sumar(self, request, context):
        resultado = request.a + request.b
        return ejemplo_pb2.RespuestaSuma(resultado=resultado)

def servir():
    servidor = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    ejemplo_pb2_grpc.add_ServicioEjemploServicer_to_server(
        ServicioEjemplo(), servidor)
    servidor.add_insecure_port('[::]:50051')
    servidor.start()
    print("Servidor gRPC iniciado en el puerto 50051...")
    servidor.wait_for_termination()

if __name__ == '__main__':
    servir()