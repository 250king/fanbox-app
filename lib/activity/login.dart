import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  double loading = 0.0;

  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 6.0),
          child: loaded? const SizedBox(): LinearProgressIndicator(value: loading),
        ),
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false
          )
        ),
        initialUrlRequest: URLRequest(
          url: Uri.parse("https://www.fanbox.cc/auth/start")
        ),
        onLoadStop: (controller, url) {
          setState(() {
            loaded = true;
          });
        },
        onLoadError: (controller, url, code, message) {
          Navigator.pop(context, "NETWORK");
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            setState(() {
              loaded = true;
            });
          }
          setState(() {
            loaded = false;
            loading = progress / 100;
          });
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var url = navigationAction.request.url;
          if (url?.path == "/") {
            CookieManager.instance().getCookie(
              url: Uri.parse("https://www.fanbox.cc/"),
              name: "FANBOXSESSID"
            ).then((cookie) {
              SharedPreferences.getInstance().then((storage) {
                Dio().get("https://www.fanbox.cc/", options: Options(
                  headers: {
                    "Cookie": "FANBOXSESSID=${cookie?.value}"
                  }
                )).then((response) {
                  var html = parse(response.data);
                  var text = html.getElementById("metadata")?.attributes["content"];
                  var result = jsonDecode(text!);
                  storage.setString("access_token", cookie?.value).then((value) {
                    storage.setString("csrf_token", result["csrfToken"]).then((value) {
                      Navigator.pushNamedAndRemoveUntil(context, "/logon", (route) => false);
                    });
                  });
                });
              });
            });
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      )
    );
  }
}
