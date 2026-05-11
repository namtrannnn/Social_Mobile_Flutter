import 'package:flutter/material.dart';

class ProfileHighlights extends StatelessWidget {
  final List<String> highlightTitles;

  const ProfileHighlights({super.key, required this.highlightTitles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: highlightTitles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == highlightTitles.length) {
            return const _NewHighlightItem();
          }

          return _HighlightItem(title: highlightTitles[index]);
        },
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final String title;

  const _HighlightItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=20'),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _NewHighlightItem extends StatelessWidget {
  const _NewHighlightItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.black),
        ),
        const SizedBox(height: 6),
        const SizedBox(
          width: 72,
          child: Text(
            'New',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
