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
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);
      print("Json > ${jsonData}");

      await prefs.setString(
        'host',
        jsonData[0]['SERVIDOR'].toString().toLowerCase(),
      );
      await prefs.setString(
        'port',
        jsonData[0]['PORTA'].toString().toLowerCase(),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<LoginModel> login(String login, String password) async {
    try {
      prefs = await SharedPreferences.getInstance();

      login = login.toUpperCase();
      password = password.toUpperCase();

      var path = '/datasnap/rest/TServerAPPecf/LoginApp/$login/$password';
      var response = await _rest.get(path);

      var jsonData = response.data;
      print("Json > ${jsonData}");

      var res = await LoginModel.fromJson(jsonData[0]);

      if (res.validado == "T") {
        await prefs.setString('userLogin', login);
        await prefs.setString('userCodigo', res.codigo ?? '');
        await prefs.setString('companyCodigo', res.empresa ?? '');
        await prefs.setString('userFantasia', res.fantasia ?? 'Nome pendente');
        await prefs.setString('userEmail', res.email?.isNotEmpty == true ? res.email! : 'Email pendente');
        if (res.imagem64 != null && res.imagem64!.isNotEmpty) {
          await prefs.setString('userImagem64', res.imagem64!);
        }
      }

      return res;
    } catch (e) {
      log(e.toString());
      return LoginModel();
    }
  }

  Future<void> logout() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove('userLogin');
    await prefs.remove('userCodigo');
    await prefs.remove('companyCodigo');
    await prefs.remove('userFantasia');
    await prefs.remove('userEmail');
    await prefs.remove('userImagem64');
  }
}
