import 'package:flutter/material.dart';
import 'package:fanbox/component/model/certificate.dart';
import 'package:fanbox/page/home.dart';
import 'package:fanbox/page/recommend.dart';
import 'package:fanbox/page/my.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key, required this.certificate});

  final Certificate certificate;

  @override
  State<MainActivity> createState() => MainActivityState();
}

class MainActivityState extends State<MainActivity> {
  int pageIndex = 0;

  final titles = [
    "首页",
    "推荐",
    "我的"
  ];

  final pages = [
    const HomePage(),
    const RecommendPage(),
    const MyPage()
  ];

  changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[pageIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) {
          changePage(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "首页"
          ),
          NavigationDestination(
            icon: Icon(Icons.thumb_up),
            label: "推荐"
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: "我的"
          )
        ],
      ),
      body: pages[pageIndex]// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}