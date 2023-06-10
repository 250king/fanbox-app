import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:fanbox/component/client.dart';
import 'package:fanbox/component/list/nothing.dart';
import 'package:fanbox/component/list/more.dart';
import 'package:fanbox/component/card/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final data = [];

  final controller = ScrollController();

  bool lock = false;

  bool loading = true;

  String next = "";

  late Dio client;

  void insert(items) {
    for (var i in items) {
      data.add({
        "name": i["user"]["name"],
        "id": int.parse(i["id"]),
        "avatar": i["user"]["iconUrl"] ?? "",
        "banner": i["cover"] == null? "": i["cover"]["url"],
        "title": i["title"],
        "time": DateTime.parse(i["updatedDatetime"]),
        "price": i["feeRequired"],
        "describe": i["excerpt"] ?? "",
        "liked": i["isLiked"]
      });
    }
  }

  void more() {
    if (controller.position.extentAfter < 500 && !lock && next.isNotEmpty) {
      lock = true;
      client.getUri(Uri.parse(next)).then((response) {
        var result = response.data["body"]["items"];
        insert(result);
        next = response.data["body"]["nextUrl"] ?? "";
        setState(() {});
        lock = false;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(more);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(more);
    SharedPreferences.getInstance().then((storage) {
      var accessToken = storage.getString("access_token") ?? "";
      var csrfToken = storage.getString("csrf_token") ?? "";
      client = Client.init(accessToken, csrfToken);
      client.get("/post.listHome?limit=10").then((response) {
        var result = response.data["body"]["items"];
        data.clear();
        insert(result);
        next = response.data["body"]["nextUrl"] ?? "";
        setState(() {
          loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading? const Center(
      child: CircularProgressIndicator(),
    ): RefreshIndicator(
      onRefresh: () async {
        var response = await client.get("/post.listHome?limit=10");
        var result = response.data["body"]["items"];
        data.clear();
        insert(result);
        next = response.data["body"]["nextUrl"] ?? "";
        lock = false;
        setState(() {});
      },
      child: ListView.builder(
        itemCount: data.length + 1,
        controller: controller,
        itemBuilder: (context, index) {
          if (index == data.length) {
            if (next.isEmpty) {
              return const Nothing();
            }
            else {
              return const LoadMore();
            }
          }
          else {
            return WorkCard(
              name: data[index]["name"],
              id: data[index]["id"],
              avatar: data[index]["avatar"],
              banner: data[index]["banner"],
              title: data[index]["title"],
              time: data[index]["time"],
              price: data[index]["price"],
              describe: data[index]["describe"],
              liked: data[index]["liked"],
            );
          }
        }
      )
    );
  }
}
