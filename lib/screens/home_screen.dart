import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obras_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/companias_provider.dart';
import '../widgets/ribbon_bar.dart';
import '../widgets/obras_list.dart';
import '../widgets/obra_form_dialog.dart';
import '../widgets/contactos_list.dart';
import '../widgets/contacto_form_view.dart';
import '../widgets/change_password_dialog.dart';
import '../database/database.dart';
import 'settings_screen.dart';
import 'proyectos_screen.dart';
import 'presupuestos_screen.dart';
import 'productos_screen.dart';
import 'empleados_screen.dart';
import 'usuarios_screen.dart';
import 'companias_screen.dart';
import 'datos_maestros_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedView = 'home';
  String? _selectedApp;
  Contacto? _selectedContacto;
  bool _isCreatingContacto = false;

  void _showNewObraDialog() {
    showDialog(
      context: context,
      builder: (context) => const ObraFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      body: Column(
        children: [
          // Header estilo Odoo
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: settings.themeColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo/Menu
                IconButton(
                  icon: const Icon(Icons.apps, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedView = 'home';
                      _selectedApp = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Presupuesto 2.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Configuración (solo administradores)
                if (authProvider.isAdministrador)
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedView = 'settings';
                        _selectedApp = null;
                      });
                    },
                    tooltip: 'Configuración',
                  ),
                if (authProvider.isAdministrador)
                  const SizedBox(width: 16),
                // Selector de Compañía
                Consumer<CompaniasProvider>(
                  builder: (context, companiasProvider, child) {
                    final companias = companiasProvider.getCompaniasActivas();
                    final companiaActualId = settings.companiaActualId;
                    final companiaActual = companiaActualId != null
                        ? companiasProvider.getCompaniaById(companiaActualId)
                        : null;
                    
                    return PopupMenuButton<int?>(
                      offset: const Offset(0, 50),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business, color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              companiaActual?.nombre ?? 'Sin compañía',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.clear, size: 18),
                              SizedBox(width: 12),
                              Text('Sin compañía'),
                            ],
                          ),
                        ),
                        if (companias.isNotEmpty) const PopupMenuDivider(),
                        ...companias.map((compania) => PopupMenuItem(
                          value: compania.id,
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 18,
                                color: compania.id == companiaActualId
                                    ? settings.themeColor
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                compania.nombre,
                                style: TextStyle(
                                  fontWeight: compania.id == companiaActualId
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: compania.id == companiaActualId
                                      ? settings.themeColor
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                      onSelected: (companiaId) {
                        settings.setCompaniaActual(companiaId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              companiaId == null
                                  ? 'Sin compañía seleccionada'
                                  : 'Compañía cambiada a: ${companiasProvider.getCompaniaById(companiaId)?.nombre}',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Usuario
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          authProvider.currentUser?.nombre ?? 'Usuario',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'changePassword',
                      child: Row(
                        children: [
                          Icon(Icons.key, size: 18),
                          SizedBox(width: 12),
                          Text('Cambiar contraseña'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 18),
                          SizedBox(width: 12),
                          Text('Bloquear pantalla'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 12),
                          Text('Cerrar sesión'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'changePassword') {
                      showDialog(
                        context: context,
                        builder: (context) => const ChangePasswordDialog(),
                      );
                    } else if (value == 'lock') {
                      authProvider.lock();
                    } else if (value == 'logout') {
                      authProvider.logout();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            child: _selectedView == 'home' 
                ? _buildAppGrid() 
                : _selectedView == 'settings'
                    ? SettingsScreen(
                        onBack: () {
                          setState(() {
                            _selectedView = 'home';
                          });
                        },
                      )
                    : _buildAppContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            image: settings.homeBackgroundPath != null && 
                   File(settings.homeBackgroundPath!).existsSync()
                ? DecorationImage(
                    image: FileImage(File(settings.homeBackgroundPath!)),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      debugPrint('Error loading home background: $exception');
                      settings.setHomeBackground(null);
                    },
                  )
                : null,
          ),
          padding: const EdgeInsets.all(40),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
            _buildAppCard(
              title: 'Proyectos',
              icon: Icons.account_tree,
              color: const Color(0xFF2ECC71),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'proyectos';
                });
              },
            ),
            _buildAppCard(
              title: 'Presupuestos',
              icon: Icons.description,
              color: const Color(0xFF8E44AD),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'presupuestos';
                });
              },
            ),
            _buildAppCard(
              title: 'Contactos',
              icon: Icons.contacts,
              color: const Color(0xFF00A09D),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'contactos';
                });
              },
            ),
            _buildAppCard(
              title: 'Productos',
              icon: Icons.inventory_2,
              color: const Color(0xFFE67E22),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'productos';
                });
              },
            ),
            _buildAppCard(
              title: 'Empleados',
              icon: Icons.badge,
              color: const Color(0xFF34495E),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'empleados';
                });
              },
            ),
            _buildAppCard(
              title: 'Datos',
              icon: Icons.data_object,
              color: const Color(0xFF16A085),
              onTap: () {
                setState(() {
                  _selectedView = 'app';
                  _selectedApp = 'datos_maestros';
                });
              },
              badge: 'ADMIN',
            ),
            // Solo administradores ven Usuarios y Compañías
            if (context.read<AuthProvider>().isAdministrador)
              _buildAppCard(
                title: 'Usuarios',
                icon: Icons.people,
                color: const Color(0xFF9B59B6),
                onTap: () {
                  setState(() {
                    _selectedView = 'app';
                    _selectedApp = 'usuarios';
                  });
                },
                badge: 'ADMIN',
              ),
            if (context.read<AuthProvider>().isAdministrador)
              _buildAppCard(
                title: 'Compañías',
                icon: Icons.business,
                color: const Color(0xFF3498DB),
                onTap: () {
                  setState(() {
                    _selectedView = 'app';
                    _selectedApp = 'companias';
                  });
                },
                badge: 'ADMIN',
              ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildAppCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return _AnimatedAppCard(
      title: title,
      icon: icon,
      color: color,
      onTap: onTap,
      badge: badge,
    );
  }

  Widget _buildAppContent() {
    return Column(
      children: [
        // Content
        Expanded(
          child: Container(
            color: const Color(0xFFF0F0F0),
            child: _selectedApp == 'proyectos'
                ? ProyectosScreen(
                    onBack: () {
                      setState(() {
                        _selectedView = 'home';
                        _selectedApp = null;
                      });
                    },
                  )
                : _selectedApp == 'presupuestos'
                    ? const PresupuestosScreen()
                    : _selectedApp == 'contactos'
                ? (_isCreatingContacto || _selectedContacto != null
                    ? ContactoFormView(
                        contacto: _selectedContacto,
                        onBack: () {
                          setState(() {
                            _selectedContacto = null;
                            _isCreatingContacto = false;
                          });
                        },
                      )
                    : ContactosList(
                        onContactoSelected: (contacto) {
                          setState(() {
                            _selectedContacto = contacto;
                          });
                        },
                        onCreateNew: () {
                          setState(() {
                            _isCreatingContacto = true;
                            _selectedContacto = null;
                          });
                        },
                      ))
                : _selectedApp == 'productos'
                    ? const ProductosScreen()
                    : _selectedApp == 'empleados'
                        ? const EmpleadosScreen()
                        : _selectedApp == 'datos_maestros'
                            ? DatosMaestrosScreen(
                            onBack: () {
                              setState(() {
                                _selectedView = 'home';
                                _selectedApp = null;
                              });
                            },
                          )
                        : _selectedApp == 'usuarios'
                            ? UsuariosScreen(
                                onBack: () {
                                  setState(() {
                                    _selectedView = 'home';
                                    _selectedApp = null;
                                  });
                                },
                              )
                            : _selectedApp == 'companias'
                                ? CompaniasScreen(
                                    onBack: () {
                                      setState(() {
                                        _selectedView = 'home';
                                        _selectedApp = null;
                                      });
                                    },
                                  )
                                : const ObrasList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAppCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _AnimatedAppCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  State<_AnimatedAppCard> createState() => _AnimatedAppCardState();
}

class _AnimatedAppCardState extends State<_AnimatedAppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 155,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.08),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 8 : 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.badge != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
