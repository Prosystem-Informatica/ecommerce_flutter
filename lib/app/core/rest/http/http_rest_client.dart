import 'dart:developer';
import 'package:http/http.dart' as http;
import '../rest_client.dart';
import '../rest_client_response.dart';

class HttpRestClient implements RestClient {
  late final http.Client rest;
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  HttpRestClient({
    required this.baseUrl,
  })  : rest = http.Client(),
        defaultHeaders = {
          'content-type': 'application/json',
        };

  @override
  RestClient auth() {
    defaultHeaders['authorization'] = 'token';
    return this;
  }

  @override
  Future<RestClientResponse<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
        Map<String, String>? headers}) async {
    log("Url da API > ${baseUrl} + ${path}");
    final uri = Uri.https(baseUrl ,path, queryParameters);
    final response = await rest.get(uri, headers: joinHeaders(headers));
    //await AuthValidation().refreshToken(response.headers);
    return RestClientResponse.fromHttp(response);
  }

  @override
  Future<RestClientResponse<T>> post<T>(String path,
      {data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try{
      final uri = Uri.https(baseUrl,'/API'+path, queryParameters);
      final response =
      await rest.post(uri, body: data, headers: joinHeaders(headers));
      //await AuthValidation().refreshToken(response.headers);
      return RestClientResponse.fromHttp(response);
    }on Exception {
      rethrow;
    }
  }

  @override
  RestClient unAuth() {
    defaultHeaders.remove("authorization");
    return this;
  }

  Map<String, String> joinHeaders(Map<String, String>? h) {
    Map<String, String> headers = defaultHeaders;
    h?.forEach((key, value) {
      headers[key] = value;
    });
    return headers;
  }
}