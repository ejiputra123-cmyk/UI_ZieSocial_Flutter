// ziesocial/flutter/ziesocial/lib/viewmodel/profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/model/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  ProfileViewModel(this._apiClient);

  // State profil user yang sedang login
  UserModel? _profileUser;
  List<PostModel> _userPosts = [];

  // State profil akun lain yang sedang dikunjungi
  UserModel? _viewedUser;
  List<PostModel> _viewedUserPosts = [];

  // State daftar akun pada tab Search
  List<UserModel> _discoveredUsers = [];
  bool _isLoadingUsers = false;

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isFollowLoading = false;
  String? _errorMessage;

  UserModel? get profileUser => _profileUser;
  List<PostModel> get userPosts => _userPosts;

  UserModel? get viewedUser => _viewedUser;
  List<PostModel> get viewedUserPosts => _viewedUserPosts;

  List<UserModel> get discoveredUsers => _discoveredUsers;
  bool get isLoadingUsers => _isLoadingUsers;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isFollowLoading => _isFollowLoading;
  String? get errorMessage => _errorMessage;

  // Memuat profil sendiri
  Future<void> fetchProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readProfile}?user_id=$userId&viewer_id=$userId',
      );

      if (response['user'] != null) {
        _profileUser = UserModel.fromJson(response['user']);
      }

      final List<dynamic> postsData = response['posts'] ?? [];
      _userPosts = postsData.map((item) => PostModel.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Memuat profil akun lain
  Future<void> fetchOtherUserProfile({
    required int targetUserId,
    required int viewerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readProfile}?user_id=$targetUserId&viewer_id=$viewerId',
      );

      if (response['user'] != null) {
        _viewedUser = UserModel.fromJson(response['user']);
      }

      final List<dynamic> postsData = response['posts'] ?? [];
      _viewedUserPosts = postsData
          .map((item) => PostModel.fromJson(item))
          .toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sinkronisasi status like pada postingan di halaman Profile
  void syncLikeStatus(int postId, String status) {
    bool changed = false;

    void updateList(List<PostModel> list) {
      for (final post in list) {
        if (post.id == postId) {
          if (status == 'liked' && !post.isLiked) {
            post.isLiked = true;
            post.likesCount += 1;
            changed = true;
          } else if (status == 'unliked' && post.isLiked) {
            post.isLiked = false;
            if (post.likesCount > 0) {
              post.likesCount -= 1;
            }
            changed = true;
          }
        }
      }
    }

    updateList(_userPosts);
    updateList(_viewedUserPosts);

    if (changed) {
      notifyListeners();
    }
  }

  // Toggle Follow / Unfollow Akun
  Future<bool?> toggleFollow({
    required int followerId,
    required int followingId,
  }) async {
    if (followerId == followingId) return null;

    _isFollowLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.toggleFollow,
        body: {'follower_id': followerId, 'following_id': followingId},
      );

      final bool isFollowed = response['is_followed'] == true;
      final int targetFollowersCount = response['followers_count'] is int
          ? response['followers_count']
          : int.tryParse(response['followers_count']?.toString() ?? '0') ?? 0;
      final int myFollowingCount = response['my_following_count'] is int
          ? response['my_following_count']
          : int.tryParse(response['my_following_count']?.toString() ?? '0') ??
                0;

      // 1. Update jumlah following pada profil sendiri
      if (_profileUser != null && _profileUser!.id == followerId.toString()) {
        _profileUser = _profileUser!.copyWith(followingCount: myFollowingCount);
      }

      // 2. Update status & jumlah followers pada profil akun yang sedang dilihat
      if (_viewedUser != null && _viewedUser!.id == followingId.toString()) {
        _viewedUser = _viewedUser!.copyWith(
          isFollowed: isFollowed,
          followersCount: targetFollowersCount,
        );
      }

      for (final post in _viewedUserPosts) {
        if (post.userId == followingId) {
          post.isAuthorFollowed = isFollowed;
        }
      }

      // 3. Update pada daftar pencarian user
      final idx = _discoveredUsers.indexWhere(
        (u) => u.id == followingId.toString(),
      );
      if (idx != -1) {
        _discoveredUsers[idx] = _discoveredUsers[idx].copyWith(
          isFollowed: isFollowed,
          followersCount: targetFollowersCount,
        );
      }

      return isFollowed;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isFollowLoading = false;
      notifyListeners();
    }
  }

  // Memuat daftar akun / mencari akun untuk di-follow
  Future<void> fetchUsers({
    required int currentUserId,
    String search = '',
  }) async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final encodedSearch = Uri.encodeQueryComponent(search.trim());
      final response = await _apiClient.get(
        '${ApiConstants.readUsers}?current_user_id=$currentUserId&search=$encodedSearch',
      );

      final List<dynamic> data = response['data'] ?? [];
      _discoveredUsers = data.map((item) => UserModel.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<UserModel?> updateProfile({
    required int userId,
    required String name,
    required String username,
    String? bio,
    String? avatarFilePath,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = <String, String>{
        'user_id': userId.toString(),
        'name': name,
        'username': username,
      };
      if (bio != null) {
        fields['bio'] = bio;
      }

      final response = await _apiClient.uploadOptional(
        ApiConstants.updateProfile,
        filePath: avatarFilePath,
        fieldName: 'avatar',
        fields: fields,
      );

      if (response['user'] != null) {
        final updated = UserModel.fromJson(response['user']);
        _profileUser = (_profileUser ?? updated).copyWith(
          name: updated.name,
          username: updated.username,
          avatar: updated.avatar,
          bio: updated.bio,
        );

        await fetchProfile(userId);
        return _profileUser;
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
