import 'package:flutter/material.dart';
import 'story_item.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        children: const [
          StoryItem(name: "Your story", isMe: true),
          StoryItem(name: "emiudth_vl"),
          StoryItem(name: "34kim_rose"),
          StoryItem(name: "m.cong1907"),
          StoryItem(name: "user_8"),
        ],
      ),
    );
  }
}
