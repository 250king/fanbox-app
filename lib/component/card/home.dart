import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanbox/activity/work.dart';
import 'package:fanbox/component/client.dart';
import 'package:fanbox/component/dialog/unable.dart';
import 'package:dio/dio.dart';

class WorkCard extends StatefulWidget {
  const WorkCard({
    super.key,
    required this.name,
    required this.id,
    required this.avatar,
    required this.banner,
    required this.title,
    required this.time,
    required this.price,
    required this.describe,
    required this.liked
  });

  final String name;

  final int id;

  final String avatar;

  final String banner;

  final String title;

  final DateTime time;

  final int price;

  final String describe;

  final bool liked;

  @override
  State<StatefulWidget> createState() {
    return WorkCardState();
  }
}

class WorkCardState extends State<WorkCard> {
  late bool access;

  late bool liked;

  late Dio client;

  @override
  void initState() {
    super.initState();
    liked = widget.liked;
    access = widget.price == 0 || widget.describe.isNotEmpty || widget.banner.contains("downloads.fanbox.cc");
    SharedPreferences.getInstance().then((storage) {
      var accessToken = storage.getString("access_token") ?? "";
      var csrfToken = storage.getString("csrf_token") ?? "";
      client = Client.init(accessToken, csrfToken);
    });
  }

  @override
  Widget build(context) {
    return Card(
      margin: const EdgeInsets.only(
          right: 12,
          left: 12,
          bottom: 12,
          top: 12
      ),
      child: InkWell(
        onTap: () {
          if (access) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WorkActivity(id: widget.id);
            }));
          }
          else {
            Unable.show(context, title: "提示", content: "此内容需要你赞助创作者后才能看哟~", backText: "我知道了");
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            access? (widget.banner.isEmpty? const SizedBox(): AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: CachedNetworkImage(
                  imageUrl: widget.banner,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  },
                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Icon(Icons.error)
                    );
                  }
                )
              )
            )): AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor
                  ),
                  child: Center(
                    child: Icon(Icons.lock_outlined, color: Theme.of(context).iconTheme.color)
                  ),
                ),
              ),
            ),
            ListTile(
              leading: widget.avatar.isEmpty? const CircleAvatar(
                backgroundImage: AssetImage("asset/image/avatar.png")
              ): CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.avatar),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Text(widget.price == 0? "公开": "￥${widget.price}",
                  style: Theme.of(context).textTheme.labelSmall
                ),
              ),
              title: Text(widget.name),
              subtitle: Text(formatDate(widget.time, [yyyy, '年', mm, '月', dd, "日 ", HH, ':', nn],
                locale: const SimplifiedChineseDateLocale()
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12
              ),
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              )
            ),
            access? (widget.describe.isEmpty? const SizedBox(): Padding(
              padding: const EdgeInsets.all(12),
              child: Text(widget.describe.replaceAll("\n", ""), maxLines: 2, overflow: TextOverflow.ellipsis)
            )): Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.lock),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text("赞助月费高于￥${widget.price}即可浏览")
                  )
                ]
              )
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                bottom: 12,
                right: 12
              ),
              child: access? IconButton(
                onPressed: () {
                  if (!liked) {
                    client.post("/post.likePost", data: jsonEncode({
                      "postId": widget.id.toString()
                    })).then((response) {
                      setState(() {
                        liked = true;
                      });
                    });
                  }
                },
                icon: liked? const Icon(Icons.favorite, color: Colors.red): const Icon(Icons.favorite_border)
              ): const SizedBox(),
            )
          ]
        )
      )
    );
  }
}
