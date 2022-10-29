import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkCard extends StatelessWidget {
  const WorkCard({
    super.key,
    required this.name,
    required this.avatar,
    required this.banner,
    required this.title,
    required this.time,
    required this.price,
    required this.describe,
    required this.access
  });

  final String name;

  final String avatar;

  final String banner;

  final String title;

  final DateTime time;

  final int price;

  final String describe;

  final bool access;

  @override
  Widget build(context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              child: banner.isEmpty? const Center(
                child: Icon(Icons.lock),
              ): CachedNetworkImage(
                imageUrl: banner,
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
                },
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark? const Color.fromARGB(255, 124, 124, 124): const Color.fromARGB(255, 211, 209, 209),
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              ),
              child: Text(price == 0? "对所有人公开": "￥$price",
                style: const TextStyle(
                  fontSize: 10
                )
              ),
            ),
            title: Text(name),
            subtitle: Text(formatDate(time, [yyyy, '年', mm, '月', dd, "日 ", HH, ':', nn],
              locale: const SimplifiedChineseDateLocale()
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8
            ),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18
              ),
            )
          ),
          access? Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(describe)
                )
              ],
            )
          ): Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark? const Color.fromARGB(255, 124, 124, 124): const Color.fromARGB(255, 211, 209, 209),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.lock),
                const SizedBox(width: 3),
                Flexible(
                  child: Text("赞助月费高于￥$price即可浏览", maxLines: 2, overflow: TextOverflow.ellipsis)
                ),
                Container(
                  padding: const EdgeInsets.only(right: 1),
                  child: ElevatedButton(
                    onPressed: () {  },
                    child: const Text("方案列表"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
