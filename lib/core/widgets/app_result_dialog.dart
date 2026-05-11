import 'package:flutter/material.dart';

enum AppResultType { success, error, warning }

class AppResultDialog extends StatelessWidget {
  final AppResultType type;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppResultDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  });

  Color get color {
    switch (type) {
      case AppResultType.success:
        return const Color(0xFF22C55E);
      case AppResultType.error:
        return const Color(0xFFEF4444);
      case AppResultType.warning:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get icon {
    switch (type) {
      case AppResultType.success:
        return Icons.check_circle_rounded;
      case AppResultType.error:
        return Icons.error_rounded;
      case AppResultType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 64),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
