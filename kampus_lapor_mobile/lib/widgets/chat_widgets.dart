part of '../main.dart';

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.onTap});

  final ChatThread chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAdmin = chat.role == 'Admin';
    final hasUnread = chat.hasUnread;
    final lastMsg = chat.messages.isEmpty ? 'Belum ada pesan' : chat.messages.last.body;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: hasUnread ? const Color(0xFFC4B5FD) : const Color(0xFFF1F5F9),
          width: hasUnread ? 2 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            key: ValueKey(chat.name),
            child: Row(
              children: [
                // Avatar with double circle border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFFC4B5FD),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isAdmin ? const Color(0xFFF5F3FF) : const Color(0xFFFAF5FF),
                    backgroundImage: chat.profilePhoto != null ? MemoryImage(chat.profilePhoto!) : null,
                    child: chat.profilePhoto == null
                        ? Text(
                            chat.name.isNotEmpty ? chat.name.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(
                              color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF6D28D9),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Chat info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              style: TextStyle(
                                color: const Color(0xFF1E1B4B),
                                fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            chat.time,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAdmin ? const Color(0xFFEDE9FE) : const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAdmin ? 'ADMIN' : 'PELAPOR',
                              style: TextStyle(
                                color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF6D28D9),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Last Message
                          Expanded(
                            child: Text(
                              lastMsg,
                              style: TextStyle(
                                color: hasUnread ? const Color(0xFF312E81) : const Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Unread status dot
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .76,
        ),
        decoration: BoxDecoration(
          gradient: mine
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: mine ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 4),
            bottomRight: Radius.circular(mine ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: mine
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.body,
          style: TextStyle(
            color: mine ? Colors.white : const Color(0xFF1E293B),
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
