import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'models.dart';

part 'screens/auth.dart';
part 'screens/home.dart';
part 'screens/create_report.dart';
part 'screens/report_list.dart';
part 'screens/chat.dart';
part 'screens/chat_detail.dart';
part 'screens/profile_nav.dart';
part 'screens/profile_edit.dart';
part 'widgets/header.dart';
part 'widgets/bottom_nav.dart';
part 'widgets/form_controls.dart';
part 'widgets/photo_picker.dart';
part 'widgets/report_cards.dart';
part 'widgets/chat_widgets.dart';

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
  String _campusKey = 'admin1';
  Uint8List? _profilePhoto;

  static const List<CampusLocation> _defaultLocations = [
    CampusLocation(name: 'Perpustakaan LSI'),
    CampusLocation(name: 'Gedung Rektorat'),
    CampusLocation(name: 'Kantin Rektorat'),
    CampusLocation(name: 'Gedung Kuliah A1'),
    CampusLocation(name: 'Masjid Kampus'),
    CampusLocation(name: 'Parkiran Fakultas'),
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

  List<CampusLocation> _locations = [..._defaultLocations];

  final List<Report> _reports = [];

  final List<ChatThread> _chats = [
    ChatThread(name: 'Admin Kampus', role: 'Admin', messages: []),
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

    final chatCount = _chats.where((chat) => chat.hasUnread).length;
    final reportCount = _reports
        .where((report) => report.hasUnreadUpdate)
        .length;
    Widget badgeIcon(IconData icon, int count) => count > 0
        ? Badge(label: Text('$count'), child: Icon(icon))
        : Icon(icon);

    final pages = [
      _HomePage(
        reports: _reports
            .where((item) => item.category == 'Barang Hilang')
            .toList(),
        tags: _tags,
        locations: _locations,
        onMessage: _openMessageToReporter,
      ),
      _ReportListPage(
        reports: _reports,
        onRefresh: _syncReportStatuses,
        refreshKey: _nim,
      ),
      _CreateReportPage(
        tags: _tags,
        locations: _locations,
        onSubmit: _addReport,
      ),
      _ChatPage(chats: _chats, onOpen: _openChat),
      _ProfileNavPage(
        name: _name,
        email: _email,
        nim: _nim,
        profilePhoto: _profilePhoto,
        reports: _reports,
        onSave: (name, email, nim, photo) {
          setState(() {
            _name = name;
            _email = email;
            _nim = nim;
            _profilePhoto = photo ?? _profilePhoto;
          });
        },
        onLogout: _logoutFromNav,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
            if (value == 1) {
              for (final report in _reports) {
                report.hasUnreadUpdate = false;
              }
            }
            if (value == 3) {
              for (final chat in _chats) {
                chat.hasUnread = false;
              }
            }
          });
          if (value == 1) {
            _syncReportStatuses();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: badgeIcon(Icons.assignment_outlined, reportCount),
            selectedIcon: badgeIcon(Icons.assignment, reportCount),
            label: 'Laporan',
          ),
          const NavigationDestination(
            icon: _CreateNavIcon(active: false),
            selectedIcon: _CreateNavIcon(active: true),
            label: 'Buat',
          ),
          NavigationDestination(
            icon: badgeIcon(Icons.chat_bubble_outline, chatCount),
            selectedIcon: badgeIcon(Icons.chat_bubble, chatCount),
            label: 'Pesan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _addReport(Report report) {
    setState(() {
      _reports.insert(0, report);
      _index = 1;
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
              Uri.parse(
                '$base/api/${report.category == 'Fasilitas Rusak' ? 'laporan-fasilitas' : 'laporan-barang'}',
              ),
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
            .get(Uri.parse('$base/api/mobile/reports/$_nim'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 400) continue;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['reports'] as List<dynamic>? ?? [];
        final serverReports = <Report>[];
        final serverKeys = <String>{};
        var changed = false;

        for (final item in items) {
          final report = item as Map<String, dynamic>;
          final title = report['title']?.toString() ?? '-';
          final category = report['category']?.toString() ?? 'Barang Hilang';
          final location = _locationLabel(
            report['location']?.toString() ?? '-',
          );
          final status = report['status']?.toString();
          final remoteId = report['id']?.toString();
          final local = _findMatchingLocalReport(
            remoteId: remoteId,
            title: title,
            category: category,
            location: location,
          );
          final hasStatusUpdate =
              local != null && status != null && local.status != status;
          final shouldNotify =
              showNotifications &&
              status != null &&
              [
                'Menunggu Diambil',
                'Sudah Diambil',
                'Sudah Diperbaiki',
                'Selesai',
                'Barang Dihapus',
              ].contains(status) &&
              (local == null || hasStatusUpdate);

          if (hasStatusUpdate || local == null) {
            changed = true;
          }
          if (shouldNotify) _showReportNotification(category, status);

          final photoData = report['photo_data']?.toString();
          serverReports.add(
            Report(
              title: title,
              category: category,
              location: location,
              tag: report['tag']?.toString() ?? 'Lainnya',
              status: status ?? local?.status ?? 'Aktif',
              date: _formatReportDate(report['created_at']),
              description: report['description']?.toString() ?? '',
              reporter: report['reporter_name']?.toString() ?? _name,
              photoBytes: _decodeReportPhoto(photoData) ?? local?.photoBytes,
              remoteId: remoteId,
              hasUnreadUpdate:
                  (local?.hasUnreadUpdate ?? false) ||
                  (shouldNotify && _index != 1),
            ),
          );
          serverKeys.add(_reportKey(title, category, location));
        }

        final localOnlyReports = _reports.where((report) {
          return report.remoteId == null &&
              !serverKeys.contains(
                _reportKey(report.title, report.category, report.location),
              );
        }).toList();

        if (changed ||
            serverReports.length + localOnlyReports.length != _reports.length) {
          if (mounted) {
            setState(() {
              _reports
                ..clear()
                ..addAll([...serverReports, ...localOnlyReports]);
            });
          }
        }
        return;
      } catch (_) {
        // Try next local address.
      }
    }
  }

  Report? _findMatchingLocalReport({
    required String? remoteId,
    required String title,
    required String category,
    required String location,
  }) {
    for (final report in _reports) {
      if (remoteId != null && report.remoteId == remoteId) return report;
    }
    for (final report in _reports) {
      if (_reportKey(report.title, report.category, report.location) ==
          _reportKey(title, category, location)) {
        return report;
      }
    }
    return null;
  }

  String _reportKey(String title, String category, String location) {
    return '${title.trim().toLowerCase()}|${category.trim().toLowerCase()}|${location.trim().toLowerCase()}';
  }

  String _locationLabel(String rawLocation) {
    final cleanLocation = rawLocation.trim();
    if (cleanLocation.isEmpty || cleanLocation == '-') return '-';
    if (cleanLocation.contains(' - ')) return cleanLocation;

    for (final location in _locations) {
      if (location.name.toLowerCase() == cleanLocation.toLowerCase()) {
        return location.label;
      }
    }

    return cleanLocation;
  }

  void _showReportNotification(String? category, String status) {
    final message = category == 'Fasilitas Rusak'
        ? 'Fasilitas telah diperbaiki.'
        : (status == 'Barang Dihapus'
              ? 'Laporan barang sudah dihapus oleh admin.'
              : status == 'Sudah Diambil'
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

    setState(() => chat.hasUnread = false);

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

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/api/chats'),
        headers: {'Accept': 'application/json'},
        body: {
          'sender_id': _nim,
          'sender_identifier': _nim,
          'sender_name': _name,
          'sender_role': 'civitas',
          'admin_username': _adminUsername,
          'campus_key': _campusKey,
          'receiver_id': _adminUsername,
          'receiver_name': 'Admin Kampus',
          'body': message,
        },
      );
      if (response.statusCode >= 400) {
        throw Exception('Gagal mengirim pesan');
      }
      await _syncAdminChat();
    } catch (_) {
      setState(
        () => chat.messages.removeWhere(
          (item) => item.isMine && item.body == message,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesan gagal dikirim ke server.')),
      );
    }
  }

  Future<void> _syncAdminChat() async {
    try {
      final uri = Uri.parse('$_apiBase/api/chats/$_nim').replace(
        queryParameters: {
          'admin_username': _adminUsername,
          'campus_key': _campusKey,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final thread = data['thread'] as Map<String, dynamic>?;
      if (thread == null) return;
      final adminChat = _chats.firstWhere(
        (chat) => chat.name == 'Admin Kampus',
      );
      final previousAdminMessageCount = adminChat.messages
          .where((message) => !message.isMine)
          .length;
      final messages = (thread['messages'] as List<dynamic>? ?? []).map((item) {
        final message = item as Map<String, dynamic>;
        return ChatMessage(
          body: message['body'].toString(),
          isMine: message['sender_role'] == 'civitas',
        );
      }).toList();
      final adminMessageCount = messages
          .where((message) => !message.isMine)
          .length;
      setState(() {
        adminChat.messages = messages;
        if (adminMessageCount > previousAdminMessageCount) {
          adminChat.hasUnread = true;
        }
      });
    } catch (_) {
      // Local demo remains usable if the Laravel server is offline.
    }
  }

  void _logoutFromNav() {
    setState(() {
      _isLoggedIn = false;
      _index = 0;
    });
  }

  void _login(Map<String, dynamic> user) {
    setState(() {
      _isLoggedIn = true;
      _name = (user['name'] ?? _name).toString();
      _email = (user['email'] ?? _email).toString();
      _nim = (user['identifier'] ?? user['nim'] ?? _nim).toString();
      _adminUsername = (user['admin_username'] ?? 'admin1').toString();
      _campusKey = (user['campus_key'] ?? user['kode_kampus'] ?? _adminUsername)
          .toString();
      final campusLocations = (user['locations'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final name = item['nama']?.toString().trim();
            if (name == null || name.isEmpty) return null;
            final area = item['area']?.toString().trim();

            return CampusLocation(
              name: name,
              area: area == null || area.isEmpty ? null : area,
            );
          })
          .whereType<CampusLocation>()
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
