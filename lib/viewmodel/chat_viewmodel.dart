// ziesocial/flutter/ziesocial/lib/viewmodel/chat_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/core/network.dart';
import 'package:ziesocial/model/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  ChatViewModel(this._apiClient);

  List<ChatInboxModel> _inboxList = [];
  List<ChatMessageModel> _roomMessages = [];
  bool _isLoadingInbox = false;
  bool _isLoadingRoom = false;
  bool _isSending = false;
  bool _isPusherInitialized = false;
  String? _errorMessage;

  int? _currentUserId;
  int? _activeRoomTargetId;

  List<ChatInboxModel> get inboxList => _inboxList;
  List<ChatMessageModel> get roomMessages => _roomMessages;
  bool get isLoadingInbox => _isLoadingInbox;
  bool get isLoadingRoom => _isLoadingRoom;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // --- Pusher Initialization ---
  Future<void> initPusher(int userId) async {
    if (_currentUserId == userId && _isPusherInitialized) return;

    final previousUserId = _currentUserId;
    _currentUserId = userId;

    try {
      if (!_isPusherInitialized) {
        await _pusher.init(
          apiKey: "dbf08c04e11c4ea523bc",
          cluster: "ap1",
          onEvent: _onPusherEvent,
        );
        _isPusherInitialized = true;
      } else if (previousUserId != null && previousUserId != userId) {
        try {
          await _pusher.unsubscribe(channelName: 'chat-$previousUserId');
        } catch (_) {}
      }

      await _pusher.subscribe(channelName: 'chat-$userId');
      await _pusher.connect();
    } catch (e) {
      debugPrint("Pusher Init Error: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName == 'new-message') {
      try {
        if (event.data == null) return;
        final Map<String, dynamic> data = event.data is String
            ? Map<String, dynamic>.from(jsonDecode(event.data as String))
            : Map<String, dynamic>.from(event.data as Map);

        final senderId = int.tryParse(data['sender_id'].toString()) ?? 0;
        final receiverId = int.tryParse(data['receiver_id'].toString()) ?? 0;

        // Cek apakah event ini ditujukan untuk/dari room yang sedang dibuka
        if ((_activeRoomTargetId == senderId ||
                _activeRoomTargetId == receiverId) &&
            _currentUserId != null) {
          final newMessage = ChatMessageModel.fromJson(data);

          final isDuplicate = _roomMessages.any(
            (msg) => msg.id == newMessage.id && newMessage.id != 0,
          );

          if (!isDuplicate) {
            _roomMessages.add(newMessage);
            notifyListeners();
          }

          // Sinkronkan ke database untuk memastikan daftar pesan & status 'is_read'
          fetchRoomMessages(
            senderId: _currentUserId!,
            receiverId: _activeRoomTargetId!,
            isInitial: false,
          );
        }

        // Selalu refresh inbox di background agar pesan terakhir & unread count ter-update
        if (_currentUserId != null) {
          fetchInbox(_currentUserId!, isInitial: false);
        }
      } catch (e) {
        debugPrint("Error parsing Pusher event: $e");
      }
    }
  }

  // Tandai user ID lawan bicara yang sedang terbuka
  void setActiveRoom(int? targetId) {
    _activeRoomTargetId = targetId;
  }

  Future<void> disconnectPusher() async {
    try {
      if (_currentUserId != null) {
        await _pusher.unsubscribe(channelName: 'chat-$_currentUserId');
      }
      await _pusher.disconnect();
    } catch (_) {}
    _currentUserId = null;
    _isPusherInitialized = false;
  }

  // --- Inbox ---
  Future<void> fetchInbox(int userId, {bool isInitial = true}) async {
    if (isInitial) {
      _isLoadingInbox = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _apiClient.get(
        '${ApiConstants.readInbox}?user_id=$userId',
      );
      final List<dynamic> data = response['data'] ?? [];
      _inboxList = data.map((item) => ChatInboxModel.fromJson(item)).toList();
    } catch (e) {
      if (isInitial) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (isInitial) {
        _isLoadingInbox = false;
      }
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
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.createMessage,
        body: {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'text': trimmedText,
        },
      );

      // Jika backend mengembalikan objek data pesan baru, tambahkan langsung (Optimistic/Instant UI)
      if (response['data'] is Map) {
        final createdMsg = ChatMessageModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
        final isDuplicate = _roomMessages.any(
          (msg) => msg.id == createdMsg.id && createdMsg.id != 0,
        );
        if (!isDuplicate) {
          _roomMessages.add(createdMsg);
          notifyListeners();
        }
      }

      // Langsung sinkronkan pesan di room & inbox dari database tanpa bergantung penuh pada Pusher
      await fetchRoomMessages(
        senderId: senderId,
        receiverId: receiverId,
        isInitial: false,
      );
      fetchInbox(senderId, isInitial: false);

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}

