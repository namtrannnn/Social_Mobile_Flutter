import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/post_like_user_model.dart';

class LikedUsersBottomSheet extends StatefulWidget {
  final String postId;

  const LikedUsersBottomSheet({super.key, required this.postId});

  @override
  State<LikedUsersBottomSheet> createState() => _LikedUsersBottomSheetState();
}

class _LikedUsersBottomSheetState extends State<LikedUsersBottomSheet> {
  final PostRemoteDataSource _postRemoteDataSource = PostRemoteDataSource();
  final TextEditingController _searchController = TextEditingController();

  final List<PostLikeUserModel> _users = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _page = 1;
  final int _limit = 20;

  String _search = '';
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadLikedUsers(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadLikedUsers({required bool isRefresh}) async {
    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
          _error = 'Bạn cần đăng nhập lại';
        });
        return;
      }

      if (isRefresh) {
        setState(() {
          _isLoading = true;
          _error = null;
          _page = 1;
          _hasMore = true;
          _users.clear();
        });
      }

      final result = await _postRemoteDataSource.getUsersLikedPost(
        token: token,
        postId: widget.postId,
        page: _page,
        limit: _limit,
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _users.addAll(result.users);
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreLikedUsers() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _page++;
    });

    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      final result = await _postRemoteDataSource.getUsersLikedPost(
        token: token,
        postId: widget.postId,
        page: _page,
        limit: _limit,
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _users.addAll(result.users);
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _page--;
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search = value.trim();
      _loadLikedUsers(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),

                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),

                      const Expanded(
                        child: Text(
                          'Lượt thích',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm người dùng',
                      prefixIcon: const Icon(Icons.search, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.close, size: 20),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 260) {
                        _loadMoreLikedUsers();
                      }

                      return false;
                    },
                    child: _buildBody(scrollController),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      );
    }

    if (_error != null && _users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty
              ? 'Chưa có ai thích bài viết này'
              : 'Không tìm thấy người dùng',
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 600,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _users.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
        });

        // LOADING MORE ITEM
        if (index >= _users.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          );
        }

        final item = _users[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFF1F1F1),
              backgroundImage: item.avatar.isNotEmpty
                  ? NetworkImage(item.avatar)
                  : null,
              child: item.avatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    item.fullName.isNotEmpty ? item.fullName : 'Người dùng',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                if (item.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ],
            ),
            subtitle: item.username.isNotEmpty
                ? Text(
                    '@${item.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  )
                : null,
          ),
        );
      },
    );
  }
}
