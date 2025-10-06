import 'package:sqflite/sqflite.dart';
import 'package:ecommerce/app/repositories/finishCard/model/cart_order_model.dart';
import 'package:ecommerce/app/repositories/finishCard/model/cart_model.dart';

import '../../data_base.dart';

class CartDao {
  static const String _tableCart = 'cart';
  static const String _tableCartOrder = 'cart_order';

  static const String createTableCart = '''
    CREATE TABLE $_tableCart (
      idEmpresa TEXT,
      numPed TEXT PRIMARY KEY,
      idVendedor TEXT,
      idCliente TEXT,
      idTpPag TEXT,
      idCondPag TEXT,
      valDesc TEXT,
      obsPed TEXT,
      totalPed TEXT
    );
  ''';

  static const String createTableCartOrder = '''
    CREATE TABLE $_tableCartOrder (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numPed TEXT,
      idProduto TEXT,
      quantidade INTEGER,
      preco TEXT,
      FOREIGN KEY (numPed) REFERENCES $_tableCart (numPed) ON DELETE CASCADE
    );
  ''';

  Future<int> saveCart(CartModel cart) async {
    final Database db = await getDatabase();

    await db.insert(_tableCart, _toMapCart(cart));

    for (final produto in cart.produtos) {
      await db.insert(_tableCartOrder, _toMapCartOrder(cart.numPed, produto));
    }

    return 1;
  }

  Future<List<CartModel>> getCarts() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> resultCart = await db.query(_tableCart);
    List<CartModel> carts = [];

    for (final cartMap in resultCart) {
      final String numPed = cartMap['numPed'];
      final List<Map<String, dynamic>> resultProducts = await db.query(
        _tableCartOrder,
        where: 'numPed = ?',
        whereArgs: [numPed],
      );

      final List<CartOrderModel> produtos =
      resultProducts.map((p) {
        return CartOrderModel(
          idProduto: p['idProduto'],
          quantidade: p['quantidade'],
          preco: p['preco'],
        );
      }).toList();

      carts.add(
        CartModel(
          idEmpresa: cartMap['idEmpresa'],
          numPed: cartMap['numPed'],
          idVendedor: cartMap['idVendedor'],
          idCliente: cartMap['idCliente'],
          idTpPag: cartMap['idTpPag'],
          idCondPag: cartMap['idCondPag'],
          valDesc: cartMap['valDesc'],
          obsPed: cartMap['obsPed'],
          totalPed: cartMap['totalPed'],
          produtos: produtos,
        ),
      );
    }

    return carts;
  }

  Map<String, dynamic> _toMapCart(CartModel cart) {
    return {
      'idEmpresa': cart.idEmpresa,
      'numPed': cart.numPed,
      'idVendedor': cart.idVendedor,
      'idCliente': cart.idCliente,
      'idTpPag': cart.idTpPag,
      'idCondPag': cart.idCondPag,
      'valDesc': cart.valDesc,
      'obsPed': cart.obsPed,
      'totalPed': cart.totalPed,
    };
  }

  Map<String, dynamic> _toMapCartOrder(String numPed, CartOrderModel order) {
    return {
      'numPed': numPed,
      'idProduto': order.idProduto,
      'quantidade': order.quantidade,
      'preco': order.preco,
    };
  }
}
