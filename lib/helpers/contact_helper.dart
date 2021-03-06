import 'package:contacts_flutter_app/models/contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class ContactHelper {
  final String contactTable = "Contact";

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? database;

  Future<Database> get db async {
    if (database != null) {
      return database!;
    } else {
      database = await initDb();
      return database!;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();

    String path = "";
    if (databasePath != null) path = join(databasePath, "contacts_flutter.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database _db = await db;
    contact.id = await _db.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<int> deleteContact(int id) async {
    Database _db = await db;
    return await _db
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database _db = await db;
    return await _db.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database _db = await db;
    List<Map<String, dynamic>> listMap =
        await _db.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];

    for (Map map_elem in listMap) {
      listContact.add(Contact.fromMap(map_elem));
    }
    return listContact;
  }

  Future<int?> getNumber() async {
    Database _db = await db;

    final allContacts =
        await _db.rawQuery("SELECT COUNT(*) FROM $contactTable");
    if (allContacts != null)
      return Sqflite.firstIntValue(allContacts);
    else
      return 0;
  }

  Future close() async {
    database?.close();
  }
}
