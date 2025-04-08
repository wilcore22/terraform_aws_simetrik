FROM python:3.9-slim

WORKDIR /app

# Copiar los archivos necesarios
COPY proto/ejemplo.proto .
COPY cliente.py .
COPY requirements.txt .

# Instalar dependencias y generar código gRPC
RUN pip install --no-cache-dir -r requirements.txt && \
    python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. ejemplo.proto

CMD ["python", "cliente.py"]