import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(const KampusLaporApp());

class KampusLaporApp extends StatelessWidget {
  const KampusLaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kampus Lapor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        useMaterial3: true,
      ),
      home: const CivitasHomePage(),
    );
  }
}

class Report {
  Report({
    required this.title,
    required this.category,
    required this.location,
    required this.tag,
    required this.status,
    required this.date,
    required this.description,
    required this.reporter,
    this.photoBytes,
    this.remoteId,
  });

  String title;
  String category;
  String location;
  String tag;
  String status;
  String date;
  String description;
  String reporter;
  Uint8List? photoBytes;
  String? remoteId;
}

class ChatThread {
  ChatThread({
    required this.name,
    required this.role,
    required this.messages,
    this.time = 'Baru',
  });

  String name;
  String role;
  String time;
  List<ChatMessage> messages;
}

class ChatMessage {
  ChatMessage({required this.body, required this.isMine});

  String body;
  bool isMine;
}

class CivitasHomePage extends StatefulWidget {
  const CivitasHomePage({super.key});

  @override
  State<CivitasHomePage> createState() => _CivitasHomePageState();
}

class _CivitasHomePageState extends State<CivitasHomePage> {
  static const _apiBase = 'http://127.0.0.1:8000';
  static const _apiBases = [
    'http://127.0.0.1:8000',
    'http://localhost:8000',
    'http://10.0.2.2:8000',
  ];
  bool _isLoggedIn = false;
  int _index = 0;
  String _name = 'Civitas Mobile 1';
  String _email = 'civitas1@kampus-lapor.test';
  String _nim = 'CV-0001';
  String _adminUsername = 'admin1';
  Uint8List? _profilePhoto;

  static const List<String> _defaultLocations = [
    'Perpustakaan LSI',
    'Gedung Rektorat',
    'Kantin Rektorat',
    'Gedung Kuliah A1',
    'Masjid Kampus',
    'Parkiran Fakultas',
  ];

  final List<String> _tags = const [
    'Laptop',
    'Kunci',
    'HP',
    'Gelang',
    'Earphone',
    'Tas',
    'Dompet',
    'Kacamata',
    'Lainnya',
  ];

  List<String> _locations = [..._defaultLocations];

  late final List<Report> _reports = [
    Report(
      title: 'Laptop hitam hilang',
      category: 'Barang Hilang',
      location: 'Perpustakaan LSI',
      tag: 'Laptop',
      status: 'Diproses',
      date: '13 Mei 2026',
      description: 'Laptop hitam dengan stiker organisasi di bagian belakang.',
      reporter: 'Budi Santoso',
    ),
    Report(
      title: 'Kunci motor Honda',
      category: 'Barang Hilang',
      location: 'Parkiran Fakultas',
      tag: 'Kunci',
      status: 'Aktif',
      date: '12 Mei 2026',
      description: 'Kunci motor dengan gantungan biru.',
      reporter: 'Siti Aminah',
    ),
  ];

  late final List<ChatThread> _chats = [
    ChatThread(
      name: 'Admin Kampus',
      role: 'Admin',
      time: '10.24',
      messages: [
        ChatMessage(
          body: 'Laporan AC sudah diteruskan ke sarpras.',
          isMine: false,
        ),
      ],
    ),
    ChatThread(
      name: 'Siti Aminah',
      role: 'Civitas',
      time: '09.51',
      messages: [
        ChatMessage(
          body: 'Saya melihat dompet serupa di meja baca.',
          isMine: false,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncAdminChat();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return MobileLoginPage(onLogin: _login, apiBases: _apiBases);
    }

    final chatCount = _chats.where((chat) => chat.messages.isNotEmpty).length;
    Widget chatIcon(IconData icon) => chatCount > 0
        ? Badge(label: Text('$chatCount'), child: Icon(icon))
        : Icon(icon);

    final pages = [
      _HomePage(
        reports: _reports
            .where((item) => item.category == 'Barang Hilang')
            .toList(),
        tags: _tags,
        locations: _locations,
        onMessage: _openMessageToReporter,
        profilePhoto: _profilePhoto,
        onProfileTap: _openProfile,
      ),
      _CreateReportPage(
        tags: _tags,
        locations: _locations,
        onSubmit: _addReport,
        profilePhoto: _profilePhoto,
        onProfileTap: _openProfile,
      ),
      _ReportListPage(
        reports: _reports,
        profilePhoto: _profilePhoto,
        onProfileTap: _openProfile,
        onRefresh: _syncReportStatuses,
        refreshKey: _nim,
      ),
      _ChatPage(
        chats: _chats,
        onOpen: _openChat,
        profilePhoto: _profilePhoto,
        onProfileTap: _openProfile,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Buat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: chatIcon(Icons.chat_bubble_outline),
            selectedIcon: chatIcon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  void _addReport(Report report) {
    setState(() {
      _reports.insert(0, report);
      _index = 2;
    });
    _sendReportToAdmin(report);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dibuat.')));
  }

  Future<void> _sendReportToAdmin(Report report) async {
    final photo = report.photoBytes == null
        ? null
        : 'data:image/jpeg;base64,${base64Encode(report.photoBytes!)}';

    for (final base in _apiBases) {
      try {
        final body = {
          'reporter_id': _nim,
          'reporter_name': _name,
          'category': report.category,
          'title': report.title,
          'location': report.location,
          'tag': report.tag,
          'description': report.description,
        };
        if (photo != null) body['photo_data'] = photo;

        final response = await http
            .post(
              Uri.parse('$base/mobile/reports'),
              headers: {'Accept': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode < 400) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          report.remoteId = (data['report'] as Map<String, dynamic>?)?['id']
              ?.toString();
          return;
        }
      } catch (_) {
        // Try the next local address; the report remains visible locally.
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Laporan tersimpan di mobile, tapi belum terkirim ke admin.',
        ),
      ),
    );
  }

  Future<void> _syncReportStatuses({bool showNotifications = true}) async {
    for (final base in _apiBases) {
      try {
        final response = await http
            .get(Uri.parse('$base/mobile/reports/$_nim'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 400) continue;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['reports'] as List<dynamic>? ?? [];
        bool changed = false;

        for (final item in items) {
          final report = item as Map<String, dynamic>;
          final title = report['title']?.toString();
          final category = report['category']?.toString();
          final status = report['status']?.toString();
          final remoteId = report['id']?.toString();
          final local = _reports.where((entry) {
            final sameId = entry.remoteId != null && entry.remoteId == remoteId;
            final sameTitle =
                entry.title == title && entry.category == category;
            return sameId || sameTitle;
          }).firstOrNull;
          if (local == null) {
            final photoData = report['photo_data']?.toString();
            _reports.add(
              Report(
                title: title ?? '-',
                category: category ?? 'Barang Hilang',
                location: report['location']?.toString() ?? '-',
                tag: report['tag']?.toString() ?? 'Lainnya',
                status: status ?? 'Aktif',
                date: _formatReportDate(report['created_at']),
                description: report['description']?.toString() ?? '',
                reporter: report['reporter_name']?.toString() ?? _name,
                photoBytes: _decodeReportPhoto(photoData),
                remoteId: remoteId,
              ),
            );
            changed = true;
            if (showNotifications &&
                status != null &&
                [
                  'Menunggu Diambil',
                  'Sudah Diambil',
                  'Sudah Diperbaiki',
                  'Selesai',
                ].contains(status)) {
              _showReportNotification(category, status);
            }
            continue;
          }

          local.remoteId ??= remoteId;
          if (status != null && local.status != status) {
            local.status = status;
            changed = true;
            if (showNotifications) _showReportNotification(category, status);
          }
        }

        if (changed && mounted) setState(() {});
        return;
      } catch (_) {
        // Try next local address.
      }
    }
  }

  void _showReportNotification(String? category, String status) {
    final message = category == 'Fasilitas Rusak'
        ? 'Fasilitas telah diperbaiki.'
        : (status == 'Sudah Diambil'
              ? 'Barang sudah diambil oleh pelapor.'
              : 'Barang sudah ditemukan. Silakan konfirmasi penerimaan.');
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Uint8List? _decodeReportPhoto(String? photoData) {
    if (photoData == null || !photoData.contains(',')) return null;
    try {
      return base64Decode(photoData.split(',').last);
    } catch (_) {
      return null;
    }
  }

  String _formatReportDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.length >= 10) return raw.substring(0, 10);
    return '13 Mei 2026';
  }

  void _openMessageToReporter(Report report) {
    final existing = _chats
        .where((chat) => chat.name == report.reporter)
        .firstOrNull;
    final chat =
        existing ??
        ChatThread(
          name: report.reporter,
          role: 'Civitas',
          messages: [
            ChatMessage(
              body: 'Halo, saya ingin bertanya tentang ${report.title}.',
              isMine: true,
            ),
          ],
        );

    if (existing == null) {
      setState(() => _chats.insert(0, chat));
    }

    _openChat(chat);
  }

  Future<void> _openChat(ChatThread chat) async {
    if (chat.name == 'Admin Kampus') {
      await _syncAdminChat();
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chat: chat,
          onSend: (message) => _sendChatMessage(chat, message),
          onRefresh: chat.name == 'Admin Kampus'
              ? () async {
                  await _syncAdminChat();
                  return chat.messages;
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(ChatThread chat, String message) async {
    setState(() => chat.messages.add(ChatMessage(body: message, isMine: true)));

    if (chat.name != 'Admin Kampus') return;

    await http.post(
      Uri.parse('$_apiBase/chat/send'),
      headers: {'Accept': 'application/json'},
      body: {
        'sender_id': _nim,
        'sender_identifier': _nim,
        'sender_name': _name,
        'sender_role': 'civitas',
        'receiver_id': _adminUsername,
        'receiver_name': 'Admin Kampus',
        'body': message,
      },
    );
  }

  Future<void> _syncAdminChat() async {
    try {
      final response = await http.get(Uri.parse('$_apiBase/chat/thread/$_nim'));
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final thread = data['thread'] as Map<String, dynamic>?;
      if (thread == null) return;
      final messages = (thread['messages'] as List<dynamic>? ?? []).map((item) {
        final message = item as Map<String, dynamic>;
        return ChatMessage(
          body: message['body'].toString(),
          isMine: message['sender_role'] == 'civitas',
        );
      }).toList();
      final adminChat = _chats.firstWhere(
        (chat) => chat.name == 'Admin Kampus',
      );
      setState(() => adminChat.messages = messages);
    } catch (_) {
      // Local demo remains usable if the Laravel server is offline.
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          name: _name,
          email: _email,
          nim: _nim,
          photoBytes: _profilePhoto,
          reports: _reports,
          onSave: (name, email, nim, photo) {
            setState(() {
              _name = name;
              _email = email;
              _nim = nim;
              _profilePhoto = photo ?? _profilePhoto;
            });
          },
          onLogout: _logout,
        ),
      ),
    );
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _index = 0;
    });
    Navigator.of(context).pop();
  }

  void _login(Map<String, dynamic> user) {
    setState(() {
      _isLoggedIn = true;
      _name = (user['name'] ?? _name).toString();
      _email = (user['email'] ?? _email).toString();
      _nim = (user['identifier'] ?? user['nim'] ?? _nim).toString();
      _adminUsername = (user['admin_username'] ?? 'admin1').toString();
      final campusLocations = (user['locations'] as List<dynamic>? ?? [])
          .map((item) => (item as Map<String, dynamic>)['nama']?.toString())
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList();
      _locations = campusLocations.isNotEmpty
          ? campusLocations
          : [..._defaultLocations];
      _reports.clear();
      _chats
        ..clear()
        ..add(ChatThread(name: 'Admin Kampus', role: 'Admin', messages: []));
    });
    _syncReportStatuses(showNotifications: false);
  }
}

class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({
    super.key,
    required this.onLogin,
    required this.apiBases,
  });

  final void Function(Map<String, dynamic> user) onLogin;
  final List<String> apiBases;

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final _name = TextEditingController(text: 'Mahasiswa UPI 1');
  final _nim = TextEditingController(text: 'UPI-0001');
  final _username = TextEditingController(text: 'civitas1');
  final _email = TextEditingController(text: 'mahasiswa1@upi.edu');
  final _password = TextEditingController(text: 'civitas123');
  bool _registerMode = false;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: .18),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/logo_kampus_lapor.png',
                        width: 168,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Kampus Lapor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Laporkan barang hilang, fasilitas rusak, dan chat dengan admin kampus.',
                      style: TextStyle(color: Color(0xFFEDE9FE), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _AuthModeButton(
                            label: 'Daftar',
                            icon: Icons.person_add_alt_1,
                            active: _registerMode,
                            onTap: () => setState(() {
                              _registerMode = true;
                              _error = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AuthModeButton(
                            label: 'Login',
                            icon: Icons.login,
                            active: !_registerMode,
                            onTap: () => setState(() {
                              _registerMode = false;
                              _error = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFF991B1B)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_registerMode) ...[
                      _AuthField(
                        controller: _name,
                        label: 'Nama lengkap',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        controller: _nim,
                        label: 'Username / NIM',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        controller: _email,
                        label: 'Email kampus',
                        icon: Icons.mail_outline,
                        helper: 'Contoh: mahasiswa@upi.edu',
                      ),
                    ] else ...[
                      _AuthField(
                        controller: _username,
                        label: 'Username / NIM',
                        icon: Icons.alternate_email,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _AuthField(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFF5B21B6),
                      ),
                      child: Text(
                        _loading
                            ? 'Memproses...'
                            : (_registerMode ? 'Buat Akun' : 'Masuk'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _registerMode
                          ? 'Email kampus dipakai untuk mencocokkan akun dengan admin universitas.'
                          : 'Gunakan username/NIM yang kamu daftarkan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final body = {
        'password': _password.text,
        if (_registerMode) ...{
          'name': _name.text.trim(),
          'nim': _nim.text.trim(),
          'email': _email.text.trim(),
        } else
          'username': _username.text.trim(),
      };
      final response = await _postMobileAuth(body);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        setState(
          () =>
              _error = (data['message'] ?? 'Gagal memproses akun.').toString(),
        );
        return;
      }
      if (_registerMode && data['pending'] == true) {
        setState(() {
          _registerMode = false;
          _username.text = _nim.text.trim();
          _error = data['message'].toString();
        });
        return;
      }
      widget.onLogin(data['user'] as Map<String, dynamic>);
    } catch (_) {
      setState(
        () => _error =
            'Tidak bisa terhubung ke server Laravel. Pastikan Laravel sedang jalan di port 8000.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<http.Response> _postMobileAuth(Map<String, String> body) async {
    Object? lastError;
    for (final base in widget.apiBases) {
      try {
        return await http
            .post(
              Uri.parse('$base/mobile/${_registerMode ? 'register' : 'login'}'),
              headers: {'Accept': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 4));
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? Exception('Server tidak dapat dihubungi');
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEDE9FE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? const Color(0xFF5B21B6) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active
                    ? const Color(0xFF5B21B6)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.helper,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? helper;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.profilePhoto,
    required this.onProfileTap,
  });

  final String title;
  final String subtitle;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF7C3AED),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(999),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage: profilePhoto == null
                  ? null
                  : MemoryImage(profilePhoto!),
              child: profilePhoto == null
                  ? const Text(
                      'CV',
                      style: TextStyle(
                        color: Color(0xFF5B21B6),
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({
    required this.reports,
    required this.tags,
    required this.locations,
    required this.onMessage,
    required this.profilePhoto,
    required this.onProfileTap,
  });

  final List<Report> reports;
  final List<String> tags;
  final List<String> locations;
  final ValueChanged<Report> onMessage;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _query = '';
  String _tag = 'Semua';
  String _location = 'Semua';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.reports.where((report) {
      final matchQuery =
          report.title.toLowerCase().contains(_query.toLowerCase()) ||
          report.description.toLowerCase().contains(_query.toLowerCase()) ||
          report.tag.toLowerCase().contains(_query.toLowerCase());
      final matchTag = _tag == 'Semua' || report.tag == _tag;
      final matchLocation =
          _location == 'Semua' || report.location == _location;
      return matchQuery && matchTag && matchLocation;
    }).toList();

    return ListView(
      children: [
        _Header(
          title: 'Kampus Lapor',
          subtitle: 'Cari barang hilang dan hubungi pelapor',
          profilePhoto: widget.profilePhoto,
          onProfileTap: widget.onProfileTap,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari barang hilang...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      value: _tag,
                      values: ['Semua', ...widget.tags],
                      onChanged: (v) => setState(() => _tag = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterDropdown(
                      value: _location,
                      values: ['Semua', ...widget.locations],
                      onChanged: (v) => setState(() => _location = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Barang Hilang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...filtered.map(
                (report) => _LostItemCard(
                  report: report,
                  onMessage: () => widget.onMessage(report),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateReportPage extends StatefulWidget {
  const _CreateReportPage({
    required this.tags,
    required this.locations,
    required this.onSubmit,
    required this.profilePhoto,
    required this.onProfileTap,
  });

  final List<String> tags;
  final List<String> locations;
  final ValueChanged<Report> onSubmit;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;

  @override
  State<_CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<_CreateReportPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Barang Hilang';
  String _tag = 'Laptop';
  String? _location;
  Uint8List? _photoBytes;

  List<String> get _locationValues =>
      widget.locations.isEmpty ? ['Belum ada lokasi'] : widget.locations;

  String get _selectedLocation =>
      _locationValues.contains(_location) ? _location! : _locationValues.first;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Header(
          title: 'Buat Laporan',
          subtitle: 'Laporkan barang hilang atau fasilitas rusak',
          profilePhoto: widget.profilePhoto,
          onProfileTap: widget.onProfileTap,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Barang Hilang', 'Fasilitas Rusak']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 12),
                  if (_category == 'Barang Hilang') ...[
                    DropdownButtonFormField<String>(
                      initialValue: _tag,
                      decoration: const InputDecoration(
                        labelText: 'Tag barang',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.tags
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _tag = value ?? _tag),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Judul laporan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi kejadian',
                      border: OutlineInputBorder(),
                    ),
                    items: _locationValues
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _location = value ?? _location),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PhotoPicker(photoBytes: _photoBytes, onPick: _pickPhoto),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Laporan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  void _submit() {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul wajib diisi.')));
      return;
    }

    widget.onSubmit(
      Report(
        title: _title.text.trim(),
        category: _category,
        location: _selectedLocation,
        tag: _category == 'Barang Hilang' ? _tag : 'Fasilitas',
        status: 'Aktif',
        date: '13 Mei 2026',
        description: _description.text.trim(),
        reporter: 'Civitas Mobile 1',
        photoBytes: _photoBytes,
      ),
    );

    _title.clear();
    _description.clear();
    setState(() => _photoBytes = null);
  }
}

class _ReportListPage extends StatelessWidget {
  const _ReportListPage({
    required this.reports,
    required this.profilePhoto,
    required this.onProfileTap,
    required this.onRefresh,
    required this.refreshKey,
  });

  final List<Report> reports;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;
  final Future<void> Function() onRefresh;
  final String refreshKey;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _ReportListBody(
        reports: reports,
        profilePhoto: profilePhoto,
        onProfileTap: onProfileTap,
        onRefresh: onRefresh,
        refreshKey: refreshKey,
      ),
    );
  }
}

class _ReportListBody extends StatefulWidget {
  const _ReportListBody({
    required this.reports,
    required this.profilePhoto,
    required this.onProfileTap,
    required this.onRefresh,
    required this.refreshKey,
  });

  final List<Report> reports;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;
  final Future<void> Function() onRefresh;
  final String refreshKey;

  @override
  State<_ReportListBody> createState() => _ReportListBodyState();
}

class _ReportListBodyState extends State<_ReportListBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRefresh());
  }

  @override
  void didUpdateWidget(covariant _ReportListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRefresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _Header(
          title: 'Daftar Laporan',
          subtitle: 'Pantau status dari admin untuk laporan yang dibuat',
          profilePhoto: widget.profilePhoto,
          onProfileTap: widget.onProfileTap,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: widget.reports
                .map(
                  (report) => _ReportCard(
                    report: report,
                    trailing: _StatusLabel(status: report.status),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage({
    required this.chats,
    required this.onOpen,
    required this.profilePhoto,
    required this.onProfileTap,
  });

  final List<ChatThread> chats;
  final ValueChanged<ChatThread> onOpen;
  final Uint8List? profilePhoto;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Header(
          title: 'Chat Civitas',
          subtitle: 'Kirim pesan ke admin atau civitas lain',
          profilePhoto: profilePhoto,
          onProfileTap: onProfileTap,
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

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({
    super.key,
    required this.chat,
    required this.onSend,
    this.onRefresh,
  });

  final ChatThread chat;
  final ValueChanged<String> onSend;
  final Future<List<ChatMessage>> Function()? onRefresh;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _message = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _message.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final loader = widget.onRefresh;
    if (loader == null) return;
    final messages = await loader();
    if (!mounted) return;
    setState(() => widget.chat.messages = messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: widget.chat.messages
                  .map((message) => _Bubble(message: message))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (_message.text.trim().isEmpty) return;
    widget.onSend(_message.text.trim());
    setState(() => _message.clear());
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.nim,
    required this.photoBytes,
    required this.reports,
    required this.onSave,
    required this.onLogout,
  });

  final String name;
  final String email;
  final String nim;
  final Uint8List? photoBytes;
  final List<Report> reports;
  final void Function(String name, String email, String nim, Uint8List? photo)
  onSave;
  final VoidCallback onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _name = TextEditingController(text: widget.name);
  late final _email = TextEditingController(text: widget.email);
  late final _nim = TextEditingController(text: widget.nim);
  Uint8List? _photo;

  @override
  void initState() {
    super.initState();
    _photo = widget.photoBytes;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Civitas'),
          actions: [
            IconButton(
              onPressed: widget.onLogout,
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Akun'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: widget.reports
                  .map((report) => _ReportCard(report: report))
                  .toList(),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: _photo == null
                        ? null
                        : MemoryImage(_photo!),
                    child: _photo == null ? const Text('CV') : null,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickProfilePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Ubah Foto Profil'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nim,
                  decoration: const InputDecoration(
                    labelText: 'NIM / ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    widget.onSave(
                      _name.text.trim(),
                      _email.text.trim(),
                      _nim.text.trim(),
                      _photo,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Profil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photo = bytes);
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? ['Semua'] : values;
    final safeValue = safeValues.contains(value) ? value : safeValues.first;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: safeValues
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) => onChanged(value ?? safeValue),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photoBytes, required this.onPick});

  final Uint8List? photoBytes;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: Text(photoBytes == null ? 'Tambah Foto' : 'Ganti Foto'),
    );
  }
}

class _LostItemCard extends StatelessWidget {
  const _LostItemCard({required this.report, required this.onMessage});

  final Report report;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: report.photoBytes == null
                  ? const Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Color(0xFF64748B),
                    )
                  : Image.memory(report.photoBytes!, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${report.tag} • ${report.location}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatusLabel(status: report.status),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Pesan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, this.trailing});

  final Report report;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDE9FE),
          child: Icon(
            report.category == 'Barang Hilang'
                ? Icons.inventory_2_outlined
                : Icons.handyman_outlined,
            color: const Color(0xFF5B21B6),
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${report.category} • ${report.location}\n${report.date}',
          ),
        ),
        trailing: trailing ?? _StatusLabel(status: report.status),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8FAFC),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.onTap});

  final ChatThread chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: chat.role == 'Admin'
              ? const Color(0xFFEDE9FE)
              : const Color(0xFFF3E8FF),
          child: Text(
            chat.name.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              chat.time,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(chat.messages.isEmpty ? '' : chat.messages.last.body),
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
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .72,
        ),
        decoration: BoxDecoration(
          color: message.isMine ? const Color(0xFFEDE9FE) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(message.body),
      ),
    );
  }
}
