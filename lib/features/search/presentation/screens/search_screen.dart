import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/global_search_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../friend/presentation/screens/friend_center_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  static const Color primaryColor = Color(0xFFF25019);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color textColor = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 700), () {
      context.read<GlobalSearchController>().searchUsers(value);
    });
  }

  void _clearSearch() {
    searchController.clear();
    context.read<GlobalSearchController>().clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GlobalSearchController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBox(),
            Expanded(child: _buildBody(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          const Text(
            'Tìm kiếm',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendCenterScreen()),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.group_add_rounded, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: _onChanged,
        cursorColor: primaryColor,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên hoặc username...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _buildBody(GlobalSearchController controller) {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      return _buildEmptyState(
        icon: Icons.manage_search_rounded,
        title: 'Tìm bạn bè của bạn',
        subtitle: 'Nhập tên hoặc username để xem hồ sơ và gửi lời mời kết bạn.',
      );
    }

    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (controller.errorMessage != null) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Có lỗi xảy ra',
        subtitle: controller.errorMessage!,
        iconColor: Colors.redAccent,
      );
    }

    if (controller.users.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_off_rounded,
        title: 'Không tìm thấy người dùng',
        subtitle: 'Thử tìm bằng tên đầy đủ hoặc username khác nha.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      itemCount: controller.users.length,
      itemBuilder: (context, index) {
        final user = controller.users[index];

        return _UserResultCard(
          fullName: user.fullName,
          username: user.username,
          avatar: user.avatar,
          isVerified: user.isVerified,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: user.id)),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: iconColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  final String fullName;
  final String? username;
  final String avatar;
  final bool isVerified;
  final VoidCallback onTap;

  const _UserResultCard({
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFFF25019);
  static const Color textColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final displayUsername = username == null || username!.isEmpty
        ? 'Chưa có username'
        : '@$username';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified_rounded,
                              color: Colors.blue,
                              size: 17,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        displayUsername,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primaryColor,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.9),
            primaryColor.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFEFEFEF),
        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
        child: avatar.isEmpty
            ? const Icon(Icons.person_rounded, color: Colors.grey, size: 30)
            : null,
      ),
    );
  }
}
