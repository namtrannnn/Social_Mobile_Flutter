import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../screens/edit_profile_screen.dart';

class ProfileActionButtons extends StatelessWidget {
  final ProfileModel profile;

  const ProfileActionButtons({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isMe = profile.relation.isMe;
    final isFollowing = profile.relation.isFollowing;
    final isFriend = profile.relation.isFriend;

    if (isMe) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: _ProfileButton(
                text: 'Edit profile',
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
            const SizedBox(width: 6),
            Expanded(
              child: _ProfileButton(text: 'Share profile', onTap: () {}),
            ),
            const SizedBox(width: 6),
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1_outlined, size: 18),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _ProfileButton(
              text: isFollowing ? 'Following' : 'Follow',
              backgroundColor: isFollowing ? Colors.grey.shade100 : Colors.blue,
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              onTap: () {
                // TODO: call follow/unfollow API sau
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ProfileButton(text: 'Message', onTap: () {}),
          ),
          const SizedBox(width: 6),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isFriend
                  ? Icons.person_remove_alt_1_outlined
                  : Icons.person_add_alt_1_outlined,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _ProfileButton({
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: backgroundColor ?? Colors.grey.shade100,
          foregroundColor: foregroundColor ?? Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
