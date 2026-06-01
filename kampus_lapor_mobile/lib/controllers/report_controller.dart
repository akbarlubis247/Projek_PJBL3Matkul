part of '../main.dart';

class _ReportController {
  final _CivitasHomePageState state;
  _ReportController(this.state);

  final List<Report> _reports = [];
  final List<Report> _lostItems = [];

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

  // Getters
  List<Report> get reports => _reports;
  List<Report> get lostItems => _lostItems;
  List<String> get tags => _tags;

  void _addReport(Report report) {
    state.updateState(() {
      _reports.insert(0, report);
      state._index = 4;
    });
    _sendReportToAdmin(report);
    ScaffoldMessenger.of(
      state.context,
    ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dibuat.')));
  }

  Future<void> _sendReportToAdmin(Report report) async {
    final photo = report.photoBytes == null
        ? null
        : 'data:image/jpeg;base64,${base64Encode(report.photoBytes!)}';

    try {
      final body = {
        'reporter_id': state.authController.nim,
        'reporter_name': state.authController.name,
        'category': report.category,
        'title': report.title,
        'location': report.location,
        'tag': report.tag,
        'description': report.description,
      };
      if (photo != null) body['photo_data'] = photo;

      final path = report.category == 'Fasilitas Rusak'
          ? 'laporan-fasilitas'
          : 'laporan-barang';

      final response = await state.authController.apiService.post(path, body);
      if (response.statusCode < 400) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        report.remoteId =
            (data['report'] as Map<String, dynamic>?)?['id']?.toString();
        return;
      }
    } catch (_) {
      // Offline fallback: report remains visible locally.
    }

    if (!state.mounted) return;
    ScaffoldMessenger.of(state.context).showSnackBar(
      const SnackBar(
        content: Text(
          'Laporan tersimpan di mobile, tapi belum terkirim ke admin.',
        ),
      ),
    );
  }

  Future<void> _syncReportStatuses({bool showNotifications = true}) async {
    try {
      final response = await state.authController.apiService.get('mobile/reports/${state.authController.nim}');
      if (response.statusCode >= 400) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['reports'] is List) ? (data['reports'] as List<dynamic>) : [];
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
        final reporterPhotoStr = report['reporter_photo']?.toString();
        serverReports.add(
          Report(
            title: title,
            category: category,
            location: location,
            tag: report['tag']?.toString() ?? 'Lainnya',
            status: status ?? local?.status ?? 'Aktif',
            date: _formatReportDate(report['created_at']),
            description: report['description']?.toString() ?? '',
            reporter: report['reporter_name']?.toString() ?? state.authController.name,
            photoBytes: _decodeReportPhoto(photoData) ?? local?.photoBytes,
            remoteId: remoteId,
            hasUnreadUpdate:
                (local?.hasUnreadUpdate ?? false) ||
                (shouldNotify && state._index != 1),
            reporterId: report['reporter_id']?.toString(),
            reporterPhoto: _decodeProfilePhoto(reporterPhotoStr) ?? local?.reporterPhoto,
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
        if (state.mounted) {
          state.updateState(() {
            _reports
              ..clear()
              ..addAll([...serverReports, ...localOnlyReports]);
          });
        }
      }
    } catch (_) {
      // Offline fallback
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

    for (final location in state.authController.locations) {
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
    if (!state.mounted) return;
    ScaffoldMessenger.of(
      state.context,
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

  Uint8List? _decodeProfilePhoto(String? photoData) {
    if (photoData == null || photoData.isEmpty) return null;
    try {
      final base64Str = photoData.contains(',') ? photoData.split(',').last : photoData;
      return base64Decode(base64Str);
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
    final reportReporterId = report.reporterId;
    if (reportReporterId == null || reportReporterId == state.authController.nim) {
      ScaffoldMessenger.of(state.context).showSnackBar(
        const SnackBar(content: Text('Anda tidak dapat memulai obrolan dengan diri sendiri.')),
      );
      return;
    }

    final existing = state.chatController.chats
        .where((chat) => chat.peerId == reportReporterId)
        .firstOrNull;
    final chat =
        existing ??
        ChatThread(
          name: report.reporter,
          role: 'Pelapor',
          peerId: reportReporterId,
          messages: [],
        );

    if (existing == null) {
      state.updateState(() => state.chatController._chats.insert(1, chat)); // Sisipkan setelah Admin Kampus
    }

    state.chatController._openChat(chat, initialMessage: existing == null ? 'Halo, saya ingin bertanya tentang ${report.title}.' : null);
  }

  Future<void> _markReportAsFound(Report report) async {
    final remoteId = report.remoteId;
    if (remoteId == null || remoteId.isEmpty) {
      state.updateState(() {
        report.status = 'Sudah Diambil';
      });
      ScaffoldMessenger.of(state.context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil ditandai ditemukan.')),
      );
      return;
    }

    // Optimistic update
    state.updateState(() {
      report.status = 'Sudah Diambil';
    });

    try {
      final response = await state.authController.apiService.patch(
        'laporan-barang/$remoteId/status',
        {'status': 'Sudah Diambil'},
      );
      if (response.statusCode < 400) {
        _syncReportStatuses(showNotifications: false);
        _syncLostItems();
        if (state.mounted) {
          ScaffoldMessenger.of(state.context).showSnackBar(
            const SnackBar(content: Text('Status laporan berhasil diperbarui.')),
          );
        }
        return;
      }
    } catch (_) {
      // Offline fallback
    }
  }

  Future<void> _syncLostItems() async {
    try {
      final response = await state.authController.apiService.get('laporan-barang?campus_key=${state.authController.campusKey}');
      if (response.statusCode >= 400) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['data'] is List) ? (data['data'] as List<dynamic>) : [];
      final serverLostItems = <Report>[];

      for (final item in items) {
        final report = item as Map<String, dynamic>;
        final title = report['title']?.toString() ?? '-';
        final category = report['category']?.toString() ?? 'Barang Hilang';
        final location = _locationLabel(
          report['location']?.toString() ?? '-',
        );
        final status = report['status']?.toString();
        final remoteId = report['id']?.toString();
        final photoData = report['photo_data']?.toString();
        final reporterPhotoStr = report['reporter_photo']?.toString();

        serverLostItems.add(
          Report(
            title: title,
            category: category,
            location: location,
            tag: report['tag']?.toString() ?? 'Lainnya',
            status: status ?? 'Aktif',
            date: _formatReportDate(report['created_at']),
            description: report['description']?.toString() ?? '',
            reporter: report['reporter_name']?.toString() ?? 'Civitas',
            photoBytes: _decodeReportPhoto(photoData),
            remoteId: remoteId,
            reporterId: report['reporter_id']?.toString(),
            reporterPhoto: _decodeProfilePhoto(reporterPhotoStr),
          ),
        );
      }

      if (state.mounted) {
        state.updateState(() {
          _lostItems
            ..clear()
            ..addAll(serverLostItems);
        });
      }
    } catch (_) {
      // Offline fallback
    }
  }
}
