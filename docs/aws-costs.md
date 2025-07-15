# Estimación de Costos AWS

## Metodología
Costos calculados usando [AWS Pricing Calculator](https://calculator.aws/) para región **us-east-1** (N. Virginia), basado en un entorno de desarrollo/testing con tráfico moderado.

## Componentes y Costos Mensuales

### Infraestructura Principal
| Servicio | Especificación | Costo Mensual |
|----------|----------------|---------------|
| **Amazon EKS** | 1 Cluster + 1 hybrid node | $73.00 |
| **Amazon EC2** | 2x t3.medium (Linux, On-Demand) | $60.74 |
| **Amazon ElastiCache** | 1x cache.t3.micro Redis | $12.41 |
| **Amazon S3** | Standard Storage (1GB) | $0.02 |

### Networking y Load Balancing
| Servicio | Especificación | Costo Mensual |
|----------|----------------|---------------|
| **Application Load Balancer** | 1 ALB con configuración básica | $17.01 |
| **VPC - NAT Gateway** | 1 NAT Gateway + Data Transfer | $33.61 |
| **VPC - Public IPv4** | 2 direcciones IP públicas | $7.30 |

## Resumen de Costos

### **TOTAL ESTIMADO: $204.09/mes USD**
### **Costo anual: $2,449.08 USD**

### Distribución por categoría:
- **Compute (EKS + EC2)**: $133.74 (65.5%)
- **Networking**: $57.92 (28.4%)
- **Database (Redis)**: $12.41 (6.1%)
- **Storage**: $0.02 (<0.1%)

## Configuración de Tráfico Utilizada

### Data Transfer:
- **Inbound**: 0 TB/mes (requests HTTP mínimos)
- **Outbound**: 3 GB/mes (respuestas HTML + APIs)
- **Intra-Region**: 2 GB/mes (comunicación pod-to-pod)

### Load Balancer:
- **Conexiones**: ~10/minuto
- **Requests**: ~5/segundo
- **Duración promedio**: 5 segundos
- **Data processed**: 0.1 GB/hora

## Optimizaciones para Reducir Costos

### Para Desarrollo (Ahorro ~$70/mes):

EC2: Cambiar a t3.small → -$30/mes
ElastiCache: Usar t2.micro → -$3/mes
Una sola instancia EC2 → -$30/mes
Menor data transfer → -$7/mes

Costo optimizado: ~$134/mes

### Para Producción (Ahorro 30-40%):

Reserved Instances (1 año) → -$40-60/mes
Savings Plans → -$20-30/mes adicionales
Spot Instances para workers → -$25-35/mes

Costo con reservas: ~$140-160/mes

## Consideraciones Adicionales

### No incluido en la estimación:
- **AWS Support Plan** ($29-100/mes según nivel)
- **CloudWatch Logs** (~$0.50/GB)
- **Route 53 DNS** (~$0.50/zona + $0.40/millón queries)
- **Taxes** (varían por región)

### Escalabilidad:
- **Auto Scaling habilitado**: Costos variables según demanda
- **Multi-AZ**: +50% en RDS/ElastiCache si se requiere HA
- **Backup automático**: +10-15% en storage costs

## Comparación con Competidores

| Provider | Configuración Similar | Costo Estimado/Mes |
|----------|----------------------|-------------------|
| **AWS** | EKS + EC2 + ElastiCache | **$204** |
| **Google Cloud** | GKE + Compute + Memorystore | ~$185 |
| **Azure** | AKS + VM + Redis Cache | ~$195 |

## Conclusión

Para un entorno de **desarrollo/testing** como el que utilicé en este challenge, el costo de **~$204/mes** es razonable si consideramos:

- ✅ **Infraestructura managed** (EKS, ElastiCache)
- ✅ **Alta disponibilidad** (Load Balancer, Multi-AZ)
- ✅ **Escalabilidad automática**
- ✅ **Security y compliance** AWS

**Para producción real**, se recomienda usar Reserved Instances y optimizar según patrones de tráfico reales.

---
*Precios calculados en Julio 2025 - Sujetos a cambios según políticas AWS*
