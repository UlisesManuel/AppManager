import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE credenciales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        nombre_servicio TEXT NOT NULL,
        usuario_servicio TEXT NOT NULL,
        password_servicio TEXT NOT NULL,
        FOREIGN KEY(usuario_id)
        REFERENCES usuarios(id)
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert(
      'usuarios',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- MÉTODOS PARA LA TABLA CREDENCIALES ---

  // Obtener solo las credenciales del usuario autenticado
  Future<List<Map<String, dynamic>>> getCredentialsByUser(int usuarioId) async {
    final db = await instance.database;
    return await db.query(
      'credenciales',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // Insertar una nueva credencial
  Future<int> insertCredential(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('credenciales', row);
  }

  // Modificar una credencial existente
  Future<int> updateCredential(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'credenciales',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar una credencial
  Future<int> deleteCredential(int id) async {
    final db = await instance.database;
    return await db.delete(
      'credenciales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método extra requerido por el .md: Verificar si la contraseña maestra coincide
  Future<bool> verificarPasswordMaestra(int usuarioId, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'usuarios',
      where: 'id = ? AND password = ?',
      whereArgs: [usuarioId, password],
    );
    return result.isNotEmpty;
  }
  Future<Map<String, dynamic>?> login(
    String email,
    String password,
    ) async {
    final db = await instance.database;

    final result = await db.query(
        'usuarios',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
        return result.first;
    }

    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}