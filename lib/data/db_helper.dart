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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE companies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company_name TEXT,
            cnpj TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE tours (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            local TEXT,
            datas TEXT,
            saida TEXT,
            chegada TEXT,
            qtd_pessoas TEXT,
            info TEXT,
            imagens TEXT,
            preco REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE tours (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT,
              local TEXT,
              datas TEXT,
              saida TEXT,
              chegada TEXT,
              qtd_pessoas TEXT,
              info TEXT,
              imagens TEXT,
              preco REAL
            )
          ''');
        }
      },
    );
  }



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
    if (result.isNotEmpty) return result.first;
    return null;
  }


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
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> insertTour(Map<String, dynamic> tour) async {
    var dbClient = await db;
    return await dbClient.insert('tours', tour);
  }

  Future<List<Map<String, dynamic>>> getTours() async {
    var dbClient = await db;
    return await dbClient.query('tours');
  }

  Future<int> deleteTour(int id) async {
    var dbClient = await db;
    return await dbClient.delete('tours', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTour(int id, Map<String, dynamic> tour) async {
    var dbClient = await db;
    return await dbClient.update('tours', tour, where: 'id = ?', whereArgs: [id]);
  }
}
