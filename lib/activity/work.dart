import 'package:flutter/material.dart';

class WorkActivity extends StatefulWidget {
  const WorkActivity({super.key, required this.id});

  final int id;

  @override
  State<StatefulWidget> createState() {
    return WorkActivityState();
  }
}

class WorkActivityState extends State<WorkActivity> {
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
