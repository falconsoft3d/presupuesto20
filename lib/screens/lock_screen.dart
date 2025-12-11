import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.unlock(_passwordController.text);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = 'Contraseña incorrecta';
          _passwordController.clear();
        });
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final themeColor = settingsProvider.themeColor;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          image: settingsProvider.lockBackgroundPath != null && 
                 File(settingsProvider.lockBackgroundPath!).existsSync()
              ? DecorationImage(
                  image: FileImage(File(settingsProvider.lockBackgroundPath!)),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Error loading lock background: $exception');
                    settingsProvider.setLockBackground(null);
                  },
                )
              : null,
        ),
        child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar y nombre del usuario
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF875A7B),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      authProvider.currentUser?.nombre
                          .substring(0, 1)
                          .toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Presupuesto 2.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF875A7B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.currentUser?.nombre ?? 'Usuario',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authProvider.currentUser?.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Mensaje de bloqueo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pantalla bloqueada',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campo de contraseña
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  errorText: _errorMessage,
                ),
                obscureText: _obscurePassword,
                onSubmitted: (_) => _handleUnlock(),
                autofocus: true,
              ),
              const SizedBox(height: 24),

              // Botón de desbloqueo
              ElevatedButton(
                onPressed: _isLoading ? null : _handleUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Desbloquear',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Botón de cerrar sesión
              TextButton(
                onPressed: _handleLogout,
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
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
