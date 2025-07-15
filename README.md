# DevOps Challenge - Nginx + Redis

## Descripción
Aplicación Nginx que muestra "Hello World" y estado de conexión contra Redis, desplegada en Kubernetes usando Helm.

**📌 Métodos de Despliegue Disponibles:**
Este proyecto incluye **3 métodos** para desplegar la aplicación:
- **Helm** (Recomendado - documentado a continuación)
- **Terraform** 
- **Manifiestos K8s directos**

En esta guía utilizaremos **Helm** como método principal. Si deseas usar otro método, consulta la sección [Métodos Alternativos](#métodos-alternativos-opcionales) más abajo.

## Arquitectura
- **K3s**: Cluster Kubernetes local
- **Redis**: Base de datos
- **Nginx**: Servidor web (escalable 1-3 réplicas)
- **Helm**: Gestión de deployments con values configurables
- **GitHub Actions**: CI/CD pipeline automatizado

#### Estructura del Proyecto
```
devops-challenge/
├── app/                    # Aplicación Nginx personalizada
├── helm-chart/            # Chart Helm (método principal)
├── terraform-local/        # Alternativa con Terraform
├── k8s-manifests/         # Alternativa con manifiestos
└── .github/workflows/     # Pipeline CI/CD
```

## Requisitos Previos
- Ubuntu 20.04+
- 12GB RAM mínimo
- Git

## Instalación y Despliegue usando HELM
### 1. Instalar Dependencias(Todas Requeridas)
**Necesitas instalar las siguientes 3 herramientas:**
```
# Docker
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker

# Verificar Docker
docker run hello-world
```
```
# K3s
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable=traefik
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Verificar K3s
kubectl get nodes
```
```
# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar Helm
helm version
```
### 2. Clonar Repositorio
```
git clone https://github.com/Leonel-Marini/devops-challenge-LeonelMarini.git
cd devops-challenge-LeonelMarini
```
### 3. Construir y Preparar Aplicación
```
cd app
docker build -t nginx-app:local .
docker save nginx-app:local -o nginx-app.tar
sudo k3s ctr images import nginx-app.tar
cd ..
```
### 4. Configurar DNS Local
```
echo "127.0.0.1 devops-challenge.local" | sudo tee -a /etc/hosts
```
### 5. Desplegar con Helm
```
cd helm-chart
kubectl create namespace devops-challenge
helm install nginx-app ./nginx-app -n devops-challenge
```
### 6. Verificar y Activar Aplicación
```
# Esperar que los pods estén listos
kubectl wait --for=condition=ready pod -l app=nginx-app -n devops-challenge --timeout=60s

# Activar la aplicación con imagen local
kubectl rollout restart deployment/nginx-app -n devops-challenge
kubectl rollout status deployment/nginx-app -n devops-challenge

# Probar aplicación
curl http://devops-challenge.local:30080
```
##### Resultado esperado:
```
 Hello World
 Redis Connection: Connected
```
**🎉 ¡Felicidades! Has desplegado tu aplicación Nginx + Redis mediante Helm! Intenta ingresar a http://devops-challenge.local:30080 desde tu navegador.**

#### CI/CD Pipeline
**Nota:** Este paso es únicamente conceptual ya que he creado el challenge con recursos locales y no cloud. Si quieres ver el action corriendo, deberás hacer un push de un cambio simple y desde la sección Actions, podrás ver el job corriendo.

El pipeline de GitHub Actions se ejecuta automáticamente cuando se hace push al repositorio:
- Construye la imagen Docker
- Ejecuta tests de funcionalidad
- Simula el despliegue con Helm
- Valida el funcionamiento

#### Métodos Alternativos (Opcionales)

**⚠️ Importante:** Si ya desplegaste con Helm, debes realizar la limpieza correspondiente antes de probar otro método. Dirígete a la sección [Si desplegaste con Helm](#si-desplegaste-con-helm) y luego regresa aquí.

El proyecto incluye otras formas de despliegue para diferentes escenarios:

#### Terraform
```
cd ~/devops-challenge-LeonelMarini/
echo "127.0.0.1 devops-challenge.local" | sudo tee -a /etc/hosts
cd app
sudo k3s ctr images import nginx-app.tar
cd ../terraform-local
terraform init
terraform apply -auto-approve
kubectl rollout restart deployment/nginx-app -n devops-challenge
kubectl rollout status deployment/nginx-app -n devops-challenge
```
**🎉 ¡Felicidades! Has desplegado tu aplicación Nginx + Redis mediante Terraform! Intenta ingresar a http://devops-challenge.local:30080 desde tu navegador.**

#### Manifiestos K8s directos
```
cd ~/devops-challenge-LeonelMarini
echo "127.0.0.1 devops-challenge.local" | sudo tee -a /etc/hosts
cd app
sudo k3s ctr images import nginx-app.tar
cd ..
kubectl apply -f k8s-manifests/
kubectl rollout restart deployment/nginx-app -n devops-challenge
kubectl rollout status deployment/nginx-app -n devops-challenge
```
**🎉 ¡Felicidades! Has desplegado tu aplicación Nginx + Redis mediante Manifiestos K8s! Intenta ingresar a http://devops-challenge.local:30080 desde tu navegador.**

## Gestión y ⚠️ Troubleshooting
#### Ver estado del deployment
```
kubectl get all -n devops-challenge
kubectl logs deployment/nginx-app -n devops-challenge
```
#### Si la aplicación muestra "Disconnected"
```
kubectl rollout restart deployment/nginx-app -n devops-challenge
```
#### Si necesito modificar número de réplicas
```
helm upgrade nginx-app ./nginx-app --set replicaCount=2 -n devops-challenge
```


## Limpieza final del Entorno
### Limpieza por Método de Despliegue
### Si desplegaste con Helm
```
helm uninstall nginx-app -n devops-challenge
kubectl delete namespace devops-challenge
sudo sed -i '/devops-challenge.local/d' /etc/hosts
docker rmi nginx-app:local 2>/dev/null || true
sudo k3s ctr images rm docker.io/library/nginx-app:local 2>/dev/null || true
cd ~/devops-challenge-LeonelMarini
```
### Si desplegaste con Terraform
```
cd ~/devops-challenge-LeonelMarini/terraform-local
terraform destroy -auto-approve
cd ..
sudo sed -i '/devops-challenge.local/d' /etc/hosts
docker rmi nginx-app:local 2>/dev/null || true
sudo k3s ctr images rm docker.io/library/nginx-app:local 2>/dev/null || true
cd ~/devops-challenge-LeonelMarini
```
### Si desplegaste con Manifiestos K8s
```
kubectl delete -f k8s-manifests/
kubectl get all -n devops-challenge
sudo sed -i '/devops-challenge.local/d' /etc/hosts
docker rmi nginx-app:local 2>/dev/null || true
sudo k3s ctr images rm docker.io/library/nginx-app:local 2>/dev/null || true
cd ~/devops-challenge-LeonelMarini
```

### Limpieza Completa del Sistema (No olvides eliminar todo⚠️)
Si quieres eliminar completamente todo y volver al estado anterior de iniciar el challenge:
```
# Parar y desinstalar K3s
sudo systemctl stop k3s
sudo /usr/local/bin/k3s-uninstall.sh

# Eliminar configuraciones kubectl
rm -rf ~/.kube

# Eliminar Helm
sudo rm /usr/local/bin/helm

# Eliminar folderr del proyecto
cd ~
rm -rf devops-challenge-LeonelMarini

# Verificar limpieza
kubectl version --client 2>/dev/null || echo "✅ kubectl eliminado"
helm version 2>/dev/null || echo "✅ Helm eliminado"
ls devops-challenge-LeonelMarini 2>/dev/null || echo "✅ Proyecto eliminado"
```
