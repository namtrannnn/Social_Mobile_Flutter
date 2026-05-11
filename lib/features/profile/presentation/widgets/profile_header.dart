import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
        ),
        SizedBox(height: 10),
        Text(
          "Le Thanh Hoai",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
