#!/bin/bash

# 1. Definimos las rutas base
SCHEMA_DIR="libs/shared/contracts/src/lib/schemas"
TS_OUT_DIR="libs/shared/contracts/src/lib/models"
DART_OUT_DIR="apps/flutter-app/lib/models"
INDEX_FILE="$TS_OUT_DIR/index.ts"

# 2. Nos aseguramos de que las carpetas de destino existan
mkdir -p "$TS_OUT_DIR"
mkdir -p "$DART_OUT_DIR"

# 3. Limpiamos o creamos el index.ts desde cero
echo "// No editar manualmente" >> "$INDEX_FILE"
echo "" >> "$INDEX_FILE"

echo "🚀 Iniciando generación masiva de modelos..."

# 4. Iteramos sobre todos los archivos que terminen en .schema.json
for SCHEMA_FILE in "$SCHEMA_DIR"/*.schema.json; do
  
  # Si no hay archivos, el bucle falla de forma segura
  [ -e "$SCHEMA_FILE" ] || continue

  # Extraemos el nombre base (ej. de "user.schema.json" sacamos "user")
  BASENAME=$(basename "$SCHEMA_FILE" .schema.json)

  echo "----------------------------------------"
  echo "📦 Procesando esquema: $BASENAME"
  
  # Generar TypeScript (Angular / Node)
  echo "   -> Generando $BASENAME.ts"
  npx quicktype -s schema "$SCHEMA_FILE" \
    -o "$TS_OUT_DIR/${BASENAME}.ts" \
    --just-types

  # AGREGADO: Añadir la exportación al index.ts
  echo "export * from './$BASENAME';" >> "$INDEX_FILE"

  # Generar Dart (Flutter)
  echo "   -> Generando ${BASENAME}.dart"
  npx quicktype -s schema "$SCHEMA_FILE" \
    -o "$DART_OUT_DIR/${BASENAME}.dart" \
    --null-safety
    
done

echo "----------------------------------------"
echo "✅ ¡Todos los modelos se generaron con éxito!"
echo "📄 Index generado en: $INDEX_FILE"