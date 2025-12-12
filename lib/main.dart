import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/database.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/pin_login_screen.dart';
import 'providers/obras_provider.dart';
import 'providers/proyectos_provider.dart';
import 'providers/contactos_provider.dart';
import 'providers/productos_provider.dart';
import 'providers/usuarios_provider.dart';
import 'providers/companias_provider.dart';
import 'providers/unidades_medida_provider.dart';
import 'providers/monedas_provider.dart';
import 'providers/categorias_productos_provider.dart';
import 'providers/estados_provider.dart';
import 'providers/empleados_provider.dart';
import 'providers/presupuestos_provider.dart';
import 'providers/conceptos_provider.dart';
import 'providers/integradores_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar locales de fecha para español
  await initializeDateFormatting('es', null);
  
  // Configurar ventana para escritorio
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Presupuesto de Obras',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider(create: (_) => AppDatabase()),
        ChangeNotifierProxyProvider<AppDatabase, AuthProvider>(
          create: (context) => AuthProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? AuthProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, ObrasProvider>(
          create: (context) => ObrasProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? ObrasProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, ProyectosProvider>(
          create: (context) => ProyectosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? ProyectosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, PresupuestosProvider>(
          create: (context) => PresupuestosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? PresupuestosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, ConceptosProvider>(
          create: (context) => ConceptosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? ConceptosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, IntegradoresProvider>(
          create: (context) => IntegradoresProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? IntegradoresProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, ContactosProvider>(
          create: (context) => ContactosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? ContactosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, ProductosProvider>(
          create: (context) => ProductosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? ProductosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, EmpleadosProvider>(
          create: (context) => EmpleadosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? EmpleadosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, UsuariosProvider>(
          create: (context) => UsuariosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? UsuariosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, CompaniasProvider>(
          create: (context) => CompaniasProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? CompaniasProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, UnidadesMedidaProvider>(
          create: (context) => UnidadesMedidaProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? UnidadesMedidaProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, MonedasProvider>(
          create: (context) => MonedasProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => MonedasProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, CategoriasProductosProvider>(
          create: (context) => CategoriasProductosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? CategoriasProductosProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, EstadosProvider>(
          create: (context) => EstadosProvider(context.read<AppDatabase>()),
          update: (context, db, previous) => previous ?? EstadosProvider(db),
        ),
        ChangeNotifierProxyProvider2<AppDatabase, SettingsProvider, ChatProvider>(
          create: (context) {
            final db = context.read<AppDatabase>();
            final settings = context.read<SettingsProvider>();
            return ChatProvider(
              database: db,
              openAIService: OpenAIService(apiKey: settings.chatGptToken),
            );
          },
          update: (context, db, settings, previous) {
            if (previous == null) {
              return ChatProvider(
                database: db,
                openAIService: OpenAIService(apiKey: settings.chatGptToken),
              );
            }
            // Si el token cambió, actualizar el servicio
            return ChatProvider(
              database: db,
              openAIService: OpenAIService(apiKey: settings.chatGptToken),
            );
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Presupuesto de Obras',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: settings.themeColor,
                brightness: Brightness.light,
              ),
              primaryColor: settings.themeColor,
              scaffoldBackgroundColor: const Color(0xFFF3F3F3),
              cardTheme: const CardThemeData(
                elevation: 0,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: settings.themeColor,
                foregroundColor: Colors.white,
              ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    } else if (authProvider.isLocked) {
      // Si hay PIN habilitado, usar PinLoginScreen, sino LockScreen
      if (settingsProvider.usarPin) {
        return PinLoginScreen();
      } else {
        return const LockScreen();
      }
    } else {
      return const HomeScreen();
    }
  }
}
