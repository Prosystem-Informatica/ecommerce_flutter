import 'package:sqflite/sqflite.dart';

import '../../database.dart';

class CartDao {
  static const String _tableCart = 'cart';
  static const String tableCart =
      'CREATE TABLE $_tableCart('
      '$_id INTEGER, '
      '$_product_name INTEGER);';

  static const String _id = 'id';
  static const String _product_name = 'product_name';

  Future<int> saveCartOffModel() async {
    final Database db = await getDatabase();
    Map<String, dynamic> customersMap = _toMapCartOffModel();
    return db.insert(_tableCart, customersMap);
  }

  Map<String, dynamic> _toMapCartOffModel() {
    final Map<String, dynamic> cartOffModelMap = Map();

    return cartOffModelMap;
  }

  /*
  Future<CartOffModel> getCartOffModelById(int id) async {
    final Database db = await getDatabase();
    List<Map> result = await db.query(
      _tableCart,
      columns: [
        _id,
        _id_nota_fiscal_assinatura,
        _inter_number,
        _bank_slip_number,
        _bank_slip_value,
        _bank_slip_issue,
        _bank_slip_due,
        _bank_slip_payment,
        _status,
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.length > 0) {
      return new CartOffModel.fromJson(result.first);
    }
    return null;
  }

  Future<List<CartOffModel>> findAllCartOffModel() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(_tableCart);
    List<CartOffModel> cartOffModelList = _toListCartOffModel(result);
    return cartOffModelList;
  }

  Future<bool> verifyCartOffModel(int id) async {
    final Database db = await getDatabase();
    List<Map> result = await db.query(
      _tableCart,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: ['$id'],
    );

    if (result.length > 0) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> _toMapCartOffModel(CartOffModel cartOffModel) {
    final Map<String, dynamic> cartOffModelMap = Map();
    cartOffModelMap['id'] = cartOffModel.id;
    cartOffModelMap['id_nota_fiscal_assinatura'] =
        cartOffModel.id_nota_fiscal_assinatura;
    cartOffModelMap['inter_number'] = cartOffModel.inter_number;
    cartOffModelMap['bank_slip_number'] = cartOffModel.bank_slip_number;
    cartOffModelMap['bank_slip_value'] = cartOffModel.bank_slip_value;
    cartOffModelMap['bank_slip_issue'] = cartOffModel.bank_slip_issue;
    cartOffModelMap['bank_slip_due'] = cartOffModel.bank_slip_due;
    cartOffModelMap['bank_slip_payment'] = cartOffModel.bank_slip_payment;
    cartOffModelMap['status'] = cartOffModel.status;
    return cartOffModelMap;
  }

  List<CartOffModel> _toListCartOffModel(List<Map<String, dynamic>> result) {
    final List<CartOffModel> cartOffList = List();
    for (Map<String, dynamic> row in result) {
      final CartOffModel cart = CartOffModel(
        row['id'],
        row['id_nota_fiscal_assinatura'],
        row['inter_number'],
        row['bank_slip_number'],
        row['bank_slip_value'],
        row['bank_slip_issue'],
        row['bank_slip_due'],
        row['bank_slip_payment '],
        row['status'],
      );
      cartOffList.add(cart);
    }
    return cartOffList;
  }*/
}
