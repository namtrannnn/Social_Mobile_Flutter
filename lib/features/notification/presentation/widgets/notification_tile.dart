import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String text;

  const NotificationTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFE2D7),
            child: Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFFF25019),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5))),
        ],
      ),
    );
  }
}
