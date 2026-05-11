import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ListTile(
          leading: Icon(Icons.email),
          title: Text("Email"),
          subtitle: Text("hoai@gmail.com"),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text("Số điện thoại"),
          subtitle: Text("0123456789"),
        ),
      ],
    );
  }
}
