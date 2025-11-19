import 'package:dio/dio.dart';

class Environment {
  static const apiPath = 'https://v2.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 10000),
    receiveTimeout: Duration(milliseconds: 10000),
    contentType: 'application/json',
  );
}

class AuthEnvironment {
  static const apiPath = 'https://v3.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 10000),
    receiveTimeout: Duration(milliseconds: 10000),
    contentType: 'application/json',
  );
}
