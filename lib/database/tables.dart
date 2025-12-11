import 'package:drift/drift.dart';

@DataClassName('Obra')
class Obras extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get cliente => text().withLength(min: 1, max: 200)();
  TextColumn get ubicacion => text().nullable().withLength(max: 300)();
  RealColumn get presupuestoTotal => real().withDefault(const Constant(0.0))();
  TextColumn get estado => text().withDefault(const Constant('Activa'))(); // Activa, En Proceso, Finalizada, Cancelada
  DateTimeColumn get fechaInicio => dateTime().nullable()();
  DateTimeColumn get fechaFin => dateTime().nullable()();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Proyecto')
class Proyectos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  IntColumn get clienteId => integer().nullable().references(Contactos, #id)();
  IntColumn get estadoId => integer().nullable().references(Estados, #id)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Presupuesto')
class Presupuestos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  IntColumn get companiaId => integer().nullable().references(Companias, #id)();
  IntColumn get monedaId => integer().nullable().references(Monedas, #id)();
  IntColumn get estadoId => integer().nullable().references(Estados, #id)();
  TextColumn get tipoCalculo => text().withDefault(const Constant('Estandar'))(); // Estandar, Apu
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Contacto')
class Contactos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get email => text().nullable().withLength(max: 200)();
  TextColumn get telefono => text().nullable().withLength(max: 50)();
  TextColumn get foto => text().nullable()(); // Path a la foto de perfil
  TextColumn get notas => text().nullable()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Producto')
class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get tipo => text().withLength(min: 1, max: 100)(); // Material, Servicio, Mano de obra, etc.
  RealColumn get precio => real().withDefault(const Constant(0.0))();
  RealColumn get coste => real().withDefault(const Constant(0.0))();
  TextColumn get descripcion => text().nullable()();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Empleado')
class Empleados extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get telefono => text().nullable().withLength(max: 50)();
  TextColumn get email => text().nullable().withLength(max: 200)();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get direccion => text().nullable().withLength(max: 300)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Usuario')
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get email => text().withLength(min: 1, max: 200).unique()();
  TextColumn get password => text().withLength(min: 1, max: 255)(); // Hash de la contraseña
  TextColumn get perfil => text().withDefault(const Constant('administrador'))(); // usuario, administrador
  TextColumn get foto => text().nullable()(); // Path a la foto de perfil
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get ultimoAcceso => dateTime().nullable()();
}

@DataClassName('Compania')
class Companias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  TextColumn get razonSocial => text().nullable().withLength(max: 200)();
  TextColumn get ruc => text().nullable().withLength(max: 50)();
  TextColumn get direccion => text().nullable().withLength(max: 300)();
  TextColumn get telefono => text().nullable().withLength(max: 50)();
  TextColumn get email => text().nullable().withLength(max: 200)();
  TextColumn get logo => text().nullable()(); // Path al logo
  IntColumn get monedaId => integer().nullable().references(Monedas, #id)();
  BoolColumn get activa => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UnidadMedida')
class UnidadesMedida extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Moneda')
class Monedas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get signo => text().withLength(min: 1, max: 10)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CategoriaProducto')
class CategoriasProductos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Estado')
class Estados extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Concepto')
class Conceptos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  TextColumn get nombre => text().withLength(min: 1, max: 200)();
  IntColumn get productoId => integer().nullable().references(Productos, #id)();
  RealColumn get cantidad => real().withDefault(const Constant(0.0))();
  RealColumn get coste => real().withDefault(const Constant(0.0))();
  RealColumn get importe => real().withDefault(const Constant(0.0))();
  IntColumn get padreId => integer().nullable().references(Conceptos, #id)();
  IntColumn get presupuestoId => integer().nullable().references(Presupuestos, #id)();
  TextColumn get tipoRecurso => text().withLength(min: 1, max: 100)(); // Material, Servicio, Mano de obra, etc.
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaModificacion => dateTime().withDefault(currentDateAndTime)();
}

