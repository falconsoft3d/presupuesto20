import 'package:flutter/material.dart';
import '../database/database.dart';
import '../widgets/conceptos_list.dart';
import '../widgets/concepto_form_view.dart';

class ConceptosScreen extends StatefulWidget {
  const ConceptosScreen({super.key});

  @override
  State<ConceptosScreen> createState() => _ConceptosScreenState();
}

class _ConceptosScreenState extends State<ConceptosScreen> {
  Concepto? _selectedConcepto;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: _showForm
          ? ConceptoFormView(
              concepto: _selectedConcepto,
              onBack: () {
                setState(() {
                  _showForm = false;
                  _selectedConcepto = null;
                });
              },
            )
          : ConceptosList(
              onConceptoSelected: (concepto) {
                setState(() {
                  _selectedConcepto = concepto;
                  _showForm = true;
                });
              },
              onCreateNew: () {
                setState(() {
                  _selectedConcepto = null;
                  _showForm = true;
                });
              },
            ),
    );
  }
}
