import 'dart:io';

import 'package:flutter/material.dart';

import '../../../user/data/models/simple_user_model.dart';
import '../../../user/presentation/screens/user_picker_screen.dart';

class TaggedUserDraft {
  final SimpleUserModel user;
  final double x;
  final double y;

  TaggedUserDraft({required this.user, required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {'user': user.id, 'x': x, 'y': y};
  }
}

class TagUsersScreen extends StatefulWidget {
  final String imagePath;
  final List<TaggedUserDraft> initialTags;

  const TagUsersScreen({
    super.key,
    required this.imagePath,
    this.initialTags = const [],
  });

  @override
  State<TagUsersScreen> createState() => _TagUsersScreenState();
}

class _TagUsersScreenState extends State<TagUsersScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<TaggedUserDraft> _tags = [];

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.initialTags);
  }

  Future<void> _addTag() async {
    final result = await Navigator.push<List<SimpleUserModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => const UserPickerScreen(
          title: 'Chọn người để gắn thẻ',
          multiple: false,
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() {
      _tags.add(TaggedUserDraft(user: result.first, x: 0.5, y: 0.5));
    });
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  void _moveTag(int index, DragUpdateDetails details) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final current = _tags[index];

    final newX = (current.x + details.delta.dx / box.size.width).clamp(
      0.0,
      1.0,
    );
    final newY = (current.y + details.delta.dy / box.size.height).clamp(
      0.0,
      1.0,
    );

    setState(() {
      _tags[index] = TaggedUserDraft(user: current.user, x: newX, y: newY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      key: _canvasKey,
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(widget.imagePath), fit: BoxFit.cover),

                        Container(color: Colors.black.withOpacity(0.05)),

                        for (int index = 0; index < _tags.length; index++)
                          _buildTagItem(index),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomTools(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),

          const Spacer(),

          TextButton(
            onPressed: () {
              Navigator.pop(context, _tags);
            },
            child: const Text(
              'Xong',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagItem(int index) {
    final tag = _tags[index];

    return Positioned(
      left: tag.x * MediaQuery.of(context).size.width * 0.72,
      top: tag.y * MediaQuery.of(context).size.height * 0.56,
      child: GestureDetector(
        onPanUpdate: (details) => _moveTag(index, details),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Text(
                '@${tag.user.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => _removeTag(index),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTools() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
      child: Row(
        children: [
          _toolButton(
            icon: Icons.person_add_alt_1,
            label: 'Tag',
            onTap: _addTag,
          ),
          const SizedBox(width: 12),
          _toolButton(icon: Icons.text_fields, label: 'Text', onTap: () {}),
          const SizedBox(width: 12),
          _toolButton(
            icon: Icons.image_outlined,
            label: 'Overlay',
            onTap: () {},
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _tags);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Xong →',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
