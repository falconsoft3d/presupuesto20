# Sistema de Perfiles de Usuario

## Cambios Implementados

### 1. Base de Datos (Schema v7)
- **Archivo**: `lib/database/tables.dart`
- **Cambio**: Agregada columna `perfil` en tabla `Usuarios`
  - Tipo: `TextColumn`
  - Valores: `'administrador'` o `'usuario'`
  - Valor por defecto: `'administrador'`

- **Archivo**: `lib/database/database.dart`
  - Schema version incrementado de 6 a 7
  - Migración agregada para columna `perfil`

### 2. Provider de Usuarios
- **Archivo**: `lib/providers/usuarios_provider.dart`
- **Cambios**:
  - `createUsuario()`: Agregado parámetro `perfil` con valor por defecto `'administrador'`
  - `updateUsuario()`: Agregado parámetro opcional `perfil`

### 3. Provider de Autenticación
- **Archivo**: `lib/providers/auth_provider.dart`
- **Cambios**:
  - Agregado getter `isAdministrador` que retorna `true` si el perfil es `'administrador'`
  - Método `register()`: Crea nuevos usuarios con perfil `'administrador'` por defecto

### 4. Pantalla de Usuarios
- **Archivo**: `lib/screens/usuarios_screen.dart`
- **Cambios**:
  - Agregado dropdown en formulario para seleccionar perfil (Usuario/Administrador)
  - Agregada columna "Perfil" en tabla de listado
  - Badge visual con colores:
    - **Morado**: Administrador
    - **Azul**: Usuario
  - Ajustadas columnas de la tabla para incluir perfil

### 5. Pantalla Principal (Restricciones de Acceso)
- **Archivo**: `lib/screens/home_screen.dart`
- **Cambios**:
  - **Botón de Configuración**: Solo visible para administradores
  - **App Usuarios**: Solo visible para administradores
  - **App Compañías**: Solo visible para administradores
  - Apps visibles para todos: Contactos, Productos

## Comportamiento del Sistema

### Usuarios Administradores
- Ven todas las apps (Contactos, Productos, Usuarios, Compañías)
- Tienen acceso al botón de configuración (⚙️)
- Pueden crear y editar usuarios
- Pueden cambiar perfiles de otros usuarios

### Usuarios Regulares
- Solo ven apps básicas (Contactos, Productos)
- No ven el botón de configuración
- No pueden acceder a gestión de usuarios
- No pueden acceder a gestión de compañías

## Notas Importantes

1. **Todos los usuarios nuevos** creados desde la aplicación son administradores por defecto
2. **Los usuarios existentes** mantienen el perfil 'administrador' tras la migración
3. **El perfil puede ser cambiado** editando el usuario desde la pantalla de Usuarios
4. **Seguridad**: Las restricciones de UI están en el frontend; considerar agregar validación en el backend si se implementa una API

## Testing

Para probar el sistema:
1. Crear un usuario con perfil "Usuario"
2. Cerrar sesión
3. Iniciar sesión con el nuevo usuario
4. Verificar que:
   - No aparece el botón de configuración
   - Solo aparecen apps de Contactos y Productos
   - No aparecen apps de Usuarios y Compañías
