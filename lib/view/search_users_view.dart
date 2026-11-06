// ziesocial/flutter/ziesocial/lib/view/search_users_view.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/view/profile_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';

class SearchUsersView extends StatefulWidget {
  const SearchUsersView({super.key});

  @override
  State<SearchUsersView> createState() => _SearchUsersViewState();
}

class _SearchUsersViewState extends State<SearchUsersView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers([String query = '']) async {
    final currentUser = context.read<LoginViewModel>().user;
    if (currentUser == null) return;
    final userId = int.tryParse(currentUser.id);
    if (userId != null) {
      await context.read<ProfileViewModel>().fetchUsers(
        currentUserId: userId,
        search: query,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<LoginViewModel>().user;
    final profileVM = context.watch<ProfileViewModel>();
    final users = profileVM.discoveredUsers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => _loadUsers(value),
            decoration: InputDecoration(
              hintText: 'Cari nama atau username...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _loadUsers('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: profileVM.isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada pengguna ditemukan.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadUsers(_searchController.text),
                  child: ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final item = users[index];
                      final targetId = int.tryParse(item.id) ?? 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileView(userId: targetId),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            ApiConstants.getImageUrl(item.avatar),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${item.username}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${item.followersCount} Followers',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () async {
                              final myId = int.tryParse(currentUser?.id ?? '');
                              if (myId == null) return;

                              final newStatus = await context
                                  .read<ProfileViewModel>()
                                  .toggleFollow(
                                    followerId: myId,
                                    followingId: targetId,
                                  );

                              if (context.mounted && newStatus != null) {
                                context.read<PostViewModel>().syncFollowStatus(
                                  targetId,
                                  newStatus,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.isFollowed
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFF4F46E5),
                              foregroundColor: item.isFollowed
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              elevation: 0,
                              side: item.isFollowed
                                  ? const BorderSide(color: Color(0xFFD1D5DB))
                                  : BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              item.isFollowed ? 'Following' : 'Follow',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
