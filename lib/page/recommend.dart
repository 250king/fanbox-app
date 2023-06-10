import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fanbox/component/card/recommend.dart';
import 'package:fanbox/component/list/nothing.dart';
import 'package:fanbox/component/client.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return RecommendPageState();
  }
}

class RecommendPageState extends State<RecommendPage> {
  final data = [];

  bool loading = true;

  late Dio client;

  void insert(items) {
    for (var i in items) {
      data.add({
        "name": i["user"]["name"],
        "screen_name": i["creatorId"],
        "avatar": i["user"]["iconUrl"] ?? "",
        "banner": i["coverImageUrl"] ?? "",
        "describe": i["description"] ?? ""
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((storage) {
      var accessToken = storage.getString("access_token") ?? "";
      var csrfToken = storage.getString("csrf_token") ?? "";
      client = Client.init(accessToken, csrfToken);
      client.get("/creator.listRecommended").then((response) {
        var result = response.data["body"];
        data.clear();
        insert(result);
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
        var response = await client.get("/creator.listRecommended");
        var result = response.data["body"];
        data.clear();
        insert(result);
        setState(() {});
      },
      child: ListView.builder(
        itemCount: data.length + 1,
        itemBuilder: (context, index) {
          if (index == data.length) {
            return const Nothing();
          }
          else {
            return PainterCard(
              name: data[index]["name"],
              screenName: data[index]["screen_name"],
              avatar: data[index]["avatar"],
              banner: data[index]["banner"],
              describe: data[index]["describe"]
            );
          }
        }
      )
    );
  }
}
