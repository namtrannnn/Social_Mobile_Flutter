import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../screens/edit_profile_screen.dart';
import '../../../friend/presentation/widgets/friend_action_button.dart';

class ProfileActionButtons extends StatelessWidget {
  final ProfileModel profile;

  const ProfileActionButtons({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isMe = profile.relation.isMe;

    if (isMe) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: _ProfileButton(
                text: 'Sửa hồ sơ',
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: profile),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            _SquareProfileButton(
              icon: Icons.person_add_alt_1_outlined,
              onTap: () {
                // TODO: mở màn chia sẻ / mời bạn bè nếu cần
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: FriendActionButton(
                userId: profile.user.id,
                initialStatus: profile.relation.relationStatus,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _ProfileButton(
              text: 'Nhắn tin',
              icon: Icons.chat_bubble_outline_rounded,
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              borderColor: const Color(0xFF111111),
              onTap: () {
                // TODO: chuyển sang màn chat với user này
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const _ProfileButton({
    required this.text,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFFF5F5F5);
    final fgColor = foregroundColor ?? const Color(0xFF1C1C1C);
    final brColor = borderColor ?? const Color(0xFFE0E0E0);

    return SizedBox(
      height: 38,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fgColor),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareProfileButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareProfileButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF1C1C1C)),
          ),
        ),
      ),
    );
  }
}
