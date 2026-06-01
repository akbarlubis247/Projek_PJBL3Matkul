part of '../main.dart';

class CivitasHomePage extends StatefulWidget {
  const CivitasHomePage({super.key});

  @override
  State<CivitasHomePage> createState() => _CivitasHomePageState();
}

class _CivitasHomePageState extends State<CivitasHomePage> {
  late final _AuthController authController = _AuthController(this);
  late final _ReportController reportController = _ReportController(this);
  late final _ChatController chatController = _ChatController(this);
  late final _NotificationController notificationController = _NotificationController(this);

  int _index = 0;

  void updateState(VoidCallback fn) {
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    chatController._syncChats();
  }

  @override
  Widget build(BuildContext context) {
    if (!authController.isLoggedIn) {
      return MobileLoginPage(onLogin: authController._login, apiService: authController.apiService);
    }

    final chatCount = chatController.chats.where((chat) => chat.hasUnread).length;

    final pages = [
      _HomePage(
        reports: reportController.lostItems,
        tags: reportController.tags,
        locations: authController.locations,
        onMessage: reportController._openMessageToReporter,
      ),
      _NotificationPage(
        notifications: notificationController.notifications,
        onRefresh: notificationController._syncNotifications,
        onRead: notificationController._markNotificationRead,
        onTapNotification: notificationController._handleNotificationTap,
      ),
      _CreateReportPage(
        tags: reportController.tags,
        locations: authController.locations,
        onSubmit: reportController._addReport,
      ),
      _ChatPage(chats: chatController.chats, onOpen: chatController._openChat),
      _ProfileNavPage(
        name: authController.name,
        email: authController.email,
        nim: authController.nim,
        profilePhoto: authController.profilePhoto,
        reports: reportController.reports,
        onSave: authController._updateProfile,
        onLogout: authController._logoutFromNav,
        onMarkAsFound: reportController._markReportAsFound,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFEDE9FE),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.notifications_outlined, Icons.notifications, 'Notifikasi', badge: notificationController.unreadNotifCount),
              _buildCenterNavItem(),
              _buildNavItem(3, Icons.chat_bubble_outline, Icons.chat_bubble, 'Pesan', badge: chatCount),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
