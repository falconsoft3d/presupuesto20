# 🏗️ Presupuesto de Obras - Guía Rápida

## 📁 Estructura del Proyecto

```
presupuesto20/
│
├── 📱 lib/
│   ├── main.dart                    # Punto de entrada principal
│   │
│   ├── 🗄️ database/
│   │   ├── database.dart            # Configuración de Drift DB
│   │   └── tables.dart              # Esquema de tablas
│   │
│   ├── 🔧 providers/
│   │   └── obras_provider.dart      # Lógica de negocio para obras
│   │
│   ├── 📺 screens/
│   │   └── home_screen.dart         # Pantalla principal
│   │
│   └── 🧩 widgets/
│       ├── ribbon_bar.dart          # Barra estilo Office
│       ├── obras_list.dart          # Tabla de obras
│       └── obra_form_dialog.dart    # Formulario modal
│
├── 🖥️ windows/                       # Configuración Windows
├── 🍎 macos/                         # Configuración macOS
│
├── 📋 pubspec.yaml                   # Dependencias
├── 📖 README.md                      # Documentación principal
├── 📝 INSTALL.md                     # Instrucciones de instalación
├── ⚙️ setup.sh                       # Script de setup (macOS/Linux)
└── ⚙️ setup.bat                      # Script de setup (Windows)
```

## 🎨 Características de la Interfaz

### Ribbon Bar (Estilo Office)
```
┌─────────────────────────────────────────────────────────────┐
│ 🏗️ Presupuesto de Obras                                     │
├─────────────────────────────────────────────────────────────┤
│ [Inicio] [Obras] [Vista] [Herramientas]                     │
├─────────────────────────────────────────────────────────────┤
│  Nuevo     │  Acciones   │  Exportar  │  Vista              │
│ ┌─────┐    │  ✏️ Editar   │  🖨️ Print  │  📋 Lista          │
│ │ 🏢  │    │  🗑️ Eliminar │  📄 PDF    │  🎴 Tarjetas       │
│ │Nueva│    │  📋 Duplicar │  📊 Excel  │                    │
│ └─────┘    │  📦 Archivar │  📧 Email  │                    │
└─────────────────────────────────────────────────────────────┘
```

### Layout Principal
```
┌──────────┬─────────────────────────────────────────────┐
│          │                                             │
│ 🏢 Obras │         📊 Listado de Obras                │
│          │  ┌─────────────────────────────────────┐   │
│ 📋 Pres. │  │ Código │ Nombre │ Cliente │ Estado │   │
│          │  ├─────────────────────────────────────┤   │
│ 🧾 Fact. │  │ OB-001 │ Edif X │ Juan P. │ Activa │   │
│          │  │ OB-002 │ Casa Y │ Maria G.│ Proceso│   │
│ 📈 Report│  └─────────────────────────────────────┘   │
│          │                                             │
└──────────┴─────────────────────────────────────────────┘
```

## 🚀 Inicio Rápido

### Opción 1: Script Automático (Recomendado)

**macOS/Linux:**
```bash
./setup.sh
```

**Windows:**
```cmd
setup.bat
```

### Opción 2: Manual

```bash
# 1. Actualizar Flutter (si es necesario)
flutter upgrade

# 2. Habilitar escritorio
flutter config --enable-macos-desktop  # o --enable-windows-desktop

# 3. Instalar dependencias
flutter pub get

# 4. Generar código
dart run build_runner build --delete-conflicting-outputs

# 5. Ejecutar
flutter run -d macos  # o -d windows
```

## 📊 Base de Datos

La aplicación usa **Drift** (ORM para SQLite) con las siguientes tablas:

### Tabla: obras
| Campo              | Tipo      | Descripción              |
|--------------------|-----------|--------------------------|
| 🔑 id              | INT (PK)  | ID autoincremental       |
| 🏷️ codigo          | TEXT      | Código único (ej: OB-001)|
| 📝 nombre          | TEXT      | Nombre de la obra        |
| 👤 cliente         | TEXT      | Cliente                  |
| 📍 ubicacion       | TEXT?     | Ubicación (opcional)     |
| 💰 presupuestoTotal| REAL      | Presupuesto en USD       |
| 🚦 estado          | TEXT      | Estado de la obra        |
| 📅 fechaInicio     | DATETIME? | Fecha inicio (opcional)  |
| 📅 fechaFin        | DATETIME? | Fecha fin (opcional)     |
| 📄 notas           | TEXT?     | Notas (opcional)         |
| ⏰ fechaCreacion   | DATETIME  | Timestamp creación       |
| ⏰ fechaModificacion| DATETIME | Timestamp modificación   |

### Estados Disponibles
- 🟢 **Activa** - Obra en estado activo
- 🟠 **En Proceso** - Obra en ejecución
- 🔵 **Finalizada** - Obra completada
- 🔴 **Cancelada** - Obra cancelada

## 🎯 Funcionalidades Implementadas

### ✅ Módulo de Obras
- [x] Crear nueva obra
- [x] Editar obra existente
- [x] Eliminar obra con confirmación
- [x] Visualizar listado de obras
- [x] Validación de formularios
- [x] Formato de moneda
- [x] Selector de fechas
- [x] Estados con chips de colores

### 🔜 Próximamente
- [ ] Módulo de Presupuestos
- [ ] Módulo de Facturas
- [ ] Módulo de Reportes
- [ ] Exportación PDF/Excel
- [ ] Búsqueda y filtros
- [ ] Gráficos y estadísticas

## 🛠️ Tecnologías

| Tecnología      | Versión | Propósito                |
|-----------------|---------|--------------------------|
| Flutter         | 3.24+   | Framework UI             |
| Dart            | 3.0+    | Lenguaje                 |
| Drift           | 2.14+   | ORM para SQLite          |
| Provider        | 6.1+    | Gestión de estado        |
| window_manager  | 0.3+    | Gestión de ventanas      |
| intl            | 0.18+   | Internacionalización     |

## 📝 Convenciones de Código

- **Nombres de archivos**: snake_case (ej: `obras_provider.dart`)
- **Nombres de clases**: PascalCase (ej: `ObrasProvider`)
- **Nombres de variables**: camelCase (ej: `presupuestoTotal`)
- **Widgets**: Stateless por defecto, Stateful cuando se necesita estado local
- **Provider**: Para estado global de la aplicación

## 🎨 Paleta de Colores (Office Style)

```dart
Primary Blue:     #0078D4  // Botones principales
Background:       #F3F3F3  // Fondo general
Sidebar:          #FAFAFA  // Fondo sidebar
White:            #FFFFFF  // Cards y diálogos
Border:           #D1D1D1  // Bordes
Success:          #107C10  // Verde para éxito
Error:            #E81123  // Rojo para errores
Warning:          #FF8C00  // Naranja para advertencias
```

## 📱 Soporte de Plataformas

| Plataforma | Estado | Notas                          |
|------------|--------|--------------------------------|
| 🍎 macOS   | ✅     | Totalmente soportado           |
| 🪟 Windows | ✅     | Totalmente soportado           |
| 🐧 Linux   | ⚠️     | No probado (debería funcionar) |
| 📱 iOS     | ❌     | No soportado (app de escritorio)|
| 🤖 Android | ❌     | No soportado (app de escritorio)|
| 🌐 Web     | ❌     | No soportado (usa SQLite nativo)|

## 🐛 Solución de Problemas

### Error: SDK version solving failed
```bash
flutter upgrade
```

### Error: No device found
```bash
flutter config --enable-macos-desktop
flutter devices
```

### Error: Build runner fails
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Base de datos corrupta
Elimina el archivo de BD y reinicia:
- macOS: `~/Documents/presupuesto_obras.db`
- Windows: `C:\Users\[Tu Usuario]\Documents\presupuesto_obras.db`

## 📧 Soporte

Para problemas o sugerencias, revisa:
1. README.md - Documentación completa
2. INSTALL.md - Instrucciones detalladas
3. Este archivo - Guía rápida

---

**¡Listo para construir! 🏗️✨**
