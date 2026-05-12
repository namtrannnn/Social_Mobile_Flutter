import 'package:flutter/material.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: child),

        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),

                    if (message != null) ...[
                      const SizedBox(height: 16),

                      Text(
                        message!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
