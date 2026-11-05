// ziesocial/flutter/ziesocial/lib/viewmodel/profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/model/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  ProfileViewModel(this._apiClient);

  UserModel? _profileUser;
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  UserModel? get profileUser => _profileUser;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readProfile}?user_id=$userId',
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

        // Refresh daftar postingan user agar header kartu ikut diperbarui
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