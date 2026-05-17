import 'package:flutter/material.dart';

// import '../../../notification/presentation/widgets/notification_sheet.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showNotification;

  const AppHeader({
    super.key,
    required this.title,
    this.showNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          // if (showNotification)
          //   IconButton(
          //     onPressed: () {
          //       showModalBottomSheet(
          //         context: context,
          //         backgroundColor: Colors.white,
          //         shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.vertical(
          //             top: Radius.circular(24),
          //           ),
          //         ),
          //         // builder: (_) => const NotificationSheet(),
          //       );
          //     },
          //     icon: const Icon(Icons.favorite_border_rounded),
          //   ),
        ],
      ),
    );
  }
}
