import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

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
      actions: const [
        Icon(Icons.add_box_outlined, color: Colors.black),
        SizedBox(width: 16),
        Icon(Icons.menu, color: Colors.black),
        SizedBox(width: 12),
      ],
    );
  }
}
