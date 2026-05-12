import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  Future<void> _logout(BuildContext context) async {
    await SecureStorageService.clearAuth();

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
                  onTap: () {
                    Navigator.pop(context);
                  },
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

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,

      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'lethanhhoai',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.black),
        ],
      ),

      centerTitle: false,

      actions: [
        const Icon(Icons.add_box_outlined, color: Colors.black),

        const SizedBox(width: 16),

        GestureDetector(
          onTap: () => _showMenu(context),
          child: const Icon(Icons.menu, color: Colors.black),
        ),

        const SizedBox(width: 12),
      ],
    );
  }
}
