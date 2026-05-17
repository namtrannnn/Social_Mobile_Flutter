import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';

class ProfileBioSection extends StatelessWidget {
  final ProfileModel profile;

  const ProfileBioSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final user = profile.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.bio,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],

          if (user.isPrivate) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 15, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Tài khoản riêng tư',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
