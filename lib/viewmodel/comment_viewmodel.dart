import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/comment_model.dart';

class CommentViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  CommentViewModel(this._apiClient);

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Memuat daftar komentar untuk postingan tertentu
  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readComments}?post_id=$postId',
      );
      final List<dynamic> data = response['data'] ?? [];
      _comments = data.map((item) => CommentModel.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan komentar baru
  Future<bool> addComment({
    required int postId,
    required int userId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.post(
        ApiConstants.createComment,
        body: {
          'post_id': postId,
          'user_id': userId,
          'text': text.trim(),
        },
      );

      // Refresh list komentar agar sinkron dengan server
      await fetchComments(postId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Mengedit komentar milik user sendiri
  Future<bool> editComment({
    required int commentId,
    required int userId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.post(
        ApiConstants.updateComment,
        body: {
          'id': commentId,
          'user_id': userId,
          'text': text.trim(),
        },
      );

      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index].text = text.trim();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Menghapus komentar milik user sendiri
  Future<bool> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.post(
        ApiConstants.deleteComment,
        body: {
          'id': commentId,
          'user_id': userId,
        },
      );

      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clear() {
    _comments = [];
    _isLoading = false;
    _isSubmitting = false;
    _errorMessage = null;
  }
}
