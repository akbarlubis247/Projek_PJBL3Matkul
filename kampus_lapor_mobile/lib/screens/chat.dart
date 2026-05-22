part of '../main.dart';

class _ChatPage extends StatelessWidget {
  const _ChatPage({required this.chats, required this.onOpen});

  final List<ChatThread> chats;
  final ValueChanged<ChatThread> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Header(
          title: 'Chat Civitas',
          subtitle: 'Kirim pesan ke admin atau civitas lain',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: chats
                .map((chat) => _ChatTile(chat: chat, onTap: () => onOpen(chat)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
