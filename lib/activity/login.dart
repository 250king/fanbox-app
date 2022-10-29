import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as dio_cookie;
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  double loading = 0.0;

  bool loaded = false;

  final client = Dio();

  final cookie = CookieJar();

  @override
  void initState() {
    super.initState();
    client.interceptors.add(dio_cookie.CookieManager(cookie));
    client.httpClientAdapter = Http2Adapter(ConnectionManager());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 0),
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
        onWebViewCreated: (controller) {
          client.get("https://www.fanbox.cc/").then((response) {
            cookie.loadForRequest(Uri.parse("https://www.fanbox.cc/")).then((cookies) {
              for (var i in cookies) {
                if (i.name == "FANBOXSESSID") {
                  CookieManager.instance().setCookie(
                    url: Uri.parse("https://www.fanbox.cc/"),
                    name: "FANBOXSESSID",
                    value: i.value,
                    domain: ".fanbox.cc",
                    path: "/"
                  ).then((value) {
                    controller.loadUrl(
                      urlRequest: URLRequest(
                        url: Uri.parse("https://www.fanbox.cc/auth/start")
                      )
                    );
                  });
                  break;
                }
              }
            });
          }).onError((error, stackTrace) {
            Navigator.pop(context, "NETWORK");
          });
        },
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
          if (url?.path == "/auth/callback") {
            client.get(url.toString(), options: Options(
              followRedirects: true,
              validateStatus: (status) {
                return status! < 400;
              }
            )).then((response) {
              cookie.loadForRequest(Uri.parse("https://www.fanbox.cc/")).then((cookies) {
                for (var i in cookies) {
                  if (i.name == "FANBOXSESSID") {
                    SharedPreferences.getInstance().then((storage) {
                      storage.setString("token", i.value).then((value) {
                        Navigator.pushNamedAndRemoveUntil(context, "/logon", (route) => false);
                      });
                    });
                    break;
                  }
                }
              });
            }).onError((error, stackTrace) {
              Navigator.pop(context, "NETWORK");
            });
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      )
    );
  }
}
