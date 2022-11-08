import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanbox/activity/welcome.dart';
import 'package:fanbox/activity/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((storage) {
    final token = storage.getString("access_token");
    if (token == null) {
      runApp(const App(login: false));
    }
    else {
      Dio().get("https://api.fanbox.cc/user.getTwitterAccountInfo", options: Options(
        sendTimeout: 10000,
        headers: {
          "Cookie": "FANBOXSESSID=$token",
          "Origin": "https://www.fanbox.cc"
        }
      )).then((response) {
        runApp(const App(login: true));
      }).onError((error, stackTrace) {
        runApp(const App(login: false));
        storage.remove("token");
      });
    }
  });
}

class App extends StatelessWidget {
  const App({super.key, required this.login});

  final bool login;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fanbox',
      initialRoute: login? "/logon": "/login",
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true
      ),
      routes: {
        "/login": (context) => const WelcomeActivity(),
        "/logon": (context) => const MainActivity()
      },
    );
  }
}

