#!/bin/bash

PROJECT_ID="btg-funds-manager"
COLLECTION="funds"
TOKEN="INGRESE TOKEN DE OAuth 2.0 Playground"

echo "🚀 Iniciando carga con IDs auto-asignados por Firestore..."

# Definición de fondos
names=(
  "Fondo Acciones Global" "Renta Fija Colombia" "Dinamismo Inmobiliario"
  "BTG Pactual Liquidez" "Acciones Petróleo & Gas" "Fondo Deuda Privada"
  "Emergentes Asia" "Sostenibilidad ESG" "Fiducuenta Plus"
  "Bonos Grado Inversión" "Acciones Tech USA" "Renta Fija Corto Plazo"
  "Global Real Estate" "Commodities Energéticos" "BTG Estrategia Lider"
  "Fondo Infraestructura" "Multiactivo Moderado" "Crecimiento Dividendos"
  "Renta Fija Emergente" "Acciones Europa" "Fondo Factoring Bogotá"
  "Global Bond ETF" "BTG Oportunidades" "Estrategia Colectiva"
  "Fondo Oro y Metales" "Acciones India & China" "Deuda Pública Local"
  "Liderazgo Femenino ESG" "Cripto-Activos Index" "Consumo Masivo Latam"
  "Fondo Ganadero" "Renta Inmobiliaria Bodegas" "BTG Conservador"
)

cats=(
  "Acciones" "Deuda" "Fondo Inmobiliario"
  "Renta Fija" "Acciones" "Deuda"
  "Acciones" "Sostenible" "Renta Fija"
  "Deuda" "Acciones" "Renta Fija"
  "Fondo Inmobiliario" "Commodities" "Multiactivo"
  "Infraestructura" "Multiactivo" "Acciones"
  "Deuda" "Acciones" "Deuda"
  "Renta Fija" "Multiactivo" "Renta Fija"
  "Commodities" "Acciones" "Deuda"
  "Sostenible" "Acciones" "Acciones"
  "Commodities" "Fondo Inmobiliario" "Renta Fija"
)

mins=(
  50000 100000 500000
  10000 200000 150000
  300000 50000 25000
  120000 250000 15000
  1000000 400000 200000
  750000 100000 80000
  90000 350000 50000
  45000 150000 20000
  600000 400000 100000
  50000 300000 100000
  250000 850000 15000
)

apys=(
  12.5 9.8 15.2
  8.2 18.4 10.5
  14.1 11.2 7.9
  9.2 22.5 8.5
  13.8 19.1 11.5
  16.4 10.2 13.5
  10.8 17.2 12.1
  8.9 14.5 9.1
  20.5 18.9 9.5
  11.8 25.4 12.8
  15.5 14.2 8.1
)

for i in ${!names[@]}; do
    NAME=${names[$i]}
    CAT=${cats[$i]}
    MIN=${mins[$i]}
    APY=${apys[$i]}

    echo "📦 Insertando: $NAME..."

    JSON_BODY="{
      \"fields\": {
        \"name\": {\"stringValue\": \"$NAME\"},
        \"category\": {\"stringValue\": \"$CAT\"},
        \"minInvestment\": {\"doubleValue\": $MIN},
        \"targetApy\": {\"doubleValue\": $APY},
        \"status\": {\"stringValue\": \"ACTIVE\"},
        \"createdAt\": {\"timestampValue\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}
      }
    }"

    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON_BODY" \
        "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/$COLLECTION")

    if [[ $RESPONSE == *"error"* ]]; then
        echo "❌ Error al insertar $NAME: $RESPONSE"
    else
        NEW_ID=$(echo $RESPONSE | sed -e 's/.*"name": "\(.*\)".*/\1/' | awk -F'/' '{print $NF}')
        echo "✅ Insertado con ID: $NEW_ID"
    fi
done

echo "🎉 Proceso terminado. ¡Revisa tu consola de Firebase!"