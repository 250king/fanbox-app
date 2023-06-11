import 'package:flutter/material.dart';

class Unable extends StatelessWidget {
  const Unable({super.key, required this.title, required this.content, required this.backText});

  final String title;

  final String content;

  final String backText;

  static show(BuildContext context, {required String title, required String content, required String backText}) {
    return showDialog(
      context: context,
      builder: (context) {
        return Unable(title: title, content: content, backText: backText);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(backText)
          )
        ]
    );
  }
}
