part of '../main.dart';

class _NotificationPage extends StatelessWidget {
  const _NotificationPage({
    required this.notifications,
    required this.onRefresh,
    required this.onRead,
    this.onTapNotification,
  });

  final List<Map<String, dynamic>> notifications;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onRead;
  final ValueChanged<Map<String, dynamic>>? onTapNotification;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF7C3AED),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          const _Header(
            title: 'Notifikasi',
            subtitle: 'Informasi dan status pembaruan laporan Anda',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: notifications.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 52,
                          color: Color(0xFFC4B5FD),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada notifikasi.',
                          style: TextStyle(
                            color: Color(0xFF8A7BA3),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: notifications.map((notif) {
                      final id = (notif['id'] ?? notif['_id'] ?? '').toString();
                      final isRead = notif['is_read'] == true || notif['is_read'] == 1 || notif['is_read'] == '1';
                      final title = notif['title']?.toString() ?? 'Pemberitahuan';
                      final body = notif['body']?.toString() ?? '';
                      final date = notif['created_at']?.toString() ?? 'Baru';
                      final cleanDate = date.length >= 19 
                          ? '${date.substring(0, 10)} ${date.substring(11, 16)}'
                          : date.length >= 10 ? date.substring(0, 10) : date;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isRead ? Colors.white : const Color(0xFFF5F3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isRead ? const Color(0xFFE9D5FF) : const Color(0xFFC4B5FD),
                            width: isRead ? 1.5 : 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (!isRead && id.isNotEmpty) {
                              onRead(id);
                            }
                            onTapNotification?.call(notif);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: isRead ? const Color(0xFFF1F5F9) : const Color(0xFFEDE9FE),
                                  radius: 20,
                                  child: Icon(
                                    isRead ? Icons.notifications_outlined : Icons.notifications_active,
                                    color: isRead ? const Color(0xFF64748B) : const Color(0xFF7C3AED),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14.5,
                                                color: isRead ? const Color(0xFF475569) : const Color(0xFF2B2438),
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF7C3AED),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        body,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isRead ? const Color(0xFF64748B) : const Color(0xFF4B3F5C),
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cleanDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8A7BA3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
