import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Obras, Proyectos, Presupuestos, Contactos, Productos, Empleados, Usuarios, Companias, UnidadesMedida, Monedas, CategoriasProductos, Estados, Conceptos, MensajesChat, MensajesConceptos, AdjuntosConceptos, Integradores])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(contactos);
      }
      if (from < 3) {
        // Migrar tabla contactos eliminando columnas empresa y cargo
        await m.deleteTable('contactos');
        await m.createTable(contactos);
      }
      if (from < 4) {
        await m.createTable(productos);
      }
      if (from < 5) {
        await m.createTable(usuarios);
      }
      if (from < 6) {
        await m.createTable(companias);
      }
      if (from < 7) {
        await m.addColumn(usuarios, usuarios.perfil);
      }
      if (from < 8) {
        await m.createTable(unidadesMedida);
        await m.createTable(monedas);
        await m.createTable(categoriasProductos);
      }
      if (from < 9) {
        await m.createTable(proyectos);
      }
      if (from < 10) {
        await m.addColumn(proyectos, proyectos.clienteId);
      }
      if (from < 11) {
        await m.createTable(estados);
        await m.addColumn(proyectos, proyectos.estadoId);
      }
      if (from < 12) {
        await m.createTable(empleados);
      }
      if (from < 13) {
        await m.createTable(presupuestos);
      }
      if (from < 14) {
        await m.addColumn(contactos, contactos.foto);
        await m.addColumn(usuarios, usuarios.foto);
        await m.addColumn(presupuestos, presupuestos.estadoId);
      }
      if (from < 15) {
        await m.addColumn(companias, companias.monedaId);
      }
      if (from < 16) {
        await m.addColumn(presupuestos, presupuestos.tipoCalculo);
      }
      if (from < 17) {
        await m.createTable(conceptos);
      }
      if (from < 18) {
        await m.createTable(mensajesChat);
      }
      if (from < 19) {
        await m.createTable(mensajesConceptos);
        await m.createTable(adjuntosConceptos);
      }
      if (from < 20) {
        await m.createTable(integradores);
      }
    },
  );

  // CRUD Operations for Obras
  Future<List<Obra>> getAllObras() => select(obras).get();
  
  Future<Obra> getObra(int id) => 
      (select(obras)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Obra>> watchAllObras() => select(obras).watch();
  
  Future<int> insertObra(ObrasCompanion obra) => 
      into(obras).insert(obra);
  
  Future<bool> updateObra(Obra obra) => 
      update(obras).replace(obra);
  
  Future<int> deleteObra(int id) => 
      (delete(obras)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Presupuestos
  Future<List<Presupuesto>> getAllPresupuestos() => 
      (select(presupuestos)..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)])).get();
  
  Future<Presupuesto> getPresupuesto(int id) => 
      (select(presupuestos)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Presupuesto>> watchAllPresupuestos() => select(presupuestos).watch();
  
  Future<int> insertPresupuesto(PresupuestosCompanion presupuesto) => 
      into(presupuestos).insert(presupuesto);
  
  Future<bool> updatePresupuesto(Presupuesto presupuesto) => 
      update(presupuestos).replace(presupuesto);
  
  Future<int> deletePresupuesto(int id) => 
      (delete(presupuestos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Contactos
  Future<List<Contacto>> getAllContactos() => select(contactos).get();
  
  Future<Contacto> getContacto(int id) => 
      (select(contactos)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Contacto>> watchAllContactos() => select(contactos).watch();
  
  Future<int> insertContacto(ContactosCompanion contacto) => 
      into(contactos).insert(contacto);
  
  Future<bool> updateContacto(Contacto contacto) => 
      update(contactos).replace(contacto);
  
  Future<int> deleteContacto(int id) => 
      (delete(contactos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Productos
  Future<List<Producto>> getAllProductos() => select(productos).get();
  
  Future<Producto> getProducto(int id) => 
      (select(productos)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Producto>> watchAllProductos() => select(productos).watch();
  
  Future<int> insertProducto(ProductosCompanion producto) => 
      into(productos).insert(producto);
  
  Future<bool> updateProducto(Producto producto) => 
      update(productos).replace(producto);
  
  Future<int> deleteProducto(int id) => 
      (delete(productos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Empleados
  Future<List<Empleado>> getAllEmpleados() => select(empleados).get();
  
  Future<Empleado> getEmpleado(int id) => 
      (select(empleados)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Empleado>> watchAllEmpleados() => select(empleados).watch();
  
  Future<int> insertEmpleado(EmpleadosCompanion empleado) => 
      into(empleados).insert(empleado);
  
  Future<bool> updateEmpleado(Empleado empleado) => 
      update(empleados).replace(empleado);
  
  Future<int> deleteEmpleado(int id) => 
      (delete(empleados)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Usuarios
  Future<List<Usuario>> getAllUsuarios() => select(usuarios).get();
  
  Future<Usuario?> getUsuarioByEmail(String email) async {
    final query = select(usuarios)..where((t) => t.email.equals(email));
    final result = await query.get();
    return result.isEmpty ? null : result.first;
  }
  
  Future<int> insertUsuario(UsuariosCompanion usuario) => 
      into(usuarios).insert(usuario);
  
  Future<bool> updateUsuario(Usuario usuario) => 
      update(usuarios).replace(usuario);
  
  Future<bool> hasUsuarios() async {
    final count = await (select(usuarios)).get();
    return count.isNotEmpty;
  }
  
  Future<int> deleteUsuario(int id) => 
      (delete(usuarios)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Companias
  Future<List<Compania>> getAllCompanias() => select(companias).get();
  
  Future<List<Compania>> getCompaniasActivas() => 
      (select(companias)..where((t) => t.activa.equals(true))).get();
  
  Future<Compania> getCompania(int id) => 
      (select(companias)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertCompania(CompaniasCompanion compania) => 
      into(companias).insert(compania);
  
  Future<bool> updateCompania(CompaniasCompanion compania) => 
      update(companias).replace(compania);
  
  Future<int> deleteCompania(int id) => 
      (delete(companias)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Proyectos
  Future<List<Proyecto>> getAllProyectos() => select(proyectos).get();
  
  Future<Proyecto> getProyecto(int id) => 
      (select(proyectos)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertProyecto(ProyectosCompanion proyecto) => 
      into(proyectos).insert(proyecto);
  
  Future<bool> updateProyecto(Proyecto proyecto) => 
      update(proyectos).replace(proyecto);
  
  Future<int> deleteProyecto(int id) => 
      (delete(proyectos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for UnidadesMedida
  Future<List<UnidadMedida>> getAllUnidadesMedida() => select(unidadesMedida).get();
  
  Future<UnidadMedida> getUnidadMedida(int id) => 
      (select(unidadesMedida)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertUnidadMedida(UnidadesMedidaCompanion unidad) => 
      into(unidadesMedida).insert(unidad);
  
  Future<bool> updateUnidadMedida(UnidadMedida unidad) => 
      update(unidadesMedida).replace(unidad);
  
  Future<int> deleteUnidadMedida(int id) => 
      (delete(unidadesMedida)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Monedas
  Future<List<Moneda>> getAllMonedas() => select(monedas).get();
  
  Future<Moneda> getMoneda(int id) => 
      (select(monedas)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertMoneda(MonedasCompanion moneda) => 
      into(monedas).insert(moneda);
  
  Future<bool> updateMoneda(Moneda moneda) => 
      update(monedas).replace(moneda);
  
  Future<int> deleteMoneda(int id) => 
      (delete(monedas)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for CategoriasProductos
  Future<List<CategoriaProducto>> getAllCategoriasProductos() => select(categoriasProductos).get();
  
  Future<CategoriaProducto> getCategoriaProducto(int id) => 
      (select(categoriasProductos)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertCategoriaProducto(CategoriasProductosCompanion categoria) => 
      into(categoriasProductos).insert(categoria);
  
  Future<bool> updateCategoriaProducto(CategoriaProducto categoria) => 
      update(categoriasProductos).replace(categoria);
  
  Future<int> deleteCategoriaProducto(int id) => 
      (delete(categoriasProductos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Estados
  Future<List<Estado>> getAllEstados() => select(estados).get();
  
  Future<Estado> getEstado(int id) => 
      (select(estados)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertEstado(EstadosCompanion estado) => 
      into(estados).insert(estado);
  
  Future<bool> updateEstado(Estado estado) => 
      update(estados).replace(estado);
  
  Future<int> deleteEstado(int id) => 
      (delete(estados)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Conceptos
  Future<List<Concepto>> getAllConceptos() => select(conceptos).get();
  
  Future<List<Concepto>> getConceptosByPresupuesto(int presupuestoId) => 
      (select(conceptos)..where((t) => t.presupuestoId.equals(presupuestoId))).get();
  
  Future<Concepto> getConcepto(int id) => 
      (select(conceptos)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Concepto>> watchAllConceptos() => select(conceptos).watch();
  
  Future<int> insertConcepto(ConceptosCompanion concepto) => 
      into(conceptos).insert(concepto);
  
  Future<bool> updateConcepto(Concepto concepto) => 
      update(conceptos).replace(concepto);
  
  Future<int> deleteConcepto(int id) => 
      (delete(conceptos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for MensajesChat
  Future<List<MensajeChat>> getAllMensajesChat() => 
      (select(mensajesChat)..orderBy([(t) => OrderingTerm.asc(t.fechaCreacion)])).get();
  
  Stream<List<MensajeChat>> watchAllMensajesChat() => 
      (select(mensajesChat)..orderBy([(t) => OrderingTerm.asc(t.fechaCreacion)])).watch();
  
  Future<int> insertMensajeChat(MensajesChatCompanion mensaje) => 
      into(mensajesChat).insert(mensaje);
  
  Future<int> deleteAllMensajesChat() => 
      delete(mensajesChat).go();

  // CRUD Operations for MensajesConceptos
  Future<List<MensajeConcepto>> getMensajesConcepto(int conceptoId) => 
      (select(mensajesConceptos)
        ..where((t) => t.conceptoId.equals(conceptoId))
        ..orderBy([(t) => OrderingTerm.asc(t.fechaCreacion)])).get();
  
  Stream<List<MensajeConcepto>> watchMensajesConcepto(int conceptoId) => 
      (select(mensajesConceptos)
        ..where((t) => t.conceptoId.equals(conceptoId))
        ..orderBy([(t) => OrderingTerm.asc(t.fechaCreacion)])).watch();
  
  Future<int> insertMensajeConcepto(MensajesConceptosCompanion mensaje) => 
      into(mensajesConceptos).insert(mensaje);
  
  Future<bool> updateMensajeConcepto(MensajeConcepto mensaje) => 
      update(mensajesConceptos).replace(mensaje);
  
  Future<int> deleteMensajeConcepto(int id) => 
      (delete(mensajesConceptos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for AdjuntosConceptos
  Future<List<AdjuntoConcepto>> getAdjuntosConcepto(int conceptoId) => 
      (select(adjuntosConceptos)
        ..where((t) => t.conceptoId.equals(conceptoId))
        ..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)])).get();
  
  Stream<List<AdjuntoConcepto>> watchAdjuntosConcepto(int conceptoId) => 
      (select(adjuntosConceptos)
        ..where((t) => t.conceptoId.equals(conceptoId))
        ..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)])).watch();
  
  Future<int> insertAdjuntoConcepto(AdjuntosConceptosCompanion adjunto) => 
      into(adjuntosConceptos).insert(adjunto);
  
  Future<bool> updateAdjuntoConcepto(AdjuntoConcepto adjunto) => 
      update(adjuntosConceptos).replace(adjunto);
  
  Future<int> deleteAdjuntoConcepto(int id) => 
      (delete(adjuntosConceptos)..where((t) => t.id.equals(id))).go();

  // CRUD Operations for Integradores
  Future<List<Integrador>> getAllIntegradores() => 
      (select(integradores)..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)])).get();
  
  Future<Integrador> getIntegrador(int id) => 
      (select(integradores)..where((t) => t.id.equals(id))).getSingle();
  
  Stream<List<Integrador>> watchAllIntegradores() => select(integradores).watch();
  
  Future<int> insertIntegrador(IntegradoresCompanion integrador) => 
      into(integradores).insert(integrador);
  
  Future<bool> updateIntegrador(Integrador integrador) => 
      update(integradores).replace(integrador);
  
  Future<int> deleteIntegrador(int id) => 
      (delete(integradores)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'presupuesto_obras.db'));
    return NativeDatabase.createInBackground(file);
  });
}
