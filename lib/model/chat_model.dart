// ziesocial/flutter/ziesocial/lib/model/chat_model.dart
import 'package:ziesocial/core/constants.dart';

class ChatInboxModel {
  final int otherUserId;
  final String username;
  final String name;
  final String avatar;
  final String lastMessage;
  final String lastMessageDate;
  final bool isSentByMe;
  final int unreadCount;

  ChatInboxModel({
    required this.otherUserId,
    required this.username,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.isSentByMe,
    required this.unreadCount,
  });

  factory ChatInboxModel.fromJson(Map<String, dynamic> json) {
    return ChatInboxModel(
      otherUserId: json['other_user_id'] is int
          ? json['other_user_id']
          : int.parse(json['other_user_id'].toString()),
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      avatar: ApiConstants.getImageUrl(json['avatar']),
      lastMessage: json['last_message'] ?? '',
      lastMessageDate: _formatDate(json['last_message_date']),
      isSentByMe: (json['is_sent_by_me'] is bool)
          ? json['is_sent_by_me']
          : (json['is_sent_by_me'] == 1 || json['is_sent_by_me'] == '1'),
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
    );
  }

  static String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String text;
  final bool isRead;
  final String createDate;
  final String formattedTime;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.isRead,
    required this.createDate,
    required this.formattedTime,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['create_date']?.toString() ?? '';
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.parse(json['sender_id'].toString()),
      receiverId: json['receiver_id'] is int
          ? json['receiver_id']
          : int.parse(json['receiver_id'].toString()),
      text: json['text'] ?? '',
      isRead: (json['is_read'] is bool)
          ? json['is_read']
          : (json['is_read'] == 1 || json['is_read'] == '1'),
      createDate: rawDate,
      formattedTime: ChatInboxModel._formatDate(rawDate),
    );
  }
}
