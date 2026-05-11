import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  final String name;
  final bool isMe;
  final String? imageUrl;

  const StoryItem({
    super.key,
    required this.name,
    this.isMe = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isMe
                      ? null
                      : const LinearGradient(
                          colors: [
                            Color(0xFFFFC107),
                            Color(0xFFFF5722),
                            Color(0xFFE91E63),
                            Color(0xFF9C27B0),
                          ],
                        ),
                  color: isMe ? const Color(0xFFEFEFEF) : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 29,
                    backgroundColor: const Color(0xFFF1F1F1),
                    backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: imageUrl == null || imageUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey, size: 30)
                        : null,
                  ),
                ),
              ),

              if (isMe)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
