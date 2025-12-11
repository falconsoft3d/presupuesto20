@echo off
REM Script de inicialización para Windows

echo ========================================
echo    Presupuesto de Obras - Inicializacion
echo ========================================
echo.

echo Verificando Flutter...
flutter --version
echo.

echo Habilitando soporte de escritorio para Windows...
flutter config --enable-windows-desktop
echo.

echo Limpiando proyecto...
flutter clean
echo.

echo Instalando dependencias...
flutter pub get
echo.

if %ERRORLEVEL% EQU 0 (
    echo Dependencias instaladas correctamente
    echo.
    
    echo Generando codigo de Drift...
    dart run build_runner build --delete-conflicting-outputs
    echo.
    
    if %ERRORLEVEL% EQU 0 (
        echo Codigo generado correctamente
        echo.
        echo Configuracion completada!
        echo.
        echo Para ejecutar la aplicacion:
        echo   flutter run -d windows
        echo.
        echo Para compilar para produccion:
        echo   flutter build windows --release
        echo.
    ) else (
        echo Error al generar codigo
        echo Intenta ejecutar manualmente:
        echo   dart run build_runner build --delete-conflicting-outputs
    )
) else (
    echo Error al instalar dependencias
    echo.
    echo Si ves errores de version de SDK, actualiza Flutter:
    echo   flutter upgrade
    echo.
    echo Luego ejecuta este script nuevamente.
)

pause
