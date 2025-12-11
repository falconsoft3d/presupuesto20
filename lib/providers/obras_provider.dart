import 'package:flutter/material.dart';
import '../database/database.dart';

class ObrasProvider extends ChangeNotifier {
  final AppDatabase _database;
  List<Obra> _obras = [];
  bool _isLoading = false;

  ObrasProvider(this._database) {
    loadObras();
  }

  List<Obra> get obras => _obras;
  bool get isLoading => _isLoading;

  Future<void> loadObras() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _obras = await _database.getAllObras();
    } catch (e) {
      debugPrint('Error loading obras: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addObra(ObrasCompanion obra) async {
    try {
      await _database.insertObra(obra);
      await loadObras();
      return true;
    } catch (e) {
      debugPrint('Error adding obra: $e');
      return false;
    }
  }

  Future<bool> updateObra(Obra obra) async {
    try {
      await _database.updateObra(obra);
      await loadObras();
      return true;
    } catch (e) {
      debugPrint('Error updating obra: $e');
      return false;
    }
  }

  Future<bool> deleteObra(int id) async {
    try {
      await _database.deleteObra(id);
      await loadObras();
      return true;
    } catch (e) {
      debugPrint('Error deleting obra: $e');
      return false;
    }
  }
}
