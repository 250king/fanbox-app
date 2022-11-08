import 'package:flutter/material.dart';

class Unable {
  static show(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("此区域暂不开放"),
          content: const Text("我们现在已经加快马鞭，尽快完善更多功能。\n如果你有能力且愿意的话，可以去项目主页申请来协助我们开发😊"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("返回")
            )
          ]
        );
      }
    );
  }
}
