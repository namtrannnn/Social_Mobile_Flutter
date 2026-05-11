import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/simple_user_model.dart';
import '../controllers/user_search_controller.dart';

class UserPickerScreen extends StatefulWidget {
  final List<SimpleUserModel> initialSelectedUsers;
  final String title;
  final bool multiple;

  const UserPickerScreen({
    super.key,
    this.initialSelectedUsers = const [],
    this.title = 'Chọn người dùng',
    this.multiple = true,
  });

  @override
  State<UserPickerScreen> createState() => _UserPickerScreenState();
}

class _UserPickerScreenState extends State<UserPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<SimpleUserModel> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _selectedUsers.addAll(widget.initialSelectedUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(SimpleUserModel user) {
    return _selectedUsers.any((item) => item.id == user.id);
  }

  void _toggleUser(SimpleUserModel user) {
    if (!widget.multiple) {
      Navigator.pop(context, [user]);
      return;
    }

    setState(() {
      if (_isSelected(user)) {
        _selectedUsers.removeWhere((item) => item.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _searchUsers(String keyword) async {
    final token = await SecureStorageService.getValidToken();

    if (token == null) return;

    if (!mounted) return;

    context.read<UserSearchController>().searchUsers(
      token: token,
      keyword: keyword,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserSearchController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (widget.multiple)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedUsers);
              },
              child: const Text(
                'Xong',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc username...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (_selectedUsers.isNotEmpty && widget.multiple)
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedUsers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final user = _selectedUsers[index];

                  return Chip(
                    label: Text(user.username),
                    onDeleted: () {
                      setState(() {
                        _selectedUsers.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),

          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.users.isEmpty
                ? const Center(
                    child: Text(
                      'Nhập tên để tìm người dùng',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.users.length,
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      final selected = _isSelected(user);

                      return ListTile(
                        onTap: () => _toggleUser(user),
                        leading: CircleAvatar(
                          backgroundImage: user.avatar.isNotEmpty
                              ? NetworkImage(user.avatar)
                              : null,
                          child: user.avatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (user.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('@${user.username}'),
                        trailing: selected
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : const Icon(Icons.circle_outlined),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
