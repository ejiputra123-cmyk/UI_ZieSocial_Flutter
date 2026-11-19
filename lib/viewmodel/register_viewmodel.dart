import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  RegisterViewModel(this._apiClient);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _createdUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get createdUser => _createdUser;

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    String? avatarFilePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _createdUser = null;

    notifyListeners();

    try {
      final Map<String, dynamic> response;

      if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
        response = await _apiClient.uploadOptional(
          ApiConstants.register,
          filePath: avatarFilePath,
          fieldName: 'avatar',
          fields: {
            'name': name,
            'username': username,
            'email': email,
            'password': password,
          },
        );
      } else {
        response = await _apiClient.post(
          ApiConstants.register,
          body: {
            'name': name,
            'username': username,
            'email': email,
            'password': password,
          },
        );
      }

      _successMessage = response['message']?.toString();
      if (response['user'] is Map) {
        _createdUser = UserModel.fromJson(
          Map<String, dynamic>.from(response['user'] as Map),
        );
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
