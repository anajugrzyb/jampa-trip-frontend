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
      version: 13, 
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 10) {
          try {
            await db.execute('ALTER TABLE companies ADD COLUMN logo TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE companies ADD COLUMN avaliacao REAL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE companies ADD COLUMN descricao TEXT');
          } catch (_) {}
        }

        if (oldVersion < 11) {
          try {
            await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
          } catch (_) {}
        }

        if (oldVersion < 12) {
          try {
            await db.execute('ALTER TABLE reservas ADD COLUMN tour_nome TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE reservas ADD COLUMN empresa TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE reservas ADD COLUMN valor_total REAL');
          } catch (_) {}
        }

        if (oldVersion < 13) {
          try {
            await db.execute('ALTER TABLE companies ADD COLUMN logo TEXT');
          } catch (_) {}
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
        password TEXT,
        profile_image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        cnpj TEXT,
        email TEXT,
        password TEXT,
        logo TEXT,
        avaliacao REAL DEFAULT 0,
        descricao TEXT
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
        data_reserva TEXT,
        tour_nome TEXT,
        empresa TEXT,
        valor_total REAL,
        FOREIGN KEY (tour_id) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_titular TEXT,
        numero_cartao TEXT,
        mes TEXT,
        ano TEXT,
        cvv TEXT
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
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

  Future<void> updateUserImage(String email, String imagePath) async {
    final dbClient = await db;
    await dbClient.update(
      'users',
      {'profile_image': imagePath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<String?> getUserImage(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      columns: ['profile_image'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first['profile_image'] as String? : null;
  }

  Future<int> insertCompany(Map<String, dynamic> company) async {
    final dbClient = await db;
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

  Future<Map<String, dynamic>?> getCompanyByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'companies',
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    final dbClient = await db;
    return await dbClient.query('companies', orderBy: 'id DESC');
  }

  Future<void> updateCompanyLogo(String email, String logoPath) async {
    final dbClient = await db;
    await dbClient.update(
      'companies',
      {'logo': logoPath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<String?> getCompanyLogo(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'companies',
      columns: ['logo'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first['logo'] as String? : null;
  }

  Future<int> insertTour(Map<String, dynamic> tour) async {
    final dbClient = await db;
    return await dbClient.insert('tours', tour);
  }

  Future<List<Map<String, dynamic>>> getTours({String? empresa}) async {
    final dbClient = await db;
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
    final dbClient = await db;
    return await dbClient.update('tours', tour, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTour(int id) async {
    final dbClient = await db;
    return await dbClient.delete('tours', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertReserva(Map<String, dynamic> reserva) async {
    final dbClient = await db;
    return await dbClient.insert('reservas', reserva);
  }

  Future<List<Map<String, dynamic>>> getReservas() async {
    final dbClient = await db;
    return await dbClient.query('reservas', orderBy: 'id DESC');
  }

  Future<int> deleteReserva(int id) async {
    final dbClient = await db;
    return await dbClient.delete('reservas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalReservasPorData(int tourId, String data) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT SUM(qtd_pessoas) as total FROM reservas 
      WHERE tour_id = ? AND data_reserva = ?
    ''', [tourId, data]);

    final total = result.first['total'];
    if (total == null) return 0;
    return (total is int) ? total : int.tryParse(total.toString()) ?? 0;
  }


  Future<int> insertCard(Map<String, dynamic> card) async {
    final dbClient = await db;
    return await dbClient.insert('cards', card);
  }

  Future<List<Map<String, dynamic>>> getCards() async {
    final dbClient = await db;
    return await dbClient.query('cards', orderBy: 'id DESC');
  }

  Future<int> deleteCard(int id) async {
    final dbClient = await db;
    return await dbClient.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllCards() async {
    final dbClient = await db;
    await dbClient.delete('cards');
  }
}
