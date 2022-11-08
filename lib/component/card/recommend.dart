import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PainterCard extends StatelessWidget {
  const PainterCard({
    super.key,
    required this.name,
    required this.screenName,
    required this.avatar,
    required this.banner,
    required this.describe
  });

  final String name;

  final String screenName;

  final String avatar;

  final String banner;

  final String describe;

  @override
  Widget build(context) {
    return Card(
      margin: const EdgeInsets.only(
        right: 12,
        left: 12,
        bottom: 12,
        top: 12
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          banner.isEmpty? const SizedBox(): AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              child: CachedNetworkImage(
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
            leading: avatar.isEmpty? const CircleAvatar(
              backgroundImage: AssetImage("asset/image/avatar.png")
            ): CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
            title: Text(name),
          ),
          describe.isEmpty? const SizedBox(): Padding(
            padding: const EdgeInsets.all(12),
            child: Text(describe.replaceAll("\n", ""), maxLines: 2, overflow: TextOverflow.ellipsis)
          )
        ],
      ),
    );
  }
}
