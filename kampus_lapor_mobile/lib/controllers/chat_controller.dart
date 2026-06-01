part of '../main.dart';

class _ChatController {
  final _CivitasHomePageState state;
  _ChatController(this.state);

  final List<ChatThread> _chats = [
    ChatThread(name: 'Admin Kampus', role: 'Admin', messages: []),
  ];

  // Getters
  List<ChatThread> get chats => _chats;

  Future<void> _openChat(ChatThread chat, {String? initialMessage}) async {
    await _syncChats();
    state.updateState(() => chat.hasUnread = false);

    if (!state.mounted) return;
    Navigator.of(state.context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chat: chat,
          initialMessage: initialMessage,
          onSend: (message) => _sendChatMessage(chat, message),
          onRefresh: () async {
            await _syncChats();
            final updatedChat = _chats.where((c) => c.peerId == chat.peerId && c.name == chat.name).firstOrNull;
            return updatedChat?.messages ?? chat.messages;
          },
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(ChatThread chat, String message) async {
    state.updateState(() => chat.messages.add(ChatMessage(body: message, isMine: true)));

    final isPeerChat = chat.peerId != null;

    try {
      final body = {
        'sender_id': state.authController.nim,
        'sender_identifier': state.authController.nim,
        'sender_name': state.authController.name,
        'sender_role': 'civitas',
        'receiver_role': isPeerChat ? 'civitas' : 'admin',
        'campus_key': state.authController.campusKey,
        'body': message,
        'receiver_id': isPeerChat ? chat.peerId! : state.authController.adminUsername,
        'receiver_name': isPeerChat ? chat.name : 'Admin Kampus',
        if (!isPeerChat) 'admin_username': state.authController.adminUsername,
      };

      final response = await state.authController.apiService.post('chats', body);
      if (response.statusCode >= 400) {
        throw Exception('Gagal mengirim pesan');
      }
      await _syncChats();
    } catch (_) {
      state.updateState(
        () => chat.messages.removeWhere(
          (item) => item.isMine && item.body == message,
        ),
      );
      if (!state.mounted) return;
      ScaffoldMessenger.of(state.context).showSnackBar(
        const SnackBar(content: Text('Pesan gagal dikirim ke server.')),
      );
    }
  }

  Future<void> _syncChats() async {
    try {
      final response = await state.authController.apiService.get('chats/civitas/${state.authController.nim}');
      
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final threads = (data['threads'] is List) ? (data['threads'] as List<dynamic>) : [];

      final loadedThreads = <ChatThread>[];
      final adminChat = ChatThread(name: 'Admin Kampus', role: 'Admin', messages: []);
      loadedThreads.add(adminChat);

      // Ambil seluruh draft chat lokal agar tidak hilang saat sync
      final localDrafts = _chats.where((c) => c.peerId != null).toList();

      for (final item in threads) {
        if (item is! Map) continue;
        final mapItem = Map<String, dynamic>.from(item);
        
        final participantId = mapItem['participant_id']?.toString() ?? '';
        final isPeerChat = mapItem['participant_role'] == 'civitas_peer' || participantId.startsWith('peer_');
        
        String chatName = 'Admin Kampus';
        String chatRole = 'Admin';
        String? peerId;
        
        if (isPeerChat) {
          final peerAId = mapItem['peer_a_id']?.toString() ?? '';
          final peerAName = mapItem['peer_a_name']?.toString() ?? '';
          final peerBId = mapItem['peer_b_id']?.toString() ?? '';
          final peerBName = mapItem['peer_b_name']?.toString() ?? '';
          
          if (peerAId == state.authController.nim) {
            chatName = peerBName;
            peerId = peerBId;
          } else {
            chatName = peerAName;
            peerId = peerAId;
          }
          chatRole = 'Pelapor';
        }

        Uint8List? peerPhoto;
        final photoBase64 = mapItem['peer_profile_photo']?.toString();
        if (photoBase64 != null && photoBase64.isNotEmpty) {
          try {
            peerPhoto = base64Decode(photoBase64);
          } catch (_) {
            peerPhoto = null;
          }
        }

        final messages = ((mapItem['messages'] ?? []) as List<dynamic>).map((msg) {
          if (msg is! Map) return ChatMessage(body: '', isMine: false);
          final m = Map<String, dynamic>.from(msg);
          final isMine = m['sender_id']?.toString() == state.authController.nim;
          return ChatMessage(
            body: m['body']?.toString() ?? '',
            isMine: isMine,
          );
        }).toList();

        if (!isPeerChat) {
          adminChat.messages = messages;
          adminChat.profilePhoto = peerPhoto;
        } else {
          loadedThreads.add(
            ChatThread(
              name: chatName,
              role: chatRole,
              messages: messages,
              time: 'Aktif',
              peerId: peerId,
              profilePhoto: peerPhoto,
            ),
          );
        }
      }

      // Masukkan kembali draft chat lokal yang belum tersimpan di server
      for (final draft in localDrafts) {
        final exists = loadedThreads.any((c) => c.peerId == draft.peerId);
        if (!exists) {
          loadedThreads.add(draft);
        }
      }

      if (state.mounted) {
        state.updateState(() {
          _chats
            ..clear()
            ..addAll(loadedThreads);
        });
      }
    } catch (_) {
      // Offline fallback
    }
  }
}
