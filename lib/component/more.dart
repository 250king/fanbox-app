import 'package:flutter/material.dart';

class LoadMore extends StatelessWidget {
  const LoadMore({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Center(
        child: SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          )
        )
      )
    );
  }
}
