// ziesocial/flutter/ziesocial/lib/view/inbox_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/view/chat_room_view.dart';
import 'package:ziesocial/viewmodel/chat_viewmodel.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  int? currentUserId;
  Timer? _inboxPollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<LoginViewModel>().user;
      if (user != null) {
        currentUserId = int.tryParse(user.id);
        if (currentUserId != null) {
          final vm = context.read<ChatViewModel>();
          vm.fetchInbox(currentUserId!);
          vm.initPusher(currentUserId!);
          _startPolling(currentUserId!);
        }
      }
    });
  }

  void _startPolling(int uid) {
    _inboxPollingTimer?.cancel();
    _inboxPollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final vm = context.read<ChatViewModel>();
      if (!vm.isLoadingInbox) {
        vm.fetchInbox(uid, isInitial: false);
      }
    });
  }

  @override
  void dispose() {
    _inboxPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: chatVM.isLoadingInbox
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (currentUserId != null) {
                  await context.read<ChatViewModel>().fetchInbox(
                    currentUserId!,
                  );
                }
              },
              child: chatVM.inboxList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 180),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.question_answer_outlined,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              const Gap(16),
                              const Text(
                                'Belum ada pesan masuk.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: chatVM.inboxList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      itemBuilder: (context, index) {
                        final item = chatVM.inboxList[index];

                        return ListTile(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomView(
                                  targetUserId: item.otherUserId,
                                  targetUserName: item.name,
                                  targetUserAvatar: item.avatar,
                                ),
                              ),
                            );
                            if (mounted && currentUserId != null) {
                              context.read<ChatViewModel>().fetchInbox(
                                currentUserId!,
                              );
                            }
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(item.avatar),
                            backgroundColor: Colors.grey[200],
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: item.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (item.isSentByMe ? 'Anda: ' : '') +
                                      item.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: item.unreadCount > 0
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFF6B7280),
                                    fontWeight: item.unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Text(
                                item.lastMessageDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          trailing: item.unreadCount > 0
                              ? CircleAvatar(
                                  radius: 10,
                                  backgroundColor: const Color(0xFFEF4444),
                                  child: Text(
                                    item.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
            ),
    );
  }
}

