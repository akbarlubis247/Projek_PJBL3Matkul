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

  void _initMockData() {
    authController._isLoggedIn = true;
    if (reportController._lostItems.isEmpty) {
      reportController._lostItems.addAll([
        Report(
          title: 'KTM IPB a.n. Budi Santoso',
          category: 'Barang Hilang',
          location: 'Perpustakaan LSI - Lt. 2 Meja Baca',
          tag: 'Lainnya',
          status: 'Aktif',
          date: '10 Mei 2026',
          description: 'KTM IPB tertinggal di area meja belajar dekat rak buku referensi.',
          reporter: 'Budi Santoso',
        ),
        Report(
          title: 'Kunci Motor Honda Vario Hitam',
          category: 'Barang Hilang',
          location: 'Parkiran Fakultas - Zona B',
          tag: 'Kunci',
          status: 'Aktif',
          date: '09 Mei 2026',
          description: 'Kunci motor dengan gantungan boneka kecil cokelat, ditemukan di atas motor.',
          reporter: 'Siti Rahma',
        ),
        Report(
          title: 'Earphone TWS Hitam',
          category: 'Barang Hilang',
          location: 'Gedung Kuliah A1 - RK A1.02',
          tag: 'Earphone',
          status: 'Aktif',
          date: '08 Mei 2026',
          description: 'Casing warna hitam matte, tertinggal di kursi baris ketiga.',
          reporter: 'Ahmad Fauzi',
        ),
      ]);
    }
    if (reportController._reports.isEmpty) {
      reportController._reports.addAll([
        Report(
          title: 'KTM IPB a.n. Budi Santoso',
          category: 'Barang Hilang',
          location: 'Perpustakaan LSI',
          tag: 'Lainnya',
          status: 'Aktif',
          date: '10 Mei 2026',
          description: 'KTM IPB tertinggal di area meja belajar.',
          reporter: 'Civitas Mobile 1',
        ),
        Report(
          title: 'AC Ruang Kuliah Mati & Bocor',
          category: 'Fasilitas Rusak',
          location: 'Gedung Kuliah A1 - RK A1.02',
          tag: 'Lainnya',
          status: 'Diproses',
          date: '09 Mei 2026',
          description: 'AC meneteskan air deras dan ruangan panas saat perkuliahan berlangsung.',
          reporter: 'Civitas Mobile 1',
        ),
      ]);
    }
    if (notificationController._notifications.isEmpty) {
      notificationController._notifications.addAll([
        {
          'id': '1',
          'title': 'Status Laporan Diperbarui',
          'message': 'Laporan Fasilitas Rusak "AC RK A1.02" sedang ditangani oleh teknisi sarpras.',
          'is_read': false,
          'created_at': '10 Mei 2026 09:30',
        },
        {
          'id': '2',
          'title': 'Pesan Baru dari Admin',
          'message': 'Admin Kampus merespon pesan Anda terkait verifikasi serah terima barang hilang.',
          'is_read': true,
          'created_at': '09 Mei 2026 14:15',
        },
      ]);
      notificationController._unreadNotifCount = 1;
    }
    if (chatController._chats.length <= 1) {
      chatController._chats.clear();
      chatController._chats.addAll([
        ChatThread(
          name: 'Admin Kampus',
          role: 'Admin',
          time: '10:15',
          hasUnread: true,
          messages: [
            ChatMessage(body: 'Halo Civitas, terkait laporan AC bocor sedang kami teruskan ke pihak Sarpras ya.', isMine: false),
            ChatMessage(body: 'Baik pak/bu admin, terima kasih banyak atas respon cepatnya.', isMine: true),
          ],
        ),
        ChatThread(
          name: 'Siti Rahma',
          role: 'Pelapor',
          time: 'Kemarin',
          hasUnread: false,
          messages: [
            ChatMessage(body: 'Permisi, kunci motor Vario apakah sudah diambil ke pos satpam?', isMine: false),
            ChatMessage(body: 'Sudah saya titipkan di pos satpam gerbang utama.', isMine: true),
          ],
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final view = uri.queryParameters['view'] ?? '';

    if (view == 'daftar') {
      return MobileLoginPage(
        onLogin: authController._login,
        apiService: authController.apiService,
        initialRegisterMode: true,
      );
    }
    if (view == 'login') {
      return MobileLoginPage(
        onLogin: authController._login,
        apiService: authController.apiService,
        initialRegisterMode: false,
      );
    }

    if (view.isNotEmpty) {
      _initMockData();
      if (view == 'beranda' || view == 'home') {
        _index = 0;
      } else if (view == 'notifikasi') {
        _index = 1;
      } else if (view == 'buat_laporan') {
        _index = 2;
      } else if (view == 'chat') {
        _index = 3;
      } else if (view == 'profil') {
        _index = 4;
      }
    } else if (!authController.isLoggedIn) {
      return MobileLoginPage(
        onLogin: authController._login,
        apiService: authController.apiService,
      );
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
