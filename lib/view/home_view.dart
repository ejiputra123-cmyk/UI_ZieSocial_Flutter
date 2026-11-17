// ziesocial/flutter/ziesocial/lib/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/view/create_post_view.dart';
import 'package:ziesocial/view/inbox_view.dart';
import 'package:ziesocial/view/login_view.dart';
import 'package:ziesocial/view/profile_view.dart';
import 'package:ziesocial/view/search_users_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';
import 'package:ziesocial/widget/post_card.dart';
import 'package:ziesocial/widget/stories_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Design tokens sesuai konfigurasi Tailwind pada HTML
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _onSurfaceVariant = Color(0xFF474554);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _primaryFixed = Color(0xFFE4DFFF);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _error = Color(0xFFBA1A1A);

  static const String _brandLogoUrl =
      'https://lh3.googleusercontent.com/aida/ALJJyrAfMs2ItwwCkd5S8GKnTKuYjyXKj8uj6XczHo5Kkahl1P0R2pCUqhdIyBuBiUKT0MAjFiZVsByNRJTFtlf7FuouANoUWjcAeNwiF9hxaWgN-0B81jMz39JlOwWlxmNMUSmZsj1llNc0BrxSoFljE0s7zrcnmc9D9QNWoNVIcmcTMssBiMeN3cg27oQvhb4wKfEzKaWwoH-z6RCVc3_5Win7EN8-OpOoPS5z6Ld-Iy7wmg';

  static const String _defaultProfileAvatar =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxJLFqSFUQj1bZ0wCvVpASe4ch76eoFLhUnXZ9Rr2lEYnpQOD_B7vrMH755u2OYfUK6J6d1u_HGAO74JP5v7FBq-NhO_MpVJGAGWuFZXIh-FLlA5n2HUVG8WzLDc8UFfs3tW0e-TFZiF5ffJ2wAf8wX_Cn1-5jxQuVyjEfxYRYdOULwis2IaVlZE-yVoQ_hFH-NHYc4R6hHYBoDVwjliNFscVj72IRmhpqrEPGr4fE';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  Future<void> _loadPosts() async {
    final user = context.read<LoginViewModel>().user;
    final userId = user != null ? int.tryParse(user.id) : null;
    await context.read<PostViewModel>().fetchPosts(currentUserId: userId);
    if (userId != null && mounted) {
      await context.read<ProfileViewModel>().fetchProfile(userId);
    }
  }

  void _logout(BuildContext context) {
    context.read<LoginViewModel>().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> _openCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostView()),
    );
    if (mounted) {
      _loadPosts();
    }
  }

  Widget _buildHeader(String userAvatar) {
    return Container(
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Name
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 0),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _brandLogoUrl,
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'z',
                                  style: TextStyle(
                                    color: _onPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ziesocial',
                        style: TextStyle(
                          fontSize: 18,
                          height: 24 / 18,
                          letterSpacing: -0.27,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Header Right Actions
                Row(
                  children: [
                    // Activity / Notifications Button
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 24,
                              color: _onSurface,
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _surface,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Direct Messages Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InboxView(),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.send_outlined,
                          size: 22,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // User Profile Avatar (with Profile & Logout menu)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          tooltip: 'Menu Akun',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'profile') {
                              setState(() => _currentIndex = 3);
                            } else if (value == 'logout') {
                              _logout(context);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 20,
                                    color: _onSurface,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Profile',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: _error,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: _surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                userAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: _secondary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatchUpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 22,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catch up on friends',
                        style: TextStyle(
                          fontSize: 15,
                          height: 20 / 15,
                          letterSpacing: -0.15,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "You're all caught up for this morning!",
                        style: TextStyle(
                          fontSize: 13,
                          height: 18 / 13,
                          fontWeight: FontWeight.w400,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: _surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => setState(() => _currentIndex = 1),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: const Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    letterSpacing: 0.12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeFeed(PostViewModel postViewModel) {
    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadPosts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Stories Tray
            const StoriesSection(),

            // Feed Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (postViewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: _primary),
                    )
                  else if (postViewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Text(
                            postViewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _error),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadPosts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryContainer,
                              foregroundColor: _onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (postViewModel.posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Belum ada postingan.',
                        style: TextStyle(color: _secondary),
                      ),
                    )
                  else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: postViewModel.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final post = postViewModel.posts[index];
                        return PostCard(key: ValueKey(post.id), post: post);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Community Delight Teaser Card
                  _buildCatchUpCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed(PostViewModel postViewModel) {
    final likedPosts = postViewModel.posts.where((p) => p.isLiked).toList();

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadPosts,
      child: likedPosts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: _primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.favorite_outline,
                    size: 28,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Activity Feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Posts you like and recent interactions will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondary,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: likedPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final post = likedPosts[index];
                return PostCard(
                  key: ValueKey('act_${post.id}'),
                  post: post,
                );
              },
            ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? _primaryContainer : _onSurfaceVariant;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 26,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                height: 14 / 11,
                letterSpacing: 0.22,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginViewModel>().user;
    final userAvatar = (user != null && user.avatar.isNotEmpty)
        ? ApiConstants.getImageUrl(user.avatar)
        : _defaultProfileAvatar;
    final postViewModel = context.watch<PostViewModel>();

    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(userAvatar),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeFeed(postViewModel),
                const SearchUsersView(),
                _buildActivityFeed(postViewModel),
                const ProfileView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  _buildBottomNavItem(
                    index: 1,
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: 'Explore',
                  ),
                  // Create Post Center Button
                  GestureDetector(
                    onTap: _openCreatePost,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: _onPrimary,
                      ),
                    ),
                  ),
                  _buildBottomNavItem(
                    index: 2,
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'Activity',
                  ),
                  _buildBottomNavItem(
                    index: 3,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

