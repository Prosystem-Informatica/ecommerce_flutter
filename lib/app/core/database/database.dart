import 'package:ecommerce/app/core/database/dao/cart/cart_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dao/customer/customer_dao.dart';
import 'dao/payment/payment_dao.dart';

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  final String path = join(databasesPath, 'prosystem.db');

  var db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      db.execute(CartDao.createTableCart);
      db.execute(CartDao.createTableCartOrder);
      db.execute(CustomerDao.createTableCustomer);
      db.execute(PaymentDao.createTablePaymentType);
    },
    onUpgrade: (db, oldVersion, newVersion) {},
  );
  return db;
}
