import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_commission_repository.dart';
import 'model/commission_model.dart';

class CommissionRepository implements ICommissionRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';

  @override
  Future<List<CommissionModel>> getCommissions({
    required String clientId,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse('$baseUrl/Comissao/$clientId/$startDate/$endDate');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) => CommissionModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar comissões: ${response.statusCode}');
    }
  }
}
