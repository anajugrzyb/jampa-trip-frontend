import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app.db');

    return await openDatabase(
      path,
      version: 6, 
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tours (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT,
              local TEXT,
              datas TEXT,
              saida TEXT,
              chegada TEXT,
              qtd_pessoas TEXT,
              info TEXT,
              imagens TEXT,
              preco REAL DEFAULT 0,
              empresa TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE tours ADD COLUMN preco REAL DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reservas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tour_id INTEGER,
              nome TEXT,
              telefone TEXT,
              endereco TEXT,
              qtd_pessoas INTEGER,
              observacoes TEXT,
              FOREIGN KEY (tour_id) REFERENCES tours (id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE tours ADD COLUMN empresa TEXT');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        cnpj TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        local TEXT,
        datas TEXT,
        saida TEXT,
        chegada TEXT,
        qtd_pessoas TEXT,
        info TEXT,
        imagens TEXT,
        preco REAL DEFAULT 0,
        empresa TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reservas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tour_id INTEGER,
        nome TEXT,
        telefone TEXT,
        endereco TEXT,
        qtd_pessoas INTEGER,
        observacoes TEXT,
        FOREIGN KEY (tour_id) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');
  }

  // ===== Users =====
  Future<int> insertUser(Map<String, dynamic> user) async {
    var dbClient = await db;
    return await dbClient.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ===== Companies =====
  Future<int> insertCompany(Map<String, dynamic> company) async {
    var dbClient = await db;
    return await dbClient.insert('companies', company);
  }

  Future<Map<String, dynamic>?> getCompany(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'companies',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ===== Tours =====
  Future<int> insertTour(Map<String, dynamic> tour) async {
    var dbClient = await db;
    return await dbClient.insert('tours', tour);
  }

  Future<List<Map<String, dynamic>>> getTours({String? empresa}) async {
    var dbClient = await db;

    if (empresa != null) {
      return await dbClient.query(
        'tours',
        where: 'empresa = ?',
        whereArgs: [empresa],
        orderBy: 'id DESC',
      );
    }

    return await dbClient.query('tours', orderBy: 'id DESC');
  }

  Future<int> updateTour(int id, Map<String, dynamic> tour) async {
    var dbClient = await db;
    return await dbClient.update('tours', tour, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTour(int id) async {
    var dbClient = await db;
    return await dbClient.delete('tours', where: 'id = ?', whereArgs: [id]);
  }

  // ===== Reservas =====
  Future<int> insertReserva(Map<String, dynamic> reserva) async {
    var dbClient = await db;
    return await dbClient.insert('reservas', reserva);
  }

  Future<List<Map<String, dynamic>>> getReservas() async {
    var dbClient = await db;
    return await dbClient.query('reservas', orderBy: 'id DESC');
  }

  Future<int> deleteReserva(int id) async {
    var dbClient = await db;
    return await dbClient.delete('reservas', where: 'id = ?', whereArgs: [id]);
  }
}
