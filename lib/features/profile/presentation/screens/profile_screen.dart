import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_bio_section.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/profile_tab_section.dart';
import '../widgets/profile_top_section.dart';
import '../widgets/profile_friends_section.dart';

import '../../../friend/presentation/controllers/friend_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToGridPosts() {
    _scrollController.animateTo(
      260,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await SecureStorageService.getValidToken();
      if (token == null) return;

      final controller = context.read<ProfileController>();
      controller.clearProfile();

      if (widget.userId == null) {
        await controller.loadMyProfile(token);
      } else {
        await controller.loadUserProfile(token: token, userId: widget.userId!);

        if (!mounted) return;

        await context.read<FriendController>().loadRelationStatus(
          widget.userId!,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        if (controller.isLoadingProfile && controller.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.profile == null) {
          return const Scaffold(
            body: Center(child: Text('Không tải được profile')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,

            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ProfileAppBar(profile: controller.profile!),
            ),

            body: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              notificationPredicate: (_) => true,
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () async {
                final token = await SecureStorageService.getValidToken();
                if (token == null) return;

                if (widget.userId == null) {
                  await controller.loadMyProfile(token);
                } else {
                  await controller.loadUserProfile(
                    token: token,
                    userId: widget.userId!,
                  );

                  if (!context.mounted) return;

                  await context.read<FriendController>().loadRelationStatus(
                    widget.userId!,
                  );
                }
              },
              child: NestedScrollView(
                controller: _scrollController,

                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileTopSection(
                            profile: controller.profile!,
                            onPostsTap: _scrollToGridPosts,
                          ),
                          ProfileBioSection(profile: controller.profile!),
                          ProfileActionButtons(profile: controller.profile!),
                          ProfileFriendsSection(profile: controller.profile!),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: ProfileTabSection(),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    ProfilePostGrid(
                      userId: controller.profile!.user.id,
                      posts: controller.gridPosts,
                    ),
                    const Center(child: Text('Chưa có reels')),
                    const Center(child: Text('Chưa có ảnh được gắn thẻ')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
