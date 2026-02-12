import 'package:dio/dio.dart';

class AndroidKencanaEnvironment {
  static const apiPath = 'https://android.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: 'application/json',
  );
}

class KmbEnvironment {
  static const apiPath = 'https://api-kmb.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: 'application/json',
  );
}

class Environment {
  static const apiPath = 'https://v2.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: 'application/json',
  );
}

class AuthEnvironment {
  static const apiPath = 'https://v3.kencana.org/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: 'application/json',
  );
}

class DevEnvironment {
  static const apiPath = 'http://10.65.65.222:8000/';
  // static const apiPath = 'http://10.0.2.2:8000/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: 'application/json',
  );
}
