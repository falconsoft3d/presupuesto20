# Instrucciones de Instalación - Presupuesto de Obras

## ⚠️ Importante: Actualizar Flutter

Tu versión actual de Flutter (3.3.10) es antigua. **Debes actualizar Flutter** antes de ejecutar la aplicación.

### Actualizar Flutter

```bash
flutter upgrade
```

Esto actualizará Flutter a la última versión estable (3.24+) que incluye Dart 3.x necesario para las dependencias.

## Pasos de Instalación

Una vez actualizado Flutter:

### 1. Verificar la versión
```bash
flutter --version
# Debe mostrar Flutter 3.24+ y Dart 3.x+
```

### 2. Habilitar soporte de escritorio

#### Para macOS:
```bash
flutter config --enable-macos-desktop
```

#### Para Windows:
```bash
flutter config --enable-windows-desktop
```

### 3. Instalar dependencias
```bash
cd /Users/marlonfalcon/Documents/Projects/presupuesto20
flutter pub get
```

### 4. Generar código de Drift
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Ejecutar la aplicación

#### En macOS:
```bash
flutter run -d macos
```

#### En Windows:
```bash
flutter run -d windows
```

## Problemas Comunes

### Error: "SDK version solving failed"
**Solución:** Actualiza Flutter con `flutter upgrade`

### Error: "No device found"
**Solución:** Asegúrate de habilitar el soporte de escritorio con `flutter config --enable-macos-desktop` o `--enable-windows-desktop`

### Error al generar código de Drift
**Solución:** Ejecuta `flutter clean` y luego `flutter pub get` antes de ejecutar el build_runner

## Verificar Instalación Correcta

Después de actualizar Flutter, ejecuta:

```bash
flutter doctor -v
```

Esto te mostrará el estado de tu instalación. Asegúrate de que:
- ✓ Flutter está en la última versión
- ✓ Dart SDK está actualizado
- ✓ El soporte de escritorio está habilitado

## Estructura de Comandos Completa

```bash
# 1. Actualizar Flutter
flutter upgrade

# 2. Navegar al proyecto
cd /Users/marlonfalcon/Documents/Projects/presupuesto20

# 3. Habilitar escritorio (macOS)
flutter config --enable-macos-desktop

# 4. Limpiar proyecto
flutter clean

# 5. Instalar dependencias
flutter pub get

# 6. Generar código
dart run build_runner build --delete-conflicting-outputs

# 7. Ejecutar
flutter run -d macos
```

## Compilar para Producción

### macOS
```bash
flutter build macos --release
```
Aplicación resultante: `build/macos/Build/Products/Release/presupuesto20.app`

### Windows
```bash
flutter build windows --release
```
Ejecutable resultante: `build/windows/runner/Release/presupuesto20.exe`

---

¿Necesitas ayuda? Revisa el README.md principal para más detalles.
