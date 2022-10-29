import 'package:flutter/material.dart';
import 'package:fanbox/activity/login.dart';

class WelcomeActivity extends StatefulWidget {
  const WelcomeActivity({super.key});

  @override
  State<WelcomeActivity> createState() => WelcomeActivityState();
}

class WelcomeActivityState extends State<WelcomeActivity> {
  bool disabled = false;

  void setButton() {
    setState(() {
      disabled = !disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: disabled? null: () async {
                setButton();
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const LoginPage();
                  })
                ).then((callback) {
                  if (callback == "NETWORK") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("登录失败，请检查网络后再试！")
                    ));
                    setButton();
                  }
                  else {
                    setButton();
                  }
                });
              },
              child: const Text("登录"),
            )
          ]
        )
      ),
    );
  }
}
