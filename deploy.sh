#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# CALCULADORA LEY 73 — AUTO-DEPLOY A CLOUDFLARE PAGES
# ═══════════════════════════════════════════════════════════════════════════

# Credenciales desde variables de entorno
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-64a5c8a2f6769b3d03a8848c4d257b3e}"
PROJECT_NAME="${CLOUDFLARE_PROJECT_NAME:-calculadora73}"

# Validar que existe el token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN no configurado"
    echo "Configura primero en GitHub: Settings → Secrets and variables → Actions"
    exit 1
fi

echo "🚀 Iniciando deploy automático..."
echo "Proyecto: $PROJECT_NAME"
echo "Cuenta: $ACCOUNT_ID"

# Verificar que estamos en el repo correcto
if [ ! -f "index.html" ]; then
    echo "❌ Error: index.html no encontrado"
    exit 1
fi

echo "✅ Archivo index.html verificado"

# Obtener último commit
LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s")
echo "📝 Último commit: $LAST_COMMIT"

# Triggear deploy en Cloudflare Pages
echo "📤 Triggeando deploy en Cloudflare..."

RESPONSE=$(curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}')

echo "📡 Respuesta de Cloudflare:"
echo "$RESPONSE"

# Verificar si fue exitoso
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo ""
    echo "✅ DEPLOY EXITOSO"
    echo "🌐 Sitio en vivo: https://pensionley73.com"
    echo "⏱️  Espera 30-60 segundos para que se actualice"
    exit 0
elif echo "$RESPONSE" | grep -q 'error'; then
    echo ""
    echo "❌ Error en el deploy"
    echo "Verifica el token de Cloudflare"
    exit 1
else
    echo ""
    echo "⚠️ Respuesta desconocida — verifica manualmente"
    exit 1
fi
