import 'dart:io';
import 'package:excel/excel.dart';
import 'package:drift/drift.dart' as drift;
import 'package:archive/archive.dart';
import 'dart:convert';
import '../database/database.dart';

class IntegradorService {
  final AppDatabase _database;

  IntegradorService(this._database);

  /// Procesa un archivo Excel en formato 2000
  /// Crea un presupuesto y sus conceptos asociados
  Future<Map<String, dynamic>> procesarFormato2000({
    required String rutaArchivo,
    required String nombrePresupuesto,
    int? proyectoId,
  }) async {
    try {
      // Leer archivo Excel con parser manual robusto
      final bytes = File(rutaArchivo).readAsBytesSync();
      
      List<List<dynamic>> rows;
      
      try {
        // Intentar primero con la librería Excel
        final excel = Excel.decodeBytes(bytes);
        
        if (excel.tables.isEmpty) {
          return {
            'success': false,
            'message': 'El archivo no contiene hojas de cálculo',
          };
        }
        
        final sheet = excel.tables.keys.first;
        rows = excel.tables[sheet]!.rows.map((row) {
          return row.map((cell) => cell?.value).toList();
        }).toList();
        
      } catch (excelError) {
        print('Error con librería Excel: $excelError');
        print('Intentando con parser manual...');
        
        // Si falla, usar parser manual que lee directamente el XML del xlsx
        try {
          rows = await _parseXlsxManual(bytes);
        } catch (manualError) {
          return {
            'success': false,
            'message': 'Error al procesar el archivo Excel:\n$excelError\n\n'
                'Error con parser alternativo: $manualError\n\n'
                '💡 Por favor, verifica que el archivo sea un Excel válido (.xlsx)',
          };
        }
      }
      
      if (rows.isEmpty) {
        return {
          'success': false,
          'message': 'El archivo está vacío',
        };
      }
      
      // Crear presupuesto
      final presupuestoId = await _crearPresupuesto(
        nombre: nombrePresupuesto,
        proyectoId: proyectoId,
      );
      
      // Procesar filas
      final resultado = await _procesarFilas(
        rows: rows,
        presupuestoId: presupuestoId,
      );
      
      // Calcular totales recursivamente de abajo hacia arriba
      print('🔢 Calculando totales recursivos...');
      await _calcularTotalesRecursivos(presupuestoId);
      print('✅ Totales calculados');
      
      return {
        'success': true,
        'message': 'Importación completada exitosamente',
        'presupuestoId': presupuestoId,
        'capitulos': resultado['capitulos'],
        'partidas': resultado['partidas'],
        'recursos': resultado['recursos'],
      };
      
    } catch (e, stackTrace) {
      // Log detallado del error
      print('Error al procesar archivo: $e');
      print('Stack trace: $stackTrace');
      
      return {
        'success': false,
        'message': 'Error al procesar archivo: $e\n\n'
            '💡 Posibles soluciones:\n'
            '• Abre el archivo en Excel/LibreOffice\n'
            '• Guárdalo como "Excel Workbook (.xlsx)"\n'
            '• Asegúrate de no tener formatos de celda personalizados\n'
            '• Si el problema persiste, elimina formatos especiales de las celdas',
      };
    }
  }

  /// Parser manual de XLSX que ignora formatos
  Future<List<List<dynamic>>> _parseXlsxManual(List<int> bytes) async {
    try {
      // Descomprimir el archivo XLSX (es un ZIP)
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Buscar el archivo sharedStrings.xml
      String? sharedStringsXml;
      for (final file in archive.files) {
        if (file.name == 'xl/sharedStrings.xml' && file.isFile) {
          sharedStringsXml = utf8.decode(file.content as List<int>);
          break;
        }
      }
      
      // Parsear shared strings
      List<String> sharedStrings = [];
      if (sharedStringsXml != null) {
        final regex = RegExp(r'<t[^>]*>(.*?)</t>', multiLine: true, dotAll: true);
        sharedStrings = regex.allMatches(sharedStringsXml)
            .map((m) => _decodeXmlEntities(m.group(1) ?? ''))
            .toList();
        print('📚 Shared Strings encontrados: ${sharedStrings.length}');
        if (sharedStrings.length > 0) {
          print('   Primeros 20: ${sharedStrings.take(20).toList()}');
        }
      } else {
        print('⚠️  No se encontró sharedStrings.xml');
      }
      
      // Buscar el archivo sheet1.xml
      String? sheetXml;
      for (final file in archive.files) {
        if (file.name.contains('xl/worksheets/sheet') && file.isFile) {
          sheetXml = utf8.decode(file.content as List<int>);
          break;
        }
      }
      
      if (sheetXml == null) {
        throw Exception('No se encontró la hoja de cálculo en el archivo');
      }
      
      // Parsear filas y celdas
      final rows = <List<dynamic>>[];
      final rowRegex = RegExp(r'<row[^>]*>(.*?)</row>', multiLine: true, dotAll: true);
      // Regex mejorado para capturar el atributo t correctamente
      final cellRegex = RegExp(r'<c\s+r="([A-Z]+)(\d+)"(?:\s+s="[^"]*")?(?:\s+t="([^"]*)")?[^>]*>(?:<v>([^<]*)</v>)?|<c\s+r="([A-Z]+)(\d+)"[^>]*t="([^"]*)"[^>]*>(?:<v>([^<]*)</v>)?', multiLine: true);
      
      for (final rowMatch in rowRegex.allMatches(sheetXml)) {
        final rowContent = rowMatch.group(1) ?? '';
        final row = <dynamic>[];
        int lastCol = -1;
        
        for (final cellMatch in cellRegex.allMatches(rowContent)) {
          // El regex tiene dos alternativas, necesitamos obtener los grupos correctos
          String colStr = cellMatch.group(1) ?? cellMatch.group(5) ?? '';
          String? type = cellMatch.group(3) ?? cellMatch.group(7);
          String? value = cellMatch.group(4) ?? cellMatch.group(8);
          
          if (colStr.isEmpty) continue;
          
          // Convertir letra de columna a índice
          int colIndex = 0;
          for (int i = 0; i < colStr.length; i++) {
            colIndex = colIndex * 26 + (colStr.codeUnitAt(i) - 65 + 1);
          }
          colIndex--;
          
          // Rellenar columnas vacías
          while (lastCol < colIndex - 1) {
            row.add(null);
            lastCol++;
          }
          
          // Agregar valor de la celda
          if (value == null || value.isEmpty) {
            row.add(null);
          } else if (type == 's') {
            // String compartido - resolver el índice
            final index = int.tryParse(value);
            if (index != null && index < sharedStrings.length) {
              row.add(sharedStrings[index]);
              print('   Celda $colStr: índice $index -> "${sharedStrings[index]}"');
            } else {
              row.add(value);
              print('   Celda $colStr: índice $index fuera de rango o inválido');
            }
          } else {
            // Número o texto directo
            final numValue = double.tryParse(value);
            row.add(numValue ?? value);
          }
          
          lastCol = colIndex;
        }
        
        if (row.isNotEmpty) {
          rows.add(row);
        }
      }
      
      return rows;
    } catch (e) {
      throw Exception('Error parseando XLSX manualmente: $e');
    }
  }
  
  /// Decodifica entidades XML
  String _decodeXmlEntities(String text) {
    return text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  /// Crea un nuevo presupuesto
  Future<int> _crearPresupuesto({
    required String nombre,
    int? proyectoId,
  }) async {
    // Generar código automático usando timestamp
    final now = DateTime.now();
    final codigo = 'PRE-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour}${now.minute}${now.second}';
    
    return await _database.insertPresupuesto(
      PresupuestosCompanion.insert(
        codigo: codigo,
        nombre: nombre,
      ),
    );
  }

  /// Procesa todas las filas del Excel
  Future<Map<String, int>> _procesarFilas({
    required List<List<dynamic>> rows,
    required int presupuestoId,
  }) async {
    int capitulosCount = 0;
    int partidasCount = 0;
    int recursosCount = 0;
    
    // Mapa para mantener la jerarquía de capítulos
    // Clave: código del capítulo (ej: "01#", "01.01#")
    // Valor: ID del concepto en base de datos
    final Map<String, int> capitulos = {};
    int? partidaActualId;
    
    // Saltar la fila de encabezados (primera fila)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      
      // Columnas según la imagen:
      // A: PARTIDA (código)
      // B: NAT (tipo: MO, MAT, EQUIPO, %)
      // C: UNIDAD
      // D: DESCRIPCION DE PARTIDA
      // E: MEDICION
      // F: PRECIO
      // G: IMPORTE
      // H: RENDIMIENTO
      
      final codigo = _getCellValue(row, 0); // Columna A
      final nat = _getCellValue(row, 1);     // Columna B
      final unidad = _getCellValue(row, 2);  // Columna C
      final descripcion = _getCellValue(row, 3); // Columna D
      final medicion = _getCellValueDouble(row, 4); // Columna E
      final precio = _getCellValueDouble(row, 5);   // Columna F
      final importe = _getCellValueDouble(row, 6);  // Columna G
      
      // Debug: mostrar lo que se está leyendo
      print('Fila $i: codigo="$codigo" nat="$nat" desc="$descripcion" med=$medicion precio=$precio');
      
      // Saltar filas vacías
      if (codigo.isEmpty) continue;
      
      // CAPÍTULO o SUBCAPÍTULO: código contiene #
      if (codigo.contains('#')) {
        // Determinar el padre según la jerarquía del código
        int? padreId;
        
        // Si es subcapítulo (tiene punto antes del #), buscar el padre
        // Ejemplos: "01#" -> sin padre, "01.01#" -> padre "01#", "01.01.02#" -> padre "01.01#"
        if (codigo.contains('.')) {
          // Extraer el código del padre (quitar el último nivel)
          final partes = codigo.split('.');
          if (partes.length >= 2) {
            // Construir código del padre
            // "01.01#" -> padre = "01#"
            // "01.01.02#" -> padre = "01.01#"
            final codigoPadre = partes.sublist(0, partes.length - 1).join('.') + '#';
            padreId = capitulos[codigoPadre];
            print('  -> CAPÍTULO hijo: "$codigo" padre: "$codigoPadre" (ID: $padreId)');
          } else {
            print('  -> CAPÍTULO raíz: "$codigo"');
          }
        } else {
          print('  -> CAPÍTULO raíz: "$codigo"');
        }
        
        final capituloId = await _crearCapitulo(
          presupuestoId: presupuestoId,
          codigo: codigo,
          descripcion: descripcion,
          unidad: unidad,
          padreId: padreId,
        );
        
        // Guardar en el mapa para referencia futura
        capitulos[codigo] = capituloId;
        capitulosCount++;
        partidaActualId = null; // Reset partida cuando hay nuevo capítulo
      }
      // PARTIDA: código sin # y NAT vacío
      else if (nat.isEmpty) {
        // Buscar el capítulo padre más cercano según el código
        // Ejemplo: "01.01.0001" -> buscar "01.01#"
        int? capituloId;
        
        // Extraer el prefijo del código para encontrar el capítulo padre
        // "01.01.0001" -> buscar "01.01#"
        final partes = codigo.split('.');
        if (partes.length >= 2) {
          // Probar desde el más específico al más general
          for (int j = partes.length - 1; j >= 1; j--) {
            final codigoCapitulo = partes.sublist(0, j).join('.') + '#';
            if (capitulos.containsKey(codigoCapitulo)) {
              capituloId = capitulos[codigoCapitulo];
              print('  -> PARTIDA: "$codigo" bajo capítulo "$codigoCapitulo" (ID: $capituloId)');
              break;
            }
          }
        }
        
        // Si no se encontró con puntos, probar con el primer nivel
        // "01.01.0001" -> probar "01#"
        if (capituloId == null && partes.isNotEmpty) {
          final codigoCapitulo = '${partes[0]}#';
          capituloId = capitulos[codigoCapitulo];
          print('  -> PARTIDA: "$codigo" bajo capítulo raíz "$codigoCapitulo" (ID: $capituloId)');
        }
        
        partidaActualId = await _crearPartida(
          presupuestoId: presupuestoId,
          capituloId: capituloId,
          codigo: codigo,
          descripcion: descripcion,
          unidad: unidad,
          cantidad: medicion,
          precio: precio,
        );
        partidasCount++;
      }
      // RECURSO: NAT tiene valor (MO, MAT, EQUIPO, %)
      else if (nat.isNotEmpty && partidaActualId != null) {
        print('  -> RECURSO: "$codigo" tipo "$nat" bajo partida ID: $partidaActualId');
        await _crearRecurso(
          presupuestoId: presupuestoId,
          partidaId: partidaActualId,
          codigo: codigo,
          tipo: nat,
          descripcion: descripcion,
          unidad: unidad,
          medicion: medicion,
          precio: precio,
          importe: importe,
        );
        recursosCount++;
      } else if (nat.isNotEmpty && partidaActualId == null) {
        print('  -> ADVERTENCIA: Recurso "$codigo" sin partida activa, se omite');
      }
    }
    
    return {
      'capitulos': capitulosCount,
      'partidas': partidasCount,
      'recursos': recursosCount,
    };
  }

  /// Crea un capítulo o subcapítulo
  Future<int> _crearCapitulo({
    required int presupuestoId,
    required String codigo,
    required String descripcion,
    required String unidad,
    int? padreId,
  }) async {
    return await _database.insertConcepto(
      ConceptosCompanion.insert(
        codigo: codigo,
        nombre: descripcion,
        tipoRecurso: 'Capítulo',
        cantidad: const drift.Value(1.0), // Capítulos siempre tienen cantidad 1
        presupuestoId: drift.Value(presupuestoId),
        padreId: drift.Value(padreId),
      ),
    );
  }

  /// Crea una partida
  Future<int> _crearPartida({
    required int presupuestoId,
    int? capituloId,
    required String codigo,
    required String descripcion,
    required String unidad,
    required double cantidad,
    required double precio,
  }) async {
    return await _database.insertConcepto(
      ConceptosCompanion.insert(
        codigo: codigo,
        nombre: descripcion,
        tipoRecurso: 'Partida',
        cantidad: drift.Value(cantidad),
        coste: drift.Value(precio),
        presupuestoId: drift.Value(presupuestoId),
        padreId: drift.Value(capituloId),
      ),
    );
  }

  /// Crea un recurso (MO, MAT, EQUIPO, %)
  Future<int> _crearRecurso({
    required int presupuestoId,
    required int partidaId,
    required String codigo,
    required String tipo,
    required String descripcion,
    required String unidad,
    required double medicion,
    required double precio,
    required double importe,
  }) async {
    // Mapear tipo NAT a tipoRecurso
    String tipoRecurso;
    switch (tipo.toUpperCase()) {
      case 'MO':
        tipoRecurso = 'Mano de obra';
        break;
      case 'MAT':
        tipoRecurso = 'Material';
        break;
      case 'EQUIPO':
        tipoRecurso = 'Equipo';
        break;
      case '%':
        tipoRecurso = 'Otros'; // Las fórmulas las clasificamos como Otros
        break;
      default:
        tipoRecurso = 'Otros';
    }
    
    return await _database.insertConcepto(
      ConceptosCompanion.insert(
        codigo: codigo,
        nombre: descripcion,
        tipoRecurso: tipoRecurso,
        cantidad: drift.Value(medicion),
        coste: drift.Value(precio),
        importe: drift.Value(importe),
        presupuestoId: drift.Value(presupuestoId),
        padreId: drift.Value(partidaId),
      ),
    );
  }

  /// Obtiene el valor de una celda como String
  String _getCellValue(List<dynamic> row, int index) {
    try {
      if (index >= row.length || row[index] == null) return '';
      final value = row[index];
      
      if (value == null) return '';
      
      return value.toString().trim();
    } catch (e) {
      // Si hay error al leer la celda, retornar vacío
      print('Error leyendo celda en índice $index: $e');
      return '';
    }
  }

  /// Obtiene el valor de una celda como double
  double _getCellValueDouble(List<dynamic> row, int index) {
    try {
      if (index >= row.length || row[index] == null) return 0.0;
      final value = row[index];
      
      if (value == null) return 0.0;
      
      // Si ya es un número, retornarlo directamente
      if (value is num) {
        return value.toDouble();
      }
      
      // Convertir a string y parsear
      final stringValue = value.toString().trim();
      
      if (stringValue.isEmpty) return 0.0;
      
      // Reemplazar coma por punto para decimales
      final cleanValue = stringValue.replaceAll(',', '.');
      
      // Eliminar caracteres no numéricos excepto punto, signo menos
      final numericValue = cleanValue.replaceAll(RegExp(r'[^\d.\-]'), '');
      
      if (numericValue.isEmpty) return 0.0;
      
      return double.parse(numericValue);
    } catch (e) {
      // Si no se puede parsear, retornar 0
      print('Error parseando celda en índice $index: $e');
      return 0.0;
    }
  }

  /// Calcula totales de forma recursiva de abajo hacia arriba
  /// 1. Calcula importe de recursos (cantidad × coste)
  /// 2. Calcula coste e importe de partidas (suma de recursos hijos)
  /// 3. Calcula coste e importe de capítulos (suma de partidas hijas)
  Future<void> _calcularTotalesRecursivos(int presupuestoId) async {
    // Obtener todos los conceptos del presupuesto ordenados por nivel (más profundo primero)
    final conceptos = await (_database.select(_database.conceptos)
          ..where((c) => c.presupuestoId.equals(presupuestoId))
          ..orderBy([
            (c) => drift.OrderingTerm(
                  expression: c.id,
                  mode: drift.OrderingMode.desc,
                ), // Procesar de abajo hacia arriba
          ]))
        .get();

    print('   Total conceptos a procesar: ${conceptos.length}');

    // Set para rastrear qué conceptos ya fueron actualizados
    final Set<int> procesados = {};

    // Procesar cada concepto
    for (final concepto in conceptos) {
      if (procesados.contains(concepto.id)) continue;

      await _calcularConcepto(concepto, procesados);
    }
  }

  /// Calcula el total de un concepto y propaga hacia arriba
  Future<void> _calcularConcepto(
    Concepto concepto,
    Set<int> procesados,
  ) async {
    // Si ya fue procesado, saltar
    if (procesados.contains(concepto.id)) return;

    // Primero calcular todos los hijos
    final hijos = await (_database.select(_database.conceptos)
          ..where((c) => c.padreId.equals(concepto.id)))
        .get();

    // Calcular recursivamente los hijos primero
    for (final hijo in hijos) {
      await _calcularConcepto(hijo, procesados);
    }

    // Ahora calcular este concepto
    double nuevoCoste = 0.0;
    double nuevoImporte = 0.0;

    if (hijos.isEmpty) {
      // Concepto hoja (recurso): importe = cantidad × coste
      nuevoImporte = concepto.cantidad * concepto.coste;
      nuevoCoste = concepto.coste;
    } else {
      // Concepto padre (partida/capítulo): sumar importes de hijos
      for (final hijo in hijos) {
        nuevoImporte += hijo.importe;
      }
      
      // Para partidas y capítulos, el coste es igual al importe
      nuevoCoste = nuevoImporte;
    }

    // Actualizar si cambió
    if (nuevoCoste != concepto.coste || nuevoImporte != concepto.importe) {
      await (_database.update(_database.conceptos)
            ..where((c) => c.id.equals(concepto.id)))
          .write(
        ConceptosCompanion(
          coste: drift.Value(nuevoCoste),
          importe: drift.Value(nuevoImporte),
        ),
      );

      print('   ✓ ${concepto.codigo}: coste=$nuevoCoste, importe=$nuevoImporte');
    }

    // Marcar como procesado
    procesados.add(concepto.id);
  }
}
