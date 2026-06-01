part of '../main.dart';

class _NotificationController {
  final _CivitasHomePageState state;
  _NotificationController(this.state);

  final List<Map<String, dynamic>> _notifications = [];
  int _unreadNotifCount = 0;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotifCount => _unreadNotifCount;

  Future<void> _syncNotifications() async {
    try {
      final response = await state.authController.apiService.get('notifikasi');
      if (response.statusCode >= 400) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['data'] is List) ? (data['data'] as List<dynamic>) : [];

      final loaded = <Map<String, dynamic>>[];
      var unread = 0;
      for (final item in items) {
        if (item is! Map) continue;
        final mapItem = Map<String, dynamic>.from(item);
        loaded.add(mapItem);
        if (mapItem['is_read'] != true) {
          unread++;
        }
      }

      if (state.mounted) {
        state.updateState(() {
          _notifications
            ..clear()
            ..addAll(loaded);
          _unreadNotifCount = unread;
        });
      }
    } catch (_) {
      // Offline fallback
    }
  }

  Future<void> _markNotificationRead(String id) async {
    state.updateState(() {
      for (final notif in _notifications) {
        final notifId = (notif['id'] ?? notif['_id'] ?? '').toString();
        if (notifId == id) {
          final isRead = notif['is_read'] == true || notif['is_read'] == 1 || notif['is_read'] == '1';
          if (!isRead) {
            notif['is_read'] = true;
            if (_unreadNotifCount > 0) _unreadNotifCount--;
          }
        }
      }
    });

    try {
      final response = await state.authController.apiService.patch('notifikasi/$id/read');
      if (response.statusCode < 400) {
        return;
      }
    } catch (_) {
      // Offline fallback
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notif) {
    final type = notif['type']?.toString();
    final title = notif['title']?.toString() ?? '';
    final body = notif['body']?.toString() ?? '';
    final senderId = notif['sender_id']?.toString();
    final senderName = notif['sender_name']?.toString() ?? 'Pengguna';
    final senderRole = notif['sender_role']?.toString();

    final isChat = type == 'chat' || 
        title.toLowerCase().contains('pesan baru') || 
        title.toLowerCase().contains('chat') || 
        body.toLowerCase().contains('pesan baru') || 
        body.toLowerCase().contains('hubungi pelapor');

    if (isChat) {
      // 1. Direct match by senderId
      if (senderId != null && senderId.isNotEmpty && senderId != state.authController.nim) {
        final isPeerChat = senderRole == 'civitas';
        ChatThread? chat;
        if (isPeerChat) {
          chat = state.chatController.chats.where((c) => c.peerId == senderId).firstOrNull;
        } else {
          chat = state.chatController.chats.where((c) => c.role == 'Admin').firstOrNull;
        }

        if (chat == null && isPeerChat) {
          chat = ChatThread(
            name: senderName,
            role: 'Pelapor',
            peerId: senderId,
            messages: [],
          );
          state.updateState(() {
            state.chatController._chats.insert(1, chat!);
          });
        }

        if (chat != null) {
          state.chatController._openChat(chat);
          return;
        }
      }

      // 2. Smart Fallback 1: Admin chat detection
      if (title.toLowerCase().contains('admin') || body.toLowerCase().contains('admin')) {
        final chat = state.chatController.chats.where((c) => c.role == 'Admin').firstOrNull;
        if (chat != null) {
          state.chatController._openChat(chat);
          return;
        }
      }

      // 3. Smart Fallback 2: Parse sender name from title/body for older or other peer-to-peer notifications
      String? parsedSenderName;
      if (title.toLowerCase().startsWith('pesan baru dari ')) {
        parsedSenderName = title.substring('pesan baru dari '.length).trim();
      } else if (body.toLowerCase().startsWith('anda menerima pesan baru dari ')) {
        final startIndex = 'anda menerima pesan baru dari '.length;
        final endIndex = body.toLowerCase().indexOf(':', startIndex);
        if (endIndex != -1) {
          parsedSenderName = body.substring(startIndex, endIndex).trim();
        }
      }

      if (parsedSenderName != null && parsedSenderName.isNotEmpty) {
        final searchName = parsedSenderName.toLowerCase();
        final chat = state.chatController.chats.where((c) {
          final cName = c.name.toLowerCase();
          return cName.contains(searchName) || searchName.contains(cName);
        }).firstOrNull;

        if (chat != null) {
          state.chatController._openChat(chat);
          return;
        }
      }

      // 4. Default fallback: go to general Pesan tab (Index 3)
      state.updateState(() {
        state._index = 3;
      });
    }
  }
}
