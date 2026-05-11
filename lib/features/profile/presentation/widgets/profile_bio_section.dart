import 'package:flutter/material.dart';

class ProfileBioSection extends StatelessWidget {
  const ProfileBioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Le Thanh Hoai',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mobile Developer',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Code, coffee và một chút chill ☕\nFlutter UI practice giống Instagram.',
            style: TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 4),
          Text(
            'github.com/lethanhhoai',
            style: TextStyle(
              color: Color(0xFF00376B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
