import 'package:ecommerce/app/core/database/dao/cart/cart_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  final String path = join(databasesPath, 'prosystem.db');

  var db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      db.execute(CartDao.tableCart);
    },
    onUpgrade: (db, oldVersion, newVersion) {},
  );
  return db;
}
