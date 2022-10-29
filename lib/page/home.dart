import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:fanbox/component/card/work.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final data = [];

  final client = Dio();

  bool loading = true;

  String next = "";

  Future<void> refresh() async {
    client.get("/post.listHome?limit=10").then((response) {
      var result = response.data["body"]["items"];
      data.clear();
      for (var i in result) {
        data.add({
          "name": i["user"]["name"],
          "avatar": i["user"]["iconUrl"],
          "banner": i["cover"] == null? "": i["cover"]["url"],
          "title": i["title"],
          "time": DateTime.parse(i["updatedDatetime"]),
          "price": i["feeRequired"],
          "describe": i["excerpt"],
          "access": i["feeRequired"] == 0
        });
      }
      next = response.data["body"]["nextUrl"];
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((storage) {
      var token = storage.getString("token") ?? "";
      client.options.baseUrl = "https://api.fanbox.cc";
      client.options.headers = {
        "Origin": "https://www.fanbox.cc",
        "Cookie": "FANBOXSESSID=$token"
      };
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading? const Center(
      child: CircularProgressIndicator(),
    ) :Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12
      ),
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return WorkCard(
              name: data[index]["name"],
              avatar: data[index]["avatar"],
              banner: data[index]["banner"],
              title: data[index]["title"],
              time: data[index]["time"],
              price: data[index]["price"],
              describe: data[index]["describe"],
              access: data[index]["access"]
            );
          }
        ),
      )
    );
  }
}
