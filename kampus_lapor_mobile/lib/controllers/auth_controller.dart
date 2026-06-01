part of '../main.dart';

class _AuthController {
  final _CivitasHomePageState state;
  _AuthController(this.state);

  static const _apiBases = [
    'http://127.0.0.1:8000',
    'http://localhost:8000',
    'http://10.0.2.2:8000',
  ];

  bool _isLoggedIn = false;
  String _name = 'Civitas Mobile 1';
  String _email = 'civitas1@kampus-lapor.test';
  String _nim = 'CV-0001';
  String _adminUsername = 'admin1';
  String _campusKey = 'admin1';
  String _token = '';
  Uint8List? _profilePhoto;
  late final ApiService _apiService = ApiService(apiBases: _apiBases);

  static const List<CampusLocation> _defaultLocations = [
    CampusLocation(name: 'Perpustakaan LSI'),
    CampusLocation(name: 'Gedung Rektorat'),
    CampusLocation(name: 'Kantin Rektorat'),
    CampusLocation(name: 'Gedung Kuliah A1'),
    CampusLocation(name: 'Masjid Kampus'),
    CampusLocation(name: 'Parkiran Fakultas'),
  ];

  List<CampusLocation> _locations = [..._defaultLocations];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get name => _name;
  String get email => _email;
  String get nim => _nim;
  String get adminUsername => _adminUsername;
  String get campusKey => _campusKey;
  String get token => _token;
  Uint8List? get profilePhoto => _profilePhoto;
  List<CampusLocation> get locations => _locations;
  ApiService get apiService => _apiService;

  void _login(Map<String, dynamic> user) {
    state.updateState(() {
      _isLoggedIn = true;
      _name = (user['name'] ?? _name).toString();
      _email = (user['email'] ?? _email).toString();
      _nim = (user['identifier'] ?? user['nim'] ?? _nim).toString();
      _adminUsername = (user['admin_username'] ?? 'admin1').toString();
      _campusKey = (user['campus_key'] ?? user['kode_kampus'] ?? _adminUsername)
          .toString();
      _token = (user['token'] ?? '').toString();
      _apiService.token = _token;

      final photoBase64 = user['profile_photo']?.toString();
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        try {
          _profilePhoto = base64Decode(photoBase64);
        } catch (_) {
          _profilePhoto = null;
        }
      } else {
        _profilePhoto = null;
      }

      final rawLocations = user['locations'];
      final campusLocations = (rawLocations is List)
          ? rawLocations
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
              .toList()
          : <CampusLocation>[];
      _locations = campusLocations.isNotEmpty
          ? campusLocations
          : [..._defaultLocations];

      state.reportController._reports.clear();
      state.chatController._chats
        ..clear()
        ..add(ChatThread(name: 'Admin Kampus', role: 'Admin', messages: []));
    });

    state.reportController._syncReportStatuses(showNotifications: false);
    state.reportController._syncLostItems();
    state.notificationController._syncNotifications();
    state.chatController._syncChats();
  }

  void _logoutFromNav() {
    state.updateState(() {
      _isLoggedIn = false;
      state._index = 0;
      _token = '';
      _apiService.token = '';
      _profilePhoto = null;
    });
  }

  Future<bool> _updateProfile(String name, String email, String nim, Uint8List? photo) async {
    state.updateState(() {
      _name = name;
      _email = email;
      _nim = nim;
      _profilePhoto = photo;
    });

    try {
      final photoBase64 = photo != null ? base64Encode(photo) : null;
      final body = {
        'name': name,
        'email': email,
        'nim': nim,
        'profile_photo': photoBase64,
      };

      final response = await _apiService.post('profile/update', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final u = data['user'] as Map<String, dynamic>;
        state.updateState(() {
          _name = (u['name'] ?? _name).toString();
          _email = (u['email'] ?? _email).toString();
          _nim = (u['identifier'] ?? u['nim'] ?? _nim).toString();
          final photoBase64 = u['profile_photo']?.toString();
          if (photoBase64 != null && photoBase64.isNotEmpty) {
            _profilePhoto = base64Decode(photoBase64);
          } else {
            _profilePhoto = null;
          }
        });
        return true;
      } else {
        throw Exception('Gagal menyimpan profil di server');
      }
    } catch (e) {
      if (state.mounted) {
        ScaffoldMessenger.of(state.context).showSnackBar(
          SnackBar(
            content: Text('Peringatan: Gagal sinkronisasi profil ke server: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
