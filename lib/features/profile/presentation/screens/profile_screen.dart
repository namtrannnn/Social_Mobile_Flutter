import 'package:flutter/material.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_top_section.dart';
import '../widgets/profile_bio_section.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_highlights.dart';
import '../widgets/profile_tab_section.dart';
import '../widgets/profile_post_grid.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> postImages = [
      'https://picsum.photos/id/1011/300/300',
      'https://picsum.photos/id/1012/300/300',
      'https://picsum.photos/id/1013/300/300',
      'https://picsum.photos/id/1015/300/300',
      'https://picsum.photos/id/1016/300/300',
      'https://picsum.photos/id/1018/300/300',
      'https://picsum.photos/id/1020/300/300',
      'https://picsum.photos/id/1024/300/300',
      'https://picsum.photos/id/1025/300/300',
    ];

    final List<String> highlightTitles = [
      'Trips',
      'Food',
      'Life',
      'Work',
      'Mood',
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ProfileAppBar(),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileTopSection(),
                    const ProfileBioSection(),
                    const ProfileActionButtons(),
                    ProfileHighlights(highlightTitles: highlightTitles),
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
              ProfilePostGrid(postImages: postImages),
              const Center(child: Text('Chưa có reels')),
              const Center(child: Text('Chưa có ảnh được gắn thẻ')),
            ],
          ),
        ),
      ),
    );
  }
}
