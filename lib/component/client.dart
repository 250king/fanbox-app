import 'package:dio/dio.dart';

class Client {
  static var dio = Dio(BaseOptions(
    baseUrl: "https://api.fanbox.cc/"
  ));

  static Dio init(accessToken, csrfToken) {
    dio.options.headers = {
      "Origin": "https://www.fanbox.cc",
      "Cookie": "FANBOXSESSID=$accessToken",
      "X-CSRF-Token": csrfToken
    };
    return dio;
  }
}
