import 'package:sqflite/sqflite.dart';
import '../../database.dart';
import 'package:ecommerce/app/repositories/customer/model/customer_model.dart';

class CustomerDao {
  static const String _tableCustomer = 'customer';

  static const String createTableCustomer = '''
    CREATE TABLE $_tableCustomer (
      codigo TEXT PRIMARY KEY,
      cliente TEXT,
      endereco TEXT,
      bairro TEXT,
      cidade TEXT,
      uf TEXT,
      restricao TEXT,
      limiteCredito TEXT
    );
  ''';

  Future<int> saveCustomer(CustomerModel customer) async {
    final Database db = await getDatabase();
    return await db.insert(
      _tableCustomer,
      _toMapCustomer(customer),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomerModel>> getCustomers() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(_tableCustomer);

    return result
        .map(
          (map) => CustomerModel(
            codigo: map['codigo'],
            cliente: map['cliente'],
            endereco: map['endereco'],
            bairro: map['bairro'],
            cidade: map['cidade'],
            uf: map['uf'],
            restricao: map['restricao'],
            limiteCredito: map['limiteCredito'],
          ),
        )
        .toList();
  }

  Future<CustomerModel?> getCustomerByCode(String codigo) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      _tableCustomer,
      where: 'codigo = ?',
      whereArgs: [codigo],
    );

    if (result.isNotEmpty) {
      final map = result.first;
      return CustomerModel(
        codigo: map['codigo'],
        cliente: map['cliente'],
        endereco: map['endereco'],
        bairro: map['bairro'],
        cidade: map['cidade'],
        uf: map['uf'],
        restricao: map['restricao'],
        limiteCredito: map['limiteCredito'],
      );
    }

    return null;
  }

  Future<int> deleteCustomer(String codigo) async {
    final Database db = await getDatabase();
    return await db.delete(
      _tableCustomer,
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
  }

  Map<String, dynamic> _toMapCustomer(CustomerModel customer) {
    return {
      'codigo': customer.codigo,
      'cliente': customer.cliente,
      'endereco': customer.endereco,
      'bairro': customer.bairro,
      'cidade': customer.cidade,
      'uf': customer.uf,
      'restricao': customer.restricao,
      'limiteCredito': customer.limiteCredito,
    };
  }
}
