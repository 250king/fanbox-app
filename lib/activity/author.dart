import 'package:flutter/material.dart';

class AuthorActivity extends StatefulWidget {
  const AuthorActivity({super.key, required this.id});

  final int id;

  @override
  State<StatefulWidget> createState() {
    return WorkActivityState();
  }
}

class WorkActivityState extends State<AuthorActivity> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return loading? const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ): Scaffold(
      appBar: AppBar(),
      body: Text(widget.id.toString()),
    );
  }
}
