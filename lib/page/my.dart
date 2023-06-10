import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fanbox/activity/welcome.dart';
import 'package:fanbox/component/client.dart';
import 'package:html/parser.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyPageState();
  }
}

class MyPageState extends State<MyPage> {
  late Dio client;

  late String name;

  late String avatar;

  bool loading = true;

  Widget item(name, action) {
    return ListTile(
      title: Text(name),
      onTap: action,
    );
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instant) {
      var accessToken = instant.getString("access_token") ?? "";
      var csrfToken = instant.getString("csrf_token") ?? "";
      client = Client.init(accessToken, csrfToken);
      client.getUri(Uri.parse("https://www.fanbox.cc/")).then((response) {
        var html = parse(response.data);
        var text = html.getElementById("metadata")?.attributes["content"];
        var result = jsonDecode(text!);
        if (result["urlContext"]["user"]["isLoggedIn"]) {
          name = result["context"]["user"]["name"];
          avatar = result["context"]["user"]["iconUrl"] ?? "";
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading? const Center(
      child: CircularProgressIndicator(),
    ): ListView(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12
            ),
            child: Row(
              children: [
                avatar.isEmpty? const CircleAvatar(
                  radius: 45.0,
                  backgroundImage: AssetImage("asset/image/avatar.png"),
                ): CircleAvatar(
                  radius: 45.0,
                  backgroundImage: CachedNetworkImageProvider(avatar),
                ),
                const SizedBox(width: 12),
                Text(name, style: Theme.of(context).textTheme.headlineMedium)
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              item("正在关注的创作者", () { }),
              item("正在赞助的创作者", () { }),
              item("支付记录", () { }),
              const Divider(),
              item("账号设置", () { }),
              item("通知设定", () { }),
              item("退出登录", () {
                client.getUri(Uri.parse("https://www.fanbox.cc/logout"));
                SharedPreferences.getInstance().then((storage) {
                  storage.clear();
                });
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                  return const WelcomeActivity();
                }), (route) => false);
              }),
              const Divider(),
              item("最新消息", () { }),
              item("帮助中心", () { }),
              item("关于", () { })
            ],
          ),
        )
      ],
    );
  }
}
