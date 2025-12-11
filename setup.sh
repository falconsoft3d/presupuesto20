#!/bin/bash

# Script de inicialización para Presupuesto de Obras
# Este script configura y ejecuta la aplicación

echo "🏗️  Presupuesto de Obras - Inicialización"
echo "=========================================="
echo ""

# Verificar versión de Flutter
echo "📋 Verificando Flutter..."
flutter --version

FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
echo "Versión actual: $FLUTTER_VERSION"
echo ""

# Habilitar soporte de escritorio para macOS
echo "🖥️  Habilitando soporte de escritorio para macOS..."
flutter config --enable-macos-desktop
echo ""

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean
echo ""

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get
echo ""

# Verificar si la instalación fue exitosa
if [ $? -eq 0 ]; then
    echo "✅ Dependencias instaladas correctamente"
    echo ""
    
    # Generar código de Drift
    echo "⚙️  Generando código de Drift..."
    dart run build_runner build --delete-conflicting-outputs
    echo ""
    
    if [ $? -eq 0 ]; then
        echo "✅ Código generado correctamente"
        echo ""
        echo "🎉 ¡Configuración completada!"
        echo ""
        echo "Para ejecutar la aplicación:"
        echo "  flutter run -d macos"
        echo ""
        echo "Para compilar para producción:"
        echo "  flutter build macos --release"
        echo ""
    else
        echo "❌ Error al generar código"
        echo "Intenta ejecutar manualmente:"
        echo "  dart run build_runner build --delete-conflicting-outputs"
    fi
else
    echo "❌ Error al instalar dependencias"
    echo ""
    echo "Si ves errores de versión de SDK, actualiza Flutter:"
    echo "  flutter upgrade"
    echo ""
    echo "Luego ejecuta este script nuevamente."
fi
