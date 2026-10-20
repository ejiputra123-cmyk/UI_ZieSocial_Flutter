import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/view/create_post_view.dart';
import 'package:ziesocial/view/login_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/widget/post_card.dart';
import 'package:ziesocial/widget/stories_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  void _logout(BuildContext context) {
    context.read<LoginViewModel>().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginViewModel>().user;
    final userAvatar = user?.avatar.isNotEmpty == true
        ? user!.avatar
        : 'https://picsum.photos/seed/user/200';

    // Mock data feed postingan sesuai referensi UI
    final List<PostModel> posts = [
      PostModel(
        username: 'wander.lust',
        userAvatar: 'https://picsum.photos/seed/sarah/200',
        location: 'Bali, Indonesia',
        imageUrl: 'https://picsum.photos/seed/bali/600/600',
        likesCount: 125,
        commentsCount: 12,
        caption: 'Exploring paradise in Bali! 🌴✨ #travel #wanderlust',
        timeAgo: '2 HOURS AGO',
      ),
      PostModel(
        username: 'art.flow',
        userAvatar: 'https://picsum.photos/seed/art/200',
        location: 'Paris, France',
        imageUrl: 'https://picsum.photos/seed/paris/600/600',
        likesCount: 342,
        commentsCount: 28,
        caption: 'Art is everywhere if you know where to look. 🎨',
        timeAgo: '5 HOURS AGO',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundImage: NetworkImage(userAvatar)),
        ),
        title: const Text(
          'ZieSocial',
          style: TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF1F2937),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4F46E5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostView()),
              );
            },
            tooltip: 'Buat postingan',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6B7280)),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Story Section (Horizontal Scroll)
            const StoriesSection(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Post Feed (Vertical Scroll)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF6B7280),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
