import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/post_model.dart';

class PostViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  PostViewModel(this._apiClient);

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Memuat postingan dari server
  Future<void> fetchPosts({int? currentUserId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String url = ApiConstants.readPosts;
      if (currentUserId != null) {
        url += '?user_id=$currentUserId';
      }

      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'] ?? [];

      _posts = data.map((item) => PostModel.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle like ke API
  Future<bool> toggleLike({required int postId, required int userId}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.toggleLike,
        body: {'user_id': userId, 'post_id': postId},
      );

      final String status = response['status'] ?? '';
      final postIndex = _posts.indexWhere((p) => p.id == postId);

      if (postIndex != -1) {
        if (status == 'liked') {
          _posts[postIndex].isLiked = true;
          _posts[postIndex].likesCount += 1;
        } else if (status == 'unliked') {
          _posts[postIndex].isLiked = false;
          _posts[postIndex].likesCount -= 1;
        }
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void incrementCommentCount(int postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].commentsCount += 1;
      notifyListeners();
    }
  }

  void decrementCommentCount(int postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1 && _posts[postIndex].commentsCount > 0) {
      _posts[postIndex].commentsCount -= 1;
      notifyListeners();
    }
  }
}
