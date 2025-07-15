FROM nginx:alpine

# Instalar redis-tools para conectividad
RUN apk add --no-cache redis

# Crear directorio y copiar archivos
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY update-counter.sh /usr/local/bin/update-counter.sh
RUN chmod +x /usr/local/bin/update-counter.sh

# Verificar que el archivo se copió
RUN ls -la /usr/share/nginx/html/

# Usar script que ejecuta nginx en background y actualiza HTML
CMD ["/usr/local/bin/update-counter.sh"]
