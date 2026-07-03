  import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:diacritic/diacritic.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,

        respuesta_idolo TEXT,
        respuesta_comida TEXT,
        respuesta_padre TEXT,
        respuesta_madre TEXT
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

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE usuarios ADD COLUMN respuesta_idolo TEXT',
      );

      await db.execute(
        'ALTER TABLE usuarios ADD COLUMN respuesta_comida TEXT',
      );

      await db.execute(
        'ALTER TABLE usuarios ADD COLUMN respuesta_padre TEXT',
      );

      await db.execute(
        'ALTER TABLE usuarios ADD COLUMN respuesta_madre TEXT',
      );
    }
  }

  // ============================================================
  // MÉTODO AUXILIAR
  // ============================================================

  String normalizarRespuesta(String texto) {
    return removeDiacritics(texto).trim().toLowerCase();
  }

  // ============================================================
  // MÉTODOS PARA USUARIOS
  // ============================================================

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert(
      'usuarios',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(int usuarioId) async {
  final db = await instance.database;

  final resultado = await db.query(
    'usuarios',
    where: 'id = ?',
    whereArgs: [usuarioId],
  );

  if (resultado.isNotEmpty) {
    return resultado.first;
  }

  return null;
  }

  Future<bool> verificarPasswordMaestra(
    int usuarioId,
    String password,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'usuarios',
      where: 'id = ? AND password = ?',
      whereArgs: [usuarioId, password],
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorCorreo(
    String email,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> actualizarPerfilUsuario({
    required int usuarioId,
    required String nuevoUsername,
    required String nuevoEmail,
    String? nuevaPassword,
  }) async {
    final db = await instance.database;

    final datos = {
      'username': nuevoUsername,
      'email': nuevoEmail,
    };

    if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
      datos['password'] = nuevaPassword;
    } 

    return await db.update(
      'usuarios',
      datos,
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }



  Future<int> guardarPreguntasSeguridad({
    required int usuarioId,
    required String idolo,
    required String comida,
    required String padre,
    required String madre,
  }) async {
    final db = await instance.database;

    return await db.update(
      'usuarios',
      {
        'respuesta_idolo': normalizarRespuesta(idolo),
        'respuesta_comida': normalizarRespuesta(comida),
        'respuesta_padre': normalizarRespuesta(padre),
        'respuesta_madre': normalizarRespuesta(madre),
      },
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  Future<Map<String, dynamic>?> validarPreguntasSeguridad({
    required String idolo,
    required String comida,
    required String padre,
    required String madre,
  }) async {
    final db = await instance.database;

    final resultado = await db.query(
      'usuarios',
      where: '''
        respuesta_idolo = ? AND
        respuesta_comida = ? AND
        respuesta_padre = ? AND
        respuesta_madre = ?
      ''',
      whereArgs: [
        normalizarRespuesta(idolo),
        normalizarRespuesta(comida),
        normalizarRespuesta(padre),
        normalizarRespuesta(madre),
      ],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }

    return null;
  }

  Future<int> actualizarPasswordMaestra(
    int usuarioId,
    String nuevaPassword,
  ) async {
    final db = await instance.database;

    return await db.update(
      'usuarios',
      {
        'password': nuevaPassword,
      },
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ============================================================
  // MÉTODOS PARA CREDENCIALES
  // ============================================================
  
  
  // Obtener solo las credenciales del usuario autenticado
  Future<List<Map<String, dynamic>>> getCredentialsByUser(
    int usuarioId,
  ) async {
    final db = await instance.database;

    return await db.query(
      'credenciales',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // Insertar una nueva credencial
  Future<int> insertCredential(
    Map<String, dynamic> row,
  ) async {
    final db = await instance.database;

    return await db.insert(
      'credenciales',
      row,
    );
  }

  // Modificar una credencial existente
  Future<int> updateCredential(
    Map<String, dynamic> row,
  ) async {
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
  Future<int> deleteCredential(
    int id,
  ) async {
    final db = await instance.database;

    return await db.delete(
      'credenciales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}