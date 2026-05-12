import 'package:flutter/material.dart';
import '../../../friend/presentation/screens/friend_screen.dart';
import '../../../chats/presentation/screens/chat_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../notification/presentation/widgets/notification_sheet.dart';
import '../widgets/home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeTab(),
    ChatScreen(),
    _SearchTab(),
    FriendScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFF25019),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: "Bạn bè",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, "Tìm kiếm"),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm bạn bè, bài viết...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: const [
                _SearchCard(title: "Bài viết nổi bật"),
                _SearchCard(title: "Bạn bè mới"),
                _SearchCard(title: "Hashtag xu hướng"),
                _SearchCard(title: "Gợi ý theo dõi"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeader(
  BuildContext context,
  String title, {
  bool showNotification = false,
}) {
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
        if (showNotification)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => const NotificationSheet(),
                    );
                  },
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF25019),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

class _SearchCard extends StatelessWidget {
  final String title;

  const _SearchCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
