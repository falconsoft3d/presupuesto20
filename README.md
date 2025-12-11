# Presupuesto de Obras - Aplicación de Escritorio

Aplicación de escritorio multiplataforma (Windows y macOS) para la gestión de presupuestos de obras, desarrollada con Flutter y Drift (base de datos SQLite).

## Características

- ✨ **Interfaz estilo Microsoft Office** con Ribbon Bar y navegación lateral
- 📊 **Gestión completa de obras** (CRUD completo)
- 💾 **Base de datos local** con Drift/SQLite
- 🖥️ **Multiplataforma**: Windows y macOS
- 🎨 **Diseño moderno** inspirado en aplicaciones de productividad

## Funcionalidades Implementadas

### Módulo de Obras
- Crear nuevas obras con todos los detalles
- Editar obras existentes
- Eliminar obras con confirmación
- Visualización en tabla con todas las columnas
- Estados: Activa, En Proceso, Finalizada, Cancelada
- Campos: Código, Nombre, Cliente, Ubicación, Presupuesto, Fechas, Notas

## Tecnologías Utilizadas

- **Flutter** (SDK 3.0+) - Framework UI
- **Drift** - ORM para SQLite
- **Provider** - Gestión de estado
- **window_manager** - Gestión de ventanas de escritorio
- **intl** - Formateo de fechas y números

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── database/
│   ├── database.dart         # Configuración de Drift
│   └── tables.dart           # Definición de tablas
├── providers/
│   └── obras_provider.dart   # Lógica de negocio
├── screens/
│   └── home_screen.dart      # Pantalla principal
└── widgets/
    ├── ribbon_bar.dart       # Barra de herramientas estilo Office
    ├── obras_list.dart       # Lista de obras
    └── obra_form_dialog.dart # Formulario de obras
```

## Instalación y Ejecución

### Requisitos Previos
- Flutter SDK (3.0 o superior)
- Para Windows: Visual Studio 2022 con carga de trabajo de desarrollo de escritorio
- Para macOS: Xcode 13 o superior

### Pasos de Instalación

1. **Clonar el repositorio** (si aplica)

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código de Drift**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Habilitar soporte de escritorio**
```bash
# Windows
flutter config --enable-windows-desktop

# macOS
flutter config --enable-macos-desktop
```

5. **Ejecutar la aplicación**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

## Compilar para Producción

### Windows
```bash
flutter build windows --release
```
El ejecutable estará en: `build/windows/runner/Release/`

### macOS
```bash
flutter build macos --release
```
La aplicación estará en: `build/macos/Build/Products/Release/`

## Base de Datos

La base de datos SQLite se crea automáticamente en:
- **Windows**: `C:\Users\[Usuario]\Documents\presupuesto_obras.db`
- **macOS**: `~/Documents/presupuesto_obras.db`

### Esquema de la Tabla Obras

| Campo              | Tipo     | Descripción                    |
|--------------------|----------|--------------------------------|
| id                 | INTEGER  | ID autoincremental (PK)        |
| codigo             | TEXT     | Código único de la obra        |
| nombre             | TEXT     | Nombre de la obra              |
| cliente            | TEXT     | Nombre del cliente             |
| ubicacion          | TEXT     | Ubicación de la obra           |
| presupuestoTotal   | REAL     | Presupuesto total en USD       |
| estado             | TEXT     | Estado actual de la obra       |
| fechaInicio        | DATETIME | Fecha de inicio                |
| fechaFin           | DATETIME | Fecha de finalización          |
| notas              | TEXT     | Notas adicionales              |
| fechaCreacion      | DATETIME | Fecha de creación del registro |
| fechaModificacion  | DATETIME | Última modificación            |

## Próximas Funcionalidades

- [ ] Módulo de Presupuestos
- [ ] Módulo de Facturas
- [ ] Módulo de Reportes y Análisis
- [ ] Exportación a PDF y Excel
- [ ] Gestión de partidas y materiales
- [ ] Sistema de búsqueda y filtros avanzados
- [ ] Gráficos y dashboard
- [ ] Respaldo y restauración de base de datos

## Capturas de Pantalla

*(Aquí puedes agregar capturas de pantalla de la aplicación)*

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios que te gustaría realizar.

## Licencia

Este proyecto está bajo la Licencia MIT.

## Soporte

Para reportar bugs o solicitar nuevas características, por favor abre un issue en el repositorio.

---

Desarrollado con ❤️ usando Flutter
