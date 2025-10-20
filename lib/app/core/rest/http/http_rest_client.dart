import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../rest_client.dart';
import '../rest_client_response.dart';

class HttpRestClient implements RestClient {
  late final http.Client rest;
  String? _baseUrl;
  final Map<String, String> defaultHeaders;

  HttpRestClient({String? baseUrl})
      : _baseUrl = baseUrl,
        rest = http.Client(),
        defaultHeaders = {'content-type': 'application/json'};

  Future<void> setBaseUrl(String host, String port) async {
    _baseUrl = '$host:$port';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', host);
    await prefs.setString('port', port);
  }

  static Future<String?> getSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');
    if (host != null && port != null) return '$host:$port';
    return null;
  }

  @override
  RestClient auth() {
    defaultHeaders['authorization'] = 'token';
    return this;
  }

  @override
  RestClient unAuth() {
    defaultHeaders.remove('authorization');
    return this;
  }

  @override
  Future<RestClientResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    if (_baseUrl == null) {
      final saved = await getSavedBaseUrl();
      if (saved == null) throw Exception('BaseUrl não definido');
      _baseUrl = saved;
    }

    final uri = Uri.http(_baseUrl!, path, queryParameters);
    log("GET API > $uri");
    final response = await rest.get(uri, headers: joinHeaders(headers));
    return RestClientResponse.fromHttp(response);
  }

  @override
  Future<RestClientResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    if (_baseUrl == null) {
      final saved = await getSavedBaseUrl();
      if (saved == null) throw Exception('BaseUrl não definido');
      _baseUrl = saved;
    }

    final uri = Uri.http(_baseUrl!, path, queryParameters);
    log("POST API > $uri");
    final response = await rest.post(uri, body: data, headers: joinHeaders(headers));
    return RestClientResponse.fromHttp(response);
  }

  Map<String, String> joinHeaders(Map<String, String>? h) {
    final Map<String, String> headers = Map.from(defaultHeaders);
    h?.forEach((key, value) => headers[key] = value);
    return headers;
  }
}
