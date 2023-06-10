import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanbox/component/model/certificate.dart';
import 'package:fanbox/activity/welcome.dart';
import 'package:fanbox/activity/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((storage) {
    final accessToken = storage.getString("access_token");
    final csrfToken = storage.getString("csrf_token");
    if (accessToken == null || csrfToken == null) {
      runApp(App(certificate: Certificate("", "")));
    }
    else {
      Dio().get("https://api.fanbox.cc/user.getTwitterAccountInfo", options: Options(
        sendTimeout: const Duration(seconds: 10),
        headers: {
          "Cookie": "FANBOXSESSID=$accessToken",
          "Origin": "https://www.fanbox.cc"
        }
      )).then((response) {
        runApp(App(certificate: Certificate(accessToken, csrfToken)));
      }).onError((error, stackTrace) {
        runApp(App(certificate: Certificate("", "")));
        storage.remove("token");
      });
    }
  });
}

class App extends StatelessWidget {
  const App({super.key, required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fanbox',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true
      ),
      home: certificate.accessToken.isEmpty? const WelcomeActivity(): MainActivity(certificate: certificate)
    );
  }
}

