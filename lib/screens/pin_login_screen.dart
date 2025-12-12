import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _enteredPin = '';
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    if (settings.verificarPin(_enteredPin)) {
      // PIN correcto
      
      // Si ya hay un usuario autenticado pero bloqueado, solo desbloquear
      if (auth.isAuthenticated && auth.isLocked) {
        auth.unlock(''); // El PIN ya fue verificado, no necesita contraseña
        setState(() {
          _isError = false;
        });
        return;
      }
      
      // Si no hay usuario autenticado, iniciar sesión con el email del último usuario
      final email = settings.ultimoEmailUsuario;
      
      if (email.isEmpty) {
        // No hay email guardado, error
        setState(() {
          _isError = true;
          _enteredPin = '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay usuario asociado al PIN. Usa contraseña para iniciar sesión.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      final success = await auth.loginWithEmail(email);
      
      if (success && mounted) {
        setState(() {
          _isError = false;
        });
        // El login redirigirá automáticamente al home
      } else if (mounted) {
        setState(() {
          _isError = true;
          _enteredPin = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // PIN incorrecto
      setState(() {
        _isError = true;
        _enteredPin = '';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeColor = settings.themeColor;
    final lockBackground = settings.lockBackgroundPath;

    return Scaffold(
      body: Container(
        decoration: lockBackground != null && File(lockBackground).existsSync()
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(lockBackground)),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeColor.withOpacity(0.8),
                    themeColor.withOpacity(0.6),
                  ],
                ),
              ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Título
                Icon(
                  Icons.lock_person,
                  size: 64,
                  color: themeColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingresa tu PIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Introduce tu PIN de 4 dígitos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isError
                            ? Colors.red
                            : isFilled
                                ? themeColor
                                : Colors.grey.shade300,
                        border: Border.all(
                          color: _isError
                              ? Colors.red
                              : isFilled
                                  ? themeColor
                                  : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                if (_isError) ...[
                  const SizedBox(height: 16),
                  Text(
                    'PIN incorrecto',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Teclado numérico
                _buildNumberPad(themeColor),

                const SizedBox(height: 24),

                // Link para usar contraseña
                TextButton(
                  onPressed: () {
                    // Desactivar temporalmente el PIN para esta sesión
                    // o mostrar el login normal
                    settings.setUsarPin(false);
                  },
                  child: Text(
                    'Usar contraseña en su lugar',
                    style: TextStyle(
                      color: themeColor,
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

  Widget _buildNumberPad(Color themeColor) {
    return Column(
      children: [
        // Fila 1-2-3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1', themeColor),
            _buildNumberButton('2', themeColor),
            _buildNumberButton('3', themeColor),
          ],
        ),
        const SizedBox(height: 12),
        // Fila 4-5-6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4', themeColor),
            _buildNumberButton('5', themeColor),
            _buildNumberButton('6', themeColor),
          ],
        ),
        const SizedBox(height: 12),
        // Fila 7-8-9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7', themeColor),
            _buildNumberButton('8', themeColor),
            _buildNumberButton('9', themeColor),
          ],
        ),
        const SizedBox(height: 12),
        // Fila vacío-0-borrar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 70, height: 60), // Espacio vacío
            _buildNumberButton('0', themeColor),
            _buildDeleteButton(themeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number, Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNumberPressed(number),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onDeletePressed,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 24,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
