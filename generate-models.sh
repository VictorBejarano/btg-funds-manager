#!/bin/bash

SCHEMA_DIR="libs/shared/contracts/src/lib/schemas"
TS_OUT_DIR="libs/shared/contracts/src/lib/models"
DART_OUT_DIR="apps/flutter-app/lib/models"
INDEX_FILE="$TS_OUT_DIR/index.ts"

mkdir -p "$TS_OUT_DIR"
mkdir -p "$DART_OUT_DIR"

echo "// No editar manualmente. Generado automáticamente." > "$INDEX_FILE"
echo "" >> "$INDEX_FILE"

echo "🚀 Iniciando generación masiva de modelos..."

for SCHEMA_FILE in "$SCHEMA_DIR"/*.schema.json; do
  
  [ -e "$SCHEMA_FILE" ] || continue

  BASENAME=$(basename "$SCHEMA_FILE" .schema.json)

  echo "----------------------------------------"
  echo "📦 Procesando esquema: $BASENAME"
  
  echo "   -> Generando $BASENAME.ts"
  npx quicktype -s schema "$SCHEMA_FILE" \
    -o "$TS_OUT_DIR/${BASENAME}.ts" \
    --just-types

  echo "export * from './$BASENAME';" >> "$INDEX_FILE"

  echo "   -> Generando ${BASENAME}.dart"
  npx quicktype -s schema "$SCHEMA_FILE" \
    -o "$DART_OUT_DIR/${BASENAME}.dart" \
    --null-safety
    
done

echo "----------------------------------------"
echo "✅ ¡Todos los modelos se generaron con éxito!"
echo "📄 Index generado en: $INDEX_FILE"