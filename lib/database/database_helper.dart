import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calificacion.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calificaciones.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calificaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreEstudiante TEXT NOT NULL,
        materia TEXT NOT NULL,
        profesor TEXT NOT NULL,
        notaFinal REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'A'
      )
    ''');
  }

  // Crear
  Future<int> crear(Calificacion c) async {
    final db = await database;
    return await db.insert('calificaciones', c.toMap());
  }

  // Leer todos los activos
  Future<List<Calificacion>> obtenerTodos() async {
    final db = await database;
    final result = await db.query(
      'calificaciones',
      where: 'estado = ?',
      whereArgs: ['A'],
      orderBy: 'nombreEstudiante ASC',
    );
    return result.map((map) => Calificacion.fromMap(map)).toList();
  }

  // Leer uno por id
  Future<Calificacion?> obtenerPorId(int id) async {
    final db = await database;
    final result = await db.query(
      'calificaciones',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return Calificacion.fromMap(result.first);
    return null;
  }

  // Actualizar
  Future<int> actualizar(Calificacion c) async {
    final db = await database;
    return await db.update(
      'calificaciones',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  // Eliminación lógica (cambia estado a 'I')
  Future<int> eliminar(int id) async {
    final db = await database;
    return await db.update(
      'calificaciones',
      {'estado': 'I'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar por nombre o materia
  Future<List<Calificacion>> buscar(String texto) async {
    final db = await database;
    final result = await db.query(
      'calificaciones',
      where: 'estado = ? AND (nombreEstudiante LIKE ? OR materia LIKE ?)',
      whereArgs: ['A', '%$texto%', '%$texto%'],
      orderBy: 'nombreEstudiante ASC',
    );
    return result.map((map) => Calificacion.fromMap(map)).toList();
  }

  // Filtrar por rango de nota
  Future<List<Calificacion>> filtrarPorNota(double min, double max) async {
    final db = await database;
    final result = await db.query(
      'calificaciones',
      where: 'estado = ? AND notaFinal >= ? AND notaFinal <= ?',
      whereArgs: ['A', min, max],
      orderBy: 'nombreEstudiante ASC',
    );
    return result.map((map) => Calificacion.fromMap(map)).toList();
  }
}