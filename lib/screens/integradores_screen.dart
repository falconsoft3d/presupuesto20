import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/integradores_provider.dart';
import '../providers/settings_provider.dart';
import '../database/database.dart';
import '../widgets/integradores_list.dart';
import '../widgets/integrador_form_view.dart';

class IntegradoresScreen extends StatefulWidget {
  const IntegradoresScreen({super.key});

  @override
  State<IntegradoresScreen> createState() => _IntegradoresScreenState();
}

class _IntegradoresScreenState extends State<IntegradoresScreen> {
  Integrador? _selectedIntegrador;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IntegradoresProvider>(context, listen: false).loadIntegradores();
    });
  }

  void _showIntegradorForm([Integrador? integrador]) {
    setState(() {
      _selectedIntegrador = integrador;
      _showForm = true;
    });
  }

  void _hideForm() {
    setState(() {
      _selectedIntegrador = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<SettingsProvider>().themeColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: _showForm
          ? IntegradorFormView(
              integrador: _selectedIntegrador,
              onBack: _hideForm,
            )
          : IntegradoresList(
              onIntegradorSelected: _showIntegradorForm,
              onCreateNew: () => _showIntegradorForm(),
            ),
    );
  }
}
