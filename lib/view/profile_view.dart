// ziesocial/flutter/ziesocial/lib/view/profile_view.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/view/edit_profile_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';
import 'package:ziesocial/widget/post_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final currentUser = context.read<LoginViewModel>().user;
    if (currentUser == null) return;
    final userId = int.tryParse(currentUser.id);
    if (userId != null) {
      await context.read<ProfileViewModel>().fetchProfile(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginUser = context.watch<LoginViewModel>().user;
    final profileVM = context.watch<ProfileViewModel>();
    final displayUser = profileVM.profileUser ?? loginUser;

    if (displayUser == null) {
      return const Center(child: Text('Silakan login terlebih dahulu.'));
    }

    final avatarUrl = ApiConstants.getImageUrl(displayUser.avatar);
    final userPosts = profileVM.userPosts;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile (Avatar + Stats)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  const Gap(24),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          count: userPosts.length.toString(),
                          label: 'Posts',
                        ),
                        _buildStatItem(
                          count: displayUser.followersCount.toString(),
                          label: 'Followers',
                        ),
                        _buildStatItem(
                          count: displayUser.followingCount.toString(),
                          label: 'Following',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nama Lengkap & Username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayUser.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '@${displayUser.username}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(16),

            // Tombol Edit Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileView(user: displayUser),
                      ),
                    );
                    _loadProfile();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const Gap(16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Toggle Tampilan Postingan (Grid / List)
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.grid_on_rounded,
                      color: _isGridView
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF9CA3AF),
                    ),
                    onPressed: () => setState(() => _isGridView = true),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.view_agenda_outlined,
                      color: !_isGridView
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF9CA3AF),
                    ),
                    onPressed: () => setState(() => _isGridView = false),
                  ),
                ),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Daftar Postingan Milik User
            if (profileVM.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (userPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 52,
                        color: Colors.grey[400],
                      ),
                      const Gap(12),
                      const Text(
                        'Belum ada postingan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _isGridView = false);
                    },
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return PostCard(key: ValueKey('prof_${post.id}'), post: post);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String count, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
