// ziesocial/flutter/ziesocial/lib/viewmodel/chat_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  Timer? _pollingTimer;

  ChatViewModel(this._apiClient);

  List<ChatInboxModel> _inboxList = [];
  List<ChatMessageModel> _roomMessages = [];
  bool _isLoadingInbox = false;
  bool _isLoadingRoom = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatInboxModel> get inboxList => _inboxList;
  List<ChatMessageModel> get roomMessages => _roomMessages;
  bool get isLoadingInbox => _isLoadingInbox;
  bool get isLoadingRoom => _isLoadingRoom;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // --- Inbox ---
  Future<void> fetchInbox(int userId) async {
    _isLoadingInbox = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readInbox}?user_id=$userId',
      );
      final List<dynamic> data = response['data'] ?? [];
      _inboxList = data.map((item) => ChatInboxModel.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingInbox = false;
      notifyListeners();
    }
  }

  // --- Room Chat ---
  Future<void> fetchRoomMessages({
    required int senderId,
    required int receiverId,
    bool isInitial = true,
  }) async {
    if (isInitial) {
      _isLoadingRoom = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readMessages}?sender_id=$senderId&receiver_id=$receiverId',
      );
      final List<dynamic> data = response['data'] ?? [];
      _roomMessages = data
          .map((item) => ChatMessageModel.fromJson(item))
          .toList();
    } catch (e) {
      if (isInitial) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (isInitial) {
        _isLoadingRoom = false;
      }
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;

    _isSending = true;
    notifyListeners();

    try {
      await _apiClient.post(
        ApiConstants.createMessage,
        body: {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'text': text.trim(),
        },
      );

      // Langsung refresh chat room
      await fetchRoomMessages(
        senderId: senderId,
        receiverId: receiverId,
        isInitial: false,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // --- Real-time Polling Logic ---
  void startPollingRoom(int senderId, int receiverId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchRoomMessages(
        senderId: senderId,
        receiverId: receiverId,
        isInitial: false,
      );
    });
  }

  void startPollingInbox(int userId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Fetch inbox secara senyap tanpa merubah status loading awal
      _apiClient
          .get('${ApiConstants.readInbox}?user_id=$userId')
          .then((res) {
            final List<dynamic> data = res['data'] ?? [];
            _inboxList = data
                .map((item) => ChatInboxModel.fromJson(item))
                .toList();
            notifyListeners();
          })
          .catchError((_) {});
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
