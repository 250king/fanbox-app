import 'package:flutter/material.dart';

class Nothing extends StatelessWidget {
  const Nothing({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Center(
        child: Icon(Icons.circle, size: 5)
      )
    );
  }
}
