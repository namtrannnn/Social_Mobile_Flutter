import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/friend_controller.dart';

class FriendActionButton extends StatefulWidget {
  final String userId;
  final String initialStatus;

  const FriendActionButton({
    super.key,
    required this.userId,
    this.initialStatus = 'none',
  });

  @override
  State<FriendActionButton> createState() => _FriendActionButtonState();
}

class _FriendActionButtonState extends State<FriendActionButton> {
  late String localStatus;

  @override
  void initState() {
    super.initState();
    localStatus = widget.initialStatus;
  }

  @override
  void didUpdateWidget(covariant FriendActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialStatus != widget.initialStatus ||
        oldWidget.userId != widget.userId) {
      localStatus = widget.initialStatus;
    }
  }

  Future<void> _sendRequest(BuildContext context) async {
    await context.read<FriendController>().sendRequest(widget.userId);

    if (!mounted) return;

    setState(() {
      localStatus = 'pending_sent';
    });
  }

  Future<void> _cancelRequest(BuildContext context) async {
    await context.read<FriendController>().cancelRequest(widget.userId);

    if (!mounted) return;

    setState(() {
      localStatus = 'none';
    });
  }

  Future<void> _acceptRequest(BuildContext context) async {
    await context.read<FriendController>().acceptRequest(widget.userId);

    if (!mounted) return;

    setState(() {
      localStatus = 'friend';
    });
  }

  Future<void> _refuseRequest(BuildContext context) async {
    await context.read<FriendController>().refuseRequest(widget.userId);

    if (!mounted) return;

    setState(() {
      localStatus = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendController = context.watch<FriendController>();

    if (localStatus == 'self') {
      return const SizedBox.shrink();
    }

    if (localStatus == 'pending_received') {
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: friendController.isLoading
              ? null
              : () => _showReceivedRequestSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: Colors.blue,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: friendController.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Phản hồi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      );
    }

    String text;
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;
    VoidCallback? onPressed;

    switch (localStatus) {
      case 'friend':
        text = 'Bạn bè';
        backgroundColor = const Color(0xFFF3F4F6);
        foregroundColor = Colors.black;
        borderSide = const BorderSide(color: Color(0xFFE5E7EB));
        onPressed = () {
          _showFriendOptions(context);
        };
        break;

      case 'pending_sent':
        text = 'Đã gửi';
        backgroundColor = const Color(0xFFF3F4F6);
        foregroundColor = Colors.black;
        borderSide = const BorderSide(color: Color(0xFFE5E7EB));
        onPressed = friendController.isLoading
            ? null
            : () => _showCancelRequestSheet(context);
        break;

      case 'none':
      default:
        text = 'Kết bạn';
        backgroundColor = Colors.blue;
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        onPressed = friendController.isLoading
            ? null
            : () => _sendRequest(context);
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: foregroundColor,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: friendController.isLoading && localStatus == 'none'
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showCancelRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lời mời kết bạn đã được gửi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bạn có thể hủy lời mời nếu không muốn chờ phản hồi nữa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelRequest(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hủy lời mời',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReceivedRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Phản hồi lời mời kết bạn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Người này đã gửi lời mời kết bạn cho bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _acceptRequest(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Chấp nhận',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _refuseRequest(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'Từ chối',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFriendOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn bè',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: Colors.blue),
                  title: const Text(
                    'Đã là bạn bè',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Hai bạn có thể nhắn tin với nhau'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_remove_alt_1_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Hủy kết bạn',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chức năng hủy kết bạn sẽ làm sau'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
