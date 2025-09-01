import 'dart:convert';
import 'dart:developer';
import 'package:ecommerce/app/repositories/login/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/rest/rest_client.dart';
import 'i_login_repository.dart';

class LoginRepository implements ILoginRepository {
  final RestClient _rest;
  late SharedPreferences prefs;
  LoginRepository({required RestClient rest}) : _rest = rest;

  @override
  Future<void> checkUrl() async {
    try {
      prefs = await SharedPreferences.getInstance();

      var url =
          'http://prosystem.dyndns-work.com:9090/datasnap/rest/TserverAPPnfe/LoginEmpresa/10329033000133';
      var response = await _rest.get(url);

      var jsonData = jsonDecode(response.data);
      print("Json > ${jsonData}");

      await prefs.setString(
        'host',
        jsonData[0]['SERVIDOR'].toString().toLowerCase(),
      );
      await prefs.setString(
        'port',
        jsonData[0]['PORTA'].toString().toLowerCase(),
      );

      return;
    } catch (e) {
      log(e.toString());
      //return ValidationModel();
    }
  }

  @override
  Future<LoginModel> login(String login, String password) async {
    try {
      prefs = await SharedPreferences.getInstance();
      var host = await prefs.getString("host");
      var port = await prefs.getString("port");

      print("Host > ${host}");

      var url =
          '$host:$port/datasnap/rest/TServerAPPecf/LoginApp/$login/$password';
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);
      print("Json > ${jsonData}");

      var res = await LoginModel.fromJson(jsonData[0]);

      return res;
    } catch (e) {
      log(e.toString());
      return LoginModel();
      //return ValidationModel();
    }
  }
}
