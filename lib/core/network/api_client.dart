import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://ery-app-turso.vercel.app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void init() {
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }
}
