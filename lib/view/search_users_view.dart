// ziesocial/flutter/ziesocial/lib/view/search_users_view.dart
import 'dart:async';
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
  Timer? _debounce;
  final Set<int> _pendingFollowIds = {};

  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceVariant = Color(0xFFE5E2E1);
  static const Color _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _loadUsers(value);
    });
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
    final errorMessage = profileVM.usersErrorMessage;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              _debounce?.cancel();
              _loadUsers(value);
            },
            decoration: InputDecoration(
              hintText: 'Cari nama atau username...',
              hintStyle: const TextStyle(color: _secondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: _secondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                        color: _secondary,
                      ),
                      onPressed: () {
                        _debounce?.cancel();
                        _searchController.clear();
                        setState(() {});
                        _loadUsers('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: _surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (profileVM.isLoadingUsers && users.isNotEmpty)
          const LinearProgressIndicator(
            minHeight: 2,
            color: _primaryContainer,
            backgroundColor: _surfaceVariant,
          )
        else
          const Divider(height: 1, color: _surfaceVariant),
        Expanded(
          child: profileVM.isLoadingUsers && users.isEmpty
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: _error,
                        ),
                        const Gap(10),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _secondary,
                            fontSize: 13,
                          ),
                        ),
                        const Gap(14),
                        ElevatedButton(
                          onPressed: () => _loadUsers(_searchController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryContainer,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : users.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.trim().isEmpty
                        ? 'Belum ada pengguna lain.'
                        : 'Tidak ada pengguna ditemukan untuk "${_searchController.text.trim()}".',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _secondary),
                  ),
                )
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: () => _loadUsers(_searchController.text),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: _surfaceContainerLow),
                    itemBuilder: (context, index) {
                      final item = users[index];
                      final targetId = int.tryParse(item.id) ?? 0;
                      final isBusy = _pendingFollowIds.contains(targetId);

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
                          backgroundColor: _surfaceContainerLow,
                          backgroundImage: NetworkImage(
                            ApiConstants.getImageUrl(item.avatar),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${item.username}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _secondary,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${item.followersCount} Followers',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: isBusy
                                ? null
                                : () async {
                                    final myId = int.tryParse(
                                      currentUser?.id ?? '',
                                    );
                                    if (myId == null) return;

                                    setState(() {
                                      _pendingFollowIds.add(targetId);
                                    });

                                    final newStatus = await context
                                        .read<ProfileViewModel>()
                                        .toggleFollow(
                                          followerId: myId,
                                          followingId: targetId,
                                        );

                                    if (!mounted) return;
                                    setState(() {
                                      _pendingFollowIds.remove(targetId);
                                    });

                                    if (newStatus != null) {
                                      context
                                          .read<PostViewModel>()
                                          .syncFollowStatus(
                                            targetId,
                                            newStatus,
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.isFollowed
                                  ? _surfaceContainerLow
                                  : _primaryContainer,
                              foregroundColor: item.isFollowed
                                  ? _onSurface
                                  : Colors.white,
                              elevation: 0,
                              side: item.isFollowed
                                  ? const BorderSide(color: _surfaceVariant)
                                  : BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              item.isFollowed ? 'Following' : 'Follow',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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

