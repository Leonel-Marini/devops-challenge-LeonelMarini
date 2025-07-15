#!/bin/sh

REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}

# Función para verificar Redis
update_html() {
    # Restaurar template
    cp /tmp/index_template.html /usr/share/nginx/html/index.html
    
    # Verificar conexión Redis (sin contador)
    if redis-cli -h $REDIS_HOST -p $REDIS_PORT ping >/dev/null 2>&1; then
        REDIS_STATUS="Connected"
    else
        REDIS_STATUS="Disconnected"
    fi
    
    # Actualizar HTML
    sed -i "s/REDIS_STATUS_PLACEHOLDER/$REDIS_STATUS/" /usr/share/nginx/html/index.html
}

# Actualizar una vez al inicio
update_html

# Iniciar nginx
exec nginx -g "daemon off;"
