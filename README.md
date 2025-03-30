EXPLICACION DEL NETWORKING

En el modulo de network se configuraron los siguiente recursos:



1. VPC (Virtual Private Cloud)

- Crea una VPC (red privada virtual) en AWS.

- count permite crear la VPC condicionalmente basado en la variable create_vpc.

- cidr_block define el rango de direcciones IP para la VPC.

- instance_tenancy especifica si las instancias EC2 serán multi-tenant o single-tenant.

- enable_dns_hostnames y enable_dns_support habilitan funciones DNS.

- Se añaden tags para identificación.

2. Internet Gateway

- Crea un Internet Gateway para permitir tráfico entre la VPC e Internet.

- Se crea condicionalmente basado en variables create_vpc y create_igw.

- Se asocia a la VPC creada anteriormente.

3. NAT Gateway

- aws_eip crea una IP elástica para el NAT Gateway.

- aws_nat_gateway crea un NAT Gateway que permite a instancias en subredes privadas conectarse a Internet (salida) sin exponerlas a conexiones entrantes.

- Se coloca en la primera subred pública.

4. Tabla de rutas para subredes privadas

- Crea una tabla de rutas para subredes privadas.

- Añade una ruta por defecto (0.0.0.0/0) que dirige el tráfico al NAT Gateway.

- Asocia la tabla de rutas con las subredes privadas.

5. Tabla de rutas para subredes públicas

- Crea una tabla de rutas para subredes públicas.

- Añade una ruta por defecto (0.0.0.0/0) que dirige el tráfico al Internet Gateway.

- Asocia la tabla de rutas con las subredes públicas.

6. Subredes privadas

- Crea múltiples subredes privadas basadas en la lista private_subnet_cidrs.

- Cada subred se coloca en una zona de disponibilidad diferente.

- Se asignan tags identificativos.

7. Subredes públicas

- Crea múltiples subredes públicas basadas en la lista public_subnet_cidrs.

- Cada subred se coloca en una zona de disponibilidad diferente.

- Se asignan tags identificativos.

Este diseño crea una arquitectura de red típica con:

- Una VPC dividida en subredes públicas y privadas

- Un Internet Gateway para tráfico público

- Un NAT Gateway para tráfico saliente desde subredes privadas

- Tablas de ruta adecuadas para cada tipo de subred

- Distribución en múltiples zonas de disponibilidad para alta disponibilidad


EXPLICACION DEL DESPLIEGUE

1. Estructura Básica

La versión: se configura la version a desplegar

2. Fase install (Instalación)

- Configura Docker como runtime principal

- Actualiza los paquetes e instala AWS CLI (necesario para interactuar con ECR)

- Verifica las versiones de AWS CLI y Docker (para debugging)

3. Fase pre_build (Pre-construcción)

- Imprime mensajes informativos y verifica versiones

- Inicializa Terraform (terraform init)

- Autenticación con ECR:

        Realiza login en Amazon ECR (Elastic Container Registry)

        Configura variables:

- Obtiene la URI del repositorio ECR llamado "grpc-app"

- Crea un tag basado en el hash del commit (7 primeros caracteres)

- Si no hay hash (ej. en builds manuales), usa "latest" como tag