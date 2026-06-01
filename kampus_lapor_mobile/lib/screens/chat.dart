part of '../main.dart';

class _ChatPage extends StatelessWidget {
  const _ChatPage({required this.chats, required this.onOpen});

  final List<ChatThread> chats;
  final ValueChanged<ChatThread> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const _Header(
          title: 'Kotak Masuk Pesan',
          subtitle: 'Hubungi Admin Kampus atau civitas penemu barang secara privat',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Semua Percakapan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
              if (chats.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFFC4B5FD)),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat pesan.',
                        style: TextStyle(color: Color(0xFF8A7BA3), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                ...chats.map((chat) => _ChatTile(chat: chat, onTap: () => onOpen(chat))),
            ],
          ),
        ),
      ],
    );
  }
}
