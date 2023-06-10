import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:fanbox/component/model/certificate.dart';
import 'package:fanbox/activity/main.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginActivityState();
  }
}

class LoginActivityState extends State<LoginActivity> {
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
                      final certificate = Certificate(cookie?.value, result["csrfToken"]);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                        return MainActivity(certificate: certificate);
                      }), (route) => false);
                    });
                  });
                }).catchError((error) {
                  Navigator.pop(context);
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
