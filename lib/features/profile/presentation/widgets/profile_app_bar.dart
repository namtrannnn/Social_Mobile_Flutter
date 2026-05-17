import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../data/models/profile_model.dart';
import '../../../auth/data/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ProfileAppBar extends StatelessWidget {
  final ProfileModel profile;

  const ProfileAppBar({super.key, required this.profile});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthController>().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (route) => false,
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Cài đặt'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _logout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = profile.user.username.isEmpty
        ? 'profile'
        : profile.user.username;

    return AppBar(
      automaticallyImplyLeading: !profile.relation.isMe,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),

      leading: profile.relation.isMe
          ? IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            )
          : null,

      title: Text(
        username,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      centerTitle: true,

      actions: [
        if (profile.relation.isMe)
          IconButton(
            onPressed: () => _showMenu(context),
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
      ],
    );
  }
}
