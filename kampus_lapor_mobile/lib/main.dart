import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const CampusLaporApp());
}

class CampusLaporApp extends StatelessWidget {
  const CampusLaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Lapor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const purple = Color(0xFF823BE8);
  static const purpleDark = Color(0xFF6E2FDB);
  static const background = Color(0xFFF3ECFF);
  static const field = Color(0xFFF9FCFF);
  static const text = Color(0xFF182033);
  static const muted = Color(0xFF8F8A99);
  static const shadow = Color(0x33000000);
}

const itemTagOptions = [
  'HP',
  'Dompet',
  'Botol',
  'Laptop',
  'Kunci',
  'Kartu Mahasiswa',
  'Charger',
  'Headset',
  'Buku',
  'Peralatan Tulis',
  'Tas',
  'Payung',
  'Jaket',
  'Sepatu',
  'Jam Tangan',
  'Flashdisk',
  'Kacamata',
];

const facilityTagOptions = [
  'Komputer',
  'Bangku',
  'Meja',
  'AC',
  'Proyektor',
  'Lampu',
  'Pintu',
  'Kipas',
  'Toilet',
  'WiFi',
  'Listrik',
  'Keran',
];

class AppSession {
  static String? token;
  static Map<String, dynamic>? user;

  static String? get campusId => user?['campus_id']?.toString();
}

class ApiClient {
  ApiClient._();

  static final instance = ApiClient._();

  String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _request('GET', path, query: query);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) {
    return _request('PATCH', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _request('DELETE', path);
  }

  Future<dynamic> multipartPost(
    String path, {
    required Map<String, String> fields,
    Map<String, List<String>> listFields = const {},
    XFile? file,
    String fileField = 'image',
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      if (AppSession.token != null) {
        request.headers['Authorization'] = 'Bearer ${AppSession.token}';
      }
      request.fields.addAll(fields);
      for (final entry in listFields.entries) {
        for (var index = 0; index < entry.value.length; index++) {
          request.fields['${entry.key}[$index]'] = entry.value[index];
        }
      }

      if (file != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            await file.readAsBytes(),
            filename: file.name,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Request gagal (${response.statusCode})';
        throw ApiException(message);
      }

      return data;
    } on http.ClientException {
      throw ApiException(
        'Tidak bisa terhubung ke server. Pastikan Laravel sedang jalan.',
      );
    }
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (AppSession.token != null)
          'Authorization': 'Bearer ${AppSession.token}',
      };

      final encodedBody = body == null ? null : jsonEncode(body);
      final response = switch (method) {
        'GET' => await http.get(uri, headers: headers),
        'POST' => await http.post(uri, headers: headers, body: encodedBody),
        'PATCH' => await http.patch(uri, headers: headers, body: encodedBody),
        'DELETE' => await http.delete(uri, headers: headers),
        _ => throw ApiException('Method API tidak didukung.'),
      };

      final responseBody = response.body;
      final data = responseBody.isEmpty ? null : jsonDecode(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Request gagal (${response.statusCode})';
        throw ApiException(message);
      }

      return data;
    } on http.ClientException {
      throw ApiException(
        'Tidak bisa terhubung ke server. Pastikan Laravel sedang jalan.',
      );
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

String errorText(Object error) {
  return error is ApiException ? error.message : error.toString();
}

class DemoData {
  static final posts = <ReportPost>[
    ReportPost(
      name: 'Siti',
      username: '@siti1432',
      time: '5 jam lalu',
      description: 'Dicari Botol tumbler hilang, hilang di cb prog.',
      location: 'CB Prog, Kampus Cilibende',
      tags: ['Botol', 'Tumbler', 'CB PROG'],
      imageStyle: 0,
    ),
    ReportPost(
      name: 'Adam Terry',
      username: '@adamterry15',
      time: '20 jam lalu',
      description:
          'Dicari Hape warna biru, hilang di cb kom 2. HP Vivo seri A59 Pro. Yang ketemu tolong banget.',
      location: 'CB KOM 2, Kampus Cilibende',
      tags: ['HP', 'Handphone', 'CB KOM'],
      imageStyle: 1,
    ),
  ];

  static final chats = <ChatPreview>[
    ChatPreview(
      'Santi',
      '@santi154',
      'Barangnya ketemu di Cb Prog, Cilibend..',
      2,
    ),
    ChatPreview('Siti', '@siti1432', 'Oke Terimakasih infonya', 0),
    ChatPreview('Admin IPB', '', 'Barangnya ketemu silahkan diambil', 3),
    ChatPreview(
      'Siti',
      '@siti1432',
      'Lorem ipsum dolor sit amet, consectetur...',
      0,
    ),
    ChatPreview(
      'Siti',
      '@siti1432',
      'Lorem ipsum dolor sit amet, consectetur...',
      0,
    ),
  ];

  static const notifications = [
    ['Pesan baru dari Santi', 'Barangnya ketemu di Cb Prog, Cilibend..'],
    ['Barang anda ditemukan!', 'Silahkan ambil di bengkong'],
    ['Pesan baru dari Admin', 'Barangnya ketemu silahkan diambil'],
  ];
}

class ReportPost {
  ReportPost({
    this.id,
    this.userId,
    required this.name,
    required this.username,
    required this.time,
    required this.description,
    required this.location,
    required this.tags,
    required this.imageStyle,
    this.imageUrl,
  });

  final String? id;
  final String? userId;
  final String name;
  final String username;
  final String time;
  final String description;
  final String location;
  final List<String> tags;
  final int imageStyle;
  final String? imageUrl;

  factory ReportPost.fromApi(Map<String, dynamic> json, int index) {
    final user = Map<String, dynamic>.from((json['user'] ?? {}) as Map);
    final location = Map<String, dynamic>.from((json['location'] ?? {}) as Map);
    final category = json['category']?.toString() ?? 'lost_item';

    return ReportPost(
      id: json['id']?.toString(),
      userId: user['id']?.toString(),
      name: user['name']?.toString() ?? 'User',
      username: '@${user['username']?.toString() ?? 'user'}',
      time: relativeTime(json['created_at']?.toString()),
      description: json['description']?.toString() ?? '-',
      location: location['name']?.toString() ?? 'Lokasi kampus',
      tags: (json['tags'] is List && (json['tags'] as List).isNotEmpty)
          ? (json['tags'] as List).map((tag) => tag.toString()).toList()
          : category == 'lost_item'
          ? ['Barang', json['status']?.toString() ?? 'lost']
          : ['Fasilitas', json['status']?.toString() ?? 'damaged'],
      imageStyle: index.isEven ? 0 : 1,
      imageUrl: normalizeImageUrl(json['image_url']?.toString()),
    );
  }
}

String? normalizeImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  final apiBase = ApiClient.instance.baseUrl;
  final server = apiBase.substring(0, apiBase.length - '/api'.length);
  return '$server$url';
}

class ChatPreview {
  ChatPreview(
    this.name,
    this.username,
    this.message,
    this.avatarStyle, {
    this.id,
    this.participantId,
    this.time = 'baru saja',
  });

  final String name;
  final String username;
  final String message;
  final int avatarStyle;
  final String? id;
  final String? participantId;
  final String time;

  factory ChatPreview.fromApi(Map<String, dynamic> json, int index) {
    final participant = Map<String, dynamic>.from(
      (json['participant'] ?? {}) as Map,
    );
    final latest = Map<String, dynamic>.from(
      (json['latest_message'] ?? {}) as Map,
    );

    return ChatPreview(
      participant['name']?.toString() ?? 'Civitas',
      '@${participant['username']?.toString() ?? 'user'}',
      latest['body']?.toString() ?? 'Belum ada pesan',
      index % 4,
      id: json['id']?.toString(),
      participantId: participant['id']?.toString(),
      time: relativeTime(
        latest['created_at']?.toString() ?? json['updated_at']?.toString(),
      ),
    );
  }
}

class ChatMessage {
  ChatMessage({required this.id, required this.senderId, required this.body});

  final String id;
  final String senderId;
  final String body;

  factory ChatMessage.fromApi(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      body: json['body']?.toString() ?? '',
    );
  }
}

class AppNotice {
  AppNotice({
    this.id,
    required this.title,
    required this.body,
    this.time = 'baru saja',
  });

  final String? id;
  final String title;
  final String body;
  final String time;

  factory AppNotice.fromApi(Map<String, dynamic> json) {
    return AppNotice(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '-',
      body: json['body']?.toString() ?? '-',
      time: relativeTime(json['created_at']?.toString()),
    );
  }
}

String relativeTime(String? isoDate) {
  final parsed = isoDate == null ? null : DateTime.tryParse(isoDate);
  if (parsed == null) return 'baru saja';

  final diff = DateTime.now().difference(parsed.toLocal());
  if (diff.inSeconds < 60) return 'baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';

  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PurpleShell(
      child: Column(
        children: [
          const Spacer(flex: 4),
          const BrandLogo(size: 46),
          const Spacer(flex: 3),
          SizedBox(
            width: 235,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.field,
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              ),
              child: const Text(
                'Get Start',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController(text: 'siti432@apps.ipb.ac.id');
  final passwordController = TextEditingController(text: 'password');
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final response =
          await ApiClient.instance.post('/auth/login', {
                'email': emailController.text.trim(),
                'password': passwordController.text,
              })
              as Map<String, dynamic>;

      final data = response['data'] as Map<String, dynamic>;
      AppSession.token = data['token'].toString();
      AppSession.user = Map<String, dynamic>.from(data['user'] as Map);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(context, title: 'Login gagal', message: errorText(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hello!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 39,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 32),
          AuthField(hint: 'Email kampus', controller: emailController),
          const SizedBox(height: 14),
          AuthField(
            hint: 'Password',
            obscure: true,
            controller: passwordController,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showAppDialog(
                context,
                title: 'Reset password',
                message:
                    'Nanti fitur ini akan mengirim link reset ke email kampus kamu.',
              ),
              child: const Text(
                'Lupa password?',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: loading ? 'Loading...' : 'Sign In',
            onTap: loading ? () {} : login,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Belum punya akun? ',
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    color: AppColors.purpleDark,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  List<Map<String, dynamic>> campuses = [];
  String? campusId;
  bool loadingCampuses = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCampuses();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> loadCampuses() async {
    try {
      final response = await ApiClient.instance.get('/campuses') as Map;
      final data = response['data'] as List;
      campuses = data.map((item) => Map<String, dynamic>.from(item)).toList();
      campusId = campuses.isNotEmpty ? campuses.first['id']?.toString() : null;
    } catch (_) {
      campuses = [];
    } finally {
      if (mounted) setState(() => loadingCampuses = false);
    }
  }

  Future<void> register() async {
    if (campusId == null) {
      showAppDialog(
        context,
        title: 'Kampus belum ada',
        message: 'Belum ada kampus yang disetujui superadmin.',
      );
      return;
    }

    setState(() => loading = true);
    try {
      final response =
          await ApiClient.instance.post('/auth/register', {
                'campus_id': campusId,
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'username': usernameController.text.trim(),
                'password': passwordController.text,
                'password_confirmation': confirmController.text,
              })
              as Map<String, dynamic>;

      final data = response['data'] as Map<String, dynamic>;
      AppSession.token = data['token'].toString();
      AppSession.user = Map<String, dynamic>.from(data['user'] as Map);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(context, title: 'Daftar gagal', message: errorText(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hello!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 39,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          AuthField(hint: 'Nama', controller: nameController),
          const SizedBox(height: 13),
          AuthField(hint: 'Email kampus anda', controller: emailController),
          const SizedBox(height: 13),
          CampusSelect(
            loading: loadingCampuses,
            campuses: campuses,
            value: campusId,
            onChanged: (value) => setState(() => campusId = value),
          ),
          const SizedBox(height: 13),
          AuthField(hint: 'Buat username', controller: usernameController),
          const SizedBox(height: 13),
          AuthField(
            hint: 'Buat password',
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 13),
          AuthField(
            hint: 'Konfirmasi password',
            obscure: true,
            controller: confirmController,
          ),
          const SizedBox(height: 40),
          PrimaryButton(
            label: loading ? 'Loading...' : 'Sign Up',
            onTap: loading ? () {} : register,
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  int notificationRefreshToken = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenSearch: () => setState(() => index = 5)),
      const ChatListScreen(),
      const ReportChoiceScreen(),
      NotificationScreen(refreshToken: notificationRefreshToken),
      const AccountScreen(),
      const SearchScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: index == 2 || index == 5
          ? null
          : FloatingBottomNav(
              currentIndex: index,
              onTap: (value) => setState(() {
                index = value;
                if (value == 3) {
                  notificationRefreshToken++;
                }
              }),
            ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ReportPost>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = loadReports();
  }

  Future<List<ReportPost>> loadReports() async {
    final response = await ApiClient.instance.get('/reports') as Map;
    final data = response['data'] as List;
    return [
      for (var i = 0; i < data.length; i++)
        ReportPost.fromApi(Map<String, dynamic>.from(data[i] as Map), i),
    ];
  }

  Future<void> refresh() async {
    final nextReports = loadReports();
    setState(() {
      reportsFuture = nextReports;
    });
    await reportsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: Column(
        children: [
          PurpleHeader(
            height: 108,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
              child: SearchPill(onTap: widget.onOpenSearch),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ReportPost>>(
              future: reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: errorText(snapshot.error!),
                    onRetry: () {
                      final nextReports = loadReports();
                      setState(() {
                        reportsFuture = nextReports;
                      });
                    },
                  );
                }

                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return const Center(child: Text('Belum ada laporan.'));
                }

                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 105),
                    itemBuilder: (_, itemIndex) =>
                        ReportCard(post: posts[itemIndex]),
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemCount: posts.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.refreshToken});

  final int refreshToken;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<AppNotice>> noticesFuture;

  @override
  void initState() {
    super.initState();
    noticesFuture = loadNotices();
  }

  @override
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      final nextNotices = loadNotices();
      setState(() {
        noticesFuture = nextNotices;
      });
    }
  }

  Future<List<AppNotice>> loadNotices() async {
    final response = await ApiClient.instance.get('/notifications') as Map;
    final data = response['data'] as List;
    return data
        .map(
          (notice) =>
              AppNotice.fromApi(Map<String, dynamic>.from(notice as Map)),
        )
        .toList();
  }

  Future<void> openNotice(AppNotice notice) async {
    if (notice.id != null) {
      try {
        await ApiClient.instance.patch('/notifications/${notice.id}/read', {});
      } catch (_) {}
    }

    if (!mounted) return;
    if (notice.title.toLowerCase().contains('admin')) {
      try {
        final response = await ApiClient.instance.post('/chats/admin', {
          'message': 'Halo Admin, saya membuka notifikasi: ${notice.title}',
        });
        final data = Map<String, dynamic>.from(
          (response as Map<String, dynamic>)['data'] as Map,
        );
        final chat = ChatPreview.fromApi(data, 0);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)),
        );
        return;
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Notifikasi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: FutureBuilder<List<AppNotice>>(
                future: noticesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                      message: errorText(snapshot.error!),
                      onRetry: () {
                        final nextNotices = loadNotices();
                        setState(() {
                          noticesFuture = nextNotices;
                        });
                      },
                    );
                  }
                  final notices = snapshot.data ?? [];
                  if (notices.isEmpty) {
                    return const Center(child: Text('Belum ada notifikasi.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    itemCount: notices.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, itemIndex) {
                      final item = notices[itemIndex];
                      return NotificationCard(
                        title: item.title,
                        body: item.body,
                        time: item.time,
                        onTap: () => openNotice(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool history = false;

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: Column(
        children: [
          const PurpleHeader(
            height: 108,
            child: Center(child: BrandLogo(size: 20)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(34, 22, 34, 16),
            child: SegmentedTabs(
              left: 'Akun',
              right: 'History',
              rightActive: history,
              onLeft: () => setState(() => history = false),
              onRight: () => setState(() => history = true),
            ),
          ),
          Expanded(child: history ? const HistoryList() : const ProfilePanel()),
        ],
      ),
    );
  }
}

class ReportChoiceScreen extends StatefulWidget {
  const ReportChoiceScreen({super.key});

  @override
  State<ReportChoiceScreen> createState() => _ReportChoiceScreenState();
}

class _ReportChoiceScreenState extends State<ReportChoiceScreen> {
  bool barang = false;

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PurpleHeader(
            height: 106,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 28,
                    child: IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Center(child: BrandLogo(size: 20)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
            child: SegmentedTabs(
              left: 'Fasilitas',
              right: 'Barang',
              rightActive: barang,
              onLeft: () => setState(() => barang = false),
              onRight: () => setState(() => barang = true),
            ),
          ),
          Expanded(child: barang ? const ItemForm() : const FacilityForm()),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? selectedTag;
  Future<List<ReportPost>>? resultsFuture;

  void search(String tag) {
    setState(() {
      selectedTag = tag;
      resultsFuture = loadResults(tag);
    });
  }

  Future<List<ReportPost>> loadResults(String tag) async {
    final response =
        await ApiClient.instance.get('/reports', query: {'q': tag}) as Map;
    final data = response['data'] as List;
    return [
      for (var i = 0; i < data.length; i++)
        ReportPost.fromApi(Map<String, dynamic>.from(data[i] as Map), i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: Column(
        children: [
          PurpleHeader(
            height: 108,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 17, 12, 18),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: SearchPill(
                        value: selectedTag,
                        onTap: () => setState(() {
                          selectedTag = null;
                          resultsFuture = null;
                        }),
                        trailing: selectedTag == null
                            ? Icons.search
                            : Icons.close,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: selectedTag != null
                ? FutureBuilder<List<ReportPost>>(
                    future: resultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return ErrorState(
                          message: errorText(snapshot.error!),
                          onRetry: () => search(selectedTag!),
                        );
                      }
                      final posts = snapshot.data ?? [];
                      if (posts.isEmpty) {
                        return Center(
                          child: Text('Tidak ada hasil untuk $selectedTag.'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 22, 12, 24),
                        itemCount: posts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            ReportCard(post: posts[index]),
                      );
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(26, 22, 20, 0),
                    children: [
                      const Text(
                        'Pilih kategori pencarian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...itemTagOptions.map(
                            (tag) => ChoiceChip(
                              label: Text(tag),
                              selected: false,
                              onSelected: (_) => search(tag),
                            ),
                          ),
                          ...facilityTagOptions.map(
                            (tag) => ChoiceChip(
                              label: Text(tag),
                              selected: false,
                              onSelected: (_) => search(tag),
                            ),
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

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatPreview>> chatsFuture;

  @override
  void initState() {
    super.initState();
    chatsFuture = loadChats();
  }

  Future<List<ChatPreview>> loadChats() async {
    final response = await ApiClient.instance.get('/chats') as Map;
    final data = response['data'] as List;
    return [
      for (var i = 0; i < data.length; i++)
        ChatPreview.fromApi(Map<String, dynamic>.from(data[i] as Map), i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MobilePage(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Pesan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: FutureBuilder<List<ChatPreview>>(
                future: chatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                      message: errorText(snapshot.error!),
                      onRetry: () {
                        final nextChats = loadChats();
                        setState(() {
                          chatsFuture = nextChats;
                        });
                      },
                    );
                  }
                  final chats = snapshot.data ?? [];
                  if (chats.isEmpty) {
                    return const Center(child: Text('Belum ada pesan.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 105),
                    itemCount: chats.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, itemIndex) {
                      final chat = chats[itemIndex];
                      return ChatTile(
                        chat: chat,
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(chat: chat),
                              ),
                            ).then((_) {
                              final nextChats = loadChats();
                              setState(() {
                                chatsFuture = nextChats;
                              });
                            }),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chat});

  final ChatPreview chat;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late Future<List<ChatMessage>> messagesFuture;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    messagesFuture = loadMessages();
  }

  Future<List<ChatMessage>> loadMessages() async {
    final response =
        await ApiClient.instance.get('/chats/${widget.chat.id}') as Map;
    final data = (response['data'] as Map)['messages'] as List;
    return data
        .map(
          (message) =>
              ChatMessage.fromApi(Map<String, dynamic>.from(message as Map)),
        )
        .toList();
  }

  Future<void> sendMessage(String message) async {
    if (widget.chat.id == null || message.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await ApiClient.instance.post('/chats/${widget.chat.id}/messages', {
        'message': message.trim(),
      });
      if (!mounted) return;
      final nextMessages = loadMessages();
      setState(() {
        messagesFuture = nextMessages;
      });
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Gagal kirim pesan',
        message: errorText(error),
      );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MobileFrame(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 22, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    Avatar(style: widget.chat.avatarStyle, size: 40),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chat.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          widget.chat.username,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ChatMessage>>(
                  future: messagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ErrorState(
                        message: errorText(snapshot.error!),
                        onRetry: () {
                          final nextMessages = loadMessages();
                          setState(() {
                            messagesFuture = nextMessages;
                          });
                        },
                      );
                    }
                    final messages = snapshot.data ?? [];
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
                      itemCount: messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final mine =
                            message.senderId ==
                            AppSession.user?['id']?.toString();
                        if (mine) {
                          return ChatBubble(text: message.body, mine: true);
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Avatar(style: widget.chat.avatarStyle, size: 30),
                            const SizedBox(width: 8),
                            ChatBubble(text: message.body, mine: false),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              MessageComposer(onSend: sendMessage, sending: sending),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class PurpleShell extends StatelessWidget {
  const PurpleShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileFrame(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple, AppColors.purpleDark],
            ),
          ),
          child: SafeArea(child: child),
        ),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileFrame(
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple, AppColors.purpleDark],
                ),
              ),
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 45, left: 84),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: BrandLogo(size: 40),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                transform: Matrix4.translationValues(0, -1, 0),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(58, 58, 58, 28),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 390 ? constraints.maxWidth : 390.0;

        return Center(
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

class MobilePage extends StatelessWidget {
  const MobilePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Container(color: AppColors.background, child: child),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Campus\nLapor',
          style: TextStyle(
            color: Colors.white,
            height: .9,
            fontSize: size,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.notifications_active, color: Colors.white, size: size * .72),
      ],
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.controller,
  });

  final String hint;
  final bool obscure;
  final IconData? suffix;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.field,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA2A0A8)),
          suffixIcon: suffix == null
              ? null
              : Icon(suffix, color: AppColors.text),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CampusSelect extends StatelessWidget {
  const CampusSelect({
    super.key,
    required this.loading,
    required this.campuses,
    required this.value,
    required this.onChanged,
  });

  final bool loading;
  final List<Map<String, dynamic>> campuses;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const AuthField(hint: 'Memuat kampus...');
    }

    return SizedBox(
      height: 49,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: campuses
            .map(
              (campus) => DropdownMenuItem<String>(
                value: campus['id']?.toString(),
                child: Text(campus['name'].toString()),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.field,
          hintText: 'Kampus',
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class PurpleHeader extends StatelessWidget {
  const PurpleHeader({super.key, required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SearchPill extends StatelessWidget {
  const SearchPill({
    super.key,
    this.onTap,
    this.value,
    this.trailing = Icons.search,
  });

  final VoidCallback? onTap;
  final String? value;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Cari',
                style: TextStyle(
                  color: value == null ? AppColors.muted : AppColors.text,
                ),
              ),
            ),
            Icon(trailing, size: 18, color: AppColors.text),
          ],
        ),
      ),
    );
  }
}

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavButton(
                    icon: Icons.home_outlined,
                    active: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  NavButton(
                    icon: Icons.chat_bubble_outline,
                    active: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 58),
                  NavButton(
                    icon: Icons.notifications_none,
                    active: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  NavButton(
                    icon: Icons.person_outline,
                    active: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 4),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: active ? Colors.white : const Color(0xFFBBA2F2)),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.post, this.onDeleted});

  final ReportPost post;
  final VoidCallback? onDeleted;

  Future<void> openMessage(BuildContext context) async {
    final currentUserId = AppSession.user?['id'];
    final isOwnReport = post.userId == null || post.userId == currentUserId;

    try {
      final response = isOwnReport
          ? await ApiClient.instance.post('/chats/admin', {
              'message':
                  'Halo Admin, saya mau menanyakan laporan saya: ${post.description}',
            })
          : await ApiClient.instance.post('/chats', {
              'user_id': post.userId,
              'message':
                  'Halo ${post.name}, saya ingin membantu soal laporan ini.',
            });

      final data = Map<String, dynamic>.from(
        (response as Map<String, dynamic>)['data'] as Map,
      );
      final chat = ChatPreview.fromApi(data, 0);

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppDialog(
        context,
        title: 'Gagal buka pesan',
        message: errorText(error),
      );
    }
  }

  Future<void> deleteReport(BuildContext context) async {
    if (post.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: const Text('Laporan akan dihapus permanen dari server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiClient.instance.delete('/reports/${post.id}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dihapus.')),
      );
      onDeleted?.call();
    } catch (error) {
      if (!context.mounted) return;
      showAppDialog(
        context,
        title: 'Gagal menghapus',
        message: errorText(error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(style: post.imageStyle, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.text),
                    children: [
                      TextSpan(
                        text: post.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' ${post.username}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                post.time,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              post.description,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.purple,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    post.location,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: FakeReportImage(
              style: post.imageStyle,
              imageUrl: post.imageUrl,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      const Text(
                        'Tags:',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      ...post.tags.map((tag) => ChipTag(tag)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => openMessage(context),
                  tooltip: 'Kirim pesan',
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.send_outlined,
                    color: AppColors.purple,
                    size: 24,
                  ),
                ),
                if (onDeleted != null)
                  IconButton(
                    onPressed: () => deleteReport(context),
                    tooltip: 'Hapus laporan',
                    constraints: const BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.purple,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FakeReportImage extends StatelessWidget {
  const FakeReportImage({super.key, required this.style, this.imageUrl});

  final int style;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          imageUrl!,
          height: 172,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            height: 172,
            child: Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    final colors = style == 0
        ? const [
            Color(0xFFE7F2F4),
            Color(0xFFFF2848),
            Color(0xFFFFFFFF),
            Color(0xFF87D0DD),
          ]
        : const [
            Color(0xFF031B36),
            Color(0xFF04D4FF),
            Color(0xFF0C3D6F),
            Color(0xFF111827),
          ];

    return Container(
      height: 172,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [.05, .38, .62, 1],
        ),
      ),
      child: style == 0
          ? Center(
              child: Container(
                width: 74,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 8),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'DIRGAHAYU\nINDONESIA\n70',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.phone_iphone, size: 80, color: Colors.white70),
            ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.style, required this.size});

  final int style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = [
      const Color(0xFFCEEBC8),
      const Color(0xFF5BD0E8),
      const Color(0xFFEBD8CF),
      const Color(0xFF234A9A),
    ][style % 4];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(
        style == 3 ? Icons.school : Icons.person,
        color: Colors.white,
        size: size * .62,
      ),
    );
  }
}

class ChipTag extends StatelessWidget {
  const ChipTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    this.onTap,
  });

  final String title;
  final String body;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 14),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(body, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.left,
    required this.right,
    required this.rightActive,
    required this.onLeft,
    required this.onRight,
  });

  final String left;
  final String right;
  final bool rightActive;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SegmentButton(
            label: left,
            active: !rightActive,
            onTap: onLeft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SegmentButton(
            label: right,
            active: rightActive,
            onTap: onRight,
          ),
        ),
      ],
    );
  }
}

class SegmentButton extends StatelessWidget {
  const SegmentButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? AppColors.purple : Colors.transparent,
          foregroundColor: active ? Colors.white : AppColors.purple,
          side: const BorderSide(color: AppColors.purple),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key});

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  bool uploadingAvatar = false;

  Future<void> updateAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (image == null) return;

    final imageBytes = await image.readAsBytes();
    if (!mounted) return;

    final croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(imageBytes: imageBytes),
      ),
    );
    if (croppedBytes == null) return;

    setState(() => uploadingAvatar = true);
    try {
      final avatarFile = XFile.fromData(
        croppedBytes,
        name: 'avatar.png',
        mimeType: 'image/png',
      );
      final response =
          await ApiClient.instance.multipartPost(
                '/me/avatar',
                fields: const {},
                file: avatarFile,
                fileField: 'avatar',
              )
              as Map<String, dynamic>;
      final data = response['data'] as Map<String, dynamic>;
      AppSession.user = Map<String, dynamic>.from(data['user'] as Map);

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Gagal upload foto',
        message: errorText(error),
      );
    } finally {
      if (mounted) setState(() => uploadingAvatar = false);
    }
  }

  Future<void> editProfile() async {
    final user = AppSession.user ?? {};
    final nameController = TextEditingController(
      text: user['name']?.toString() ?? '',
    );
    final usernameController = TextEditingController(
      text: user['username']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: user['email']?.toString() ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit akun'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email kampus'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      final response =
          await ApiClient.instance.patch('/me', {
                'name': nameController.text.trim(),
                'username': usernameController.text.trim(),
                'email': emailController.text.trim(),
              })
              as Map<String, dynamic>;
      final data = response['data'] as Map<String, dynamic>;
      AppSession.user = Map<String, dynamic>.from(data['user'] as Map);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Gagal edit akun',
        message: errorText(error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.user ?? {};
    final campus = Map<String, dynamic>.from((user['campus'] ?? {}) as Map);
    final name = user['name']?.toString() ?? 'Civitas Kampus';
    final username = '@${user['username']?.toString() ?? 'username'}';
    final email = user['email']?.toString() ?? '-';
    final campusName = campus['name']?.toString() ?? 'Kampus';
    final avatarUrl = normalizeImageUrl(user['avatar_url']?.toString());

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              ProfileAvatar(
                imageUrl: avatarUrl,
                size: 104,
                loading: uploadingAvatar,
                onTap: uploadingAvatar ? null : updateAvatar,
              ),
              TextButton.icon(
                onPressed: uploadingAvatar ? null : updateAvatar,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(avatarUrl == null ? 'Tambah Foto' : 'Ganti Foto'),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(campusName, style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              ProfileField(
                label: 'Username',
                value: username,
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              ProfileField(label: 'Email', value: email, icon: Icons.email),
              const SizedBox(height: 32),
              SizedBox(
                width: 112,
                height: 38,
                child: FilledButton(
                  onPressed: editProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Akun'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.loading = false,
    this.onTap,
  });

  final double size;
  final String? imageUrl;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = imageUrl == null
        ? Avatar(style: 1, size: size)
        : ClipOval(
            child: Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Avatar(style: 1, size: size),
            ),
          );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: avatar),
            if (loading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0x66000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.field, width: 3),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCropScreen extends StatefulWidget {
  const ImageCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  late final Future<ui.Image> decodedImage;
  double scale = 1;
  double cropSize = 260;
  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;
  Offset startFocal = Offset.zero;
  double startScale = 1;

  @override
  void initState() {
    super.initState();
    decodedImage = decodeImage(widget.imageBytes);
  }

  Future<ui.Image> decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Offset clampOffset(Offset value, ui.Image image, [double? size]) {
    final currentSize = size ?? cropSize;
    final baseScale = math.max(
      currentSize / image.width,
      currentSize / image.height,
    );
    final renderedWidth = image.width * baseScale * scale;
    final renderedHeight = image.height * baseScale * scale;
    final maxX = math.max(0.0, (renderedWidth - currentSize) / 2);
    final maxY = math.max(0.0, (renderedHeight - currentSize) / 2);

    return Offset(
      value.dx.clamp(-maxX, maxX).toDouble(),
      value.dy.clamp(-maxY, maxY).toDouble(),
    );
  }

  Future<void> finishCrop(ui.Image image) async {
    final croppedBytes = await cropImage(image);
    if (!mounted) return;
    Navigator.pop(context, croppedBytes);
  }

  Future<Uint8List> cropImage(ui.Image image) async {
    const outputSize = 640;
    final baseScale = math.max(cropSize / image.width, cropSize / image.height);
    final effectiveScale = baseScale * scale;
    final sourceSize = cropSize / effectiveScale;
    final safeSourceSize = math.min(
      sourceSize,
      math.min(image.width.toDouble(), image.height.toDouble()),
    );
    final sourceX =
        ((image.width - safeSourceSize) / 2) - (offset.dx / effectiveScale);
    final sourceY =
        ((image.height - safeSourceSize) / 2) - (offset.dy / effectiveScale);
    final safeSourceX = sourceX
        .clamp(0.0, image.width - safeSourceSize)
        .toDouble();
    final safeSourceY = sourceY
        .clamp(0.0, image.height - safeSourceSize)
        .toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(safeSourceX, safeSourceY, safeSourceSize, safeSourceSize),
      Rect.fromLTWH(0, 0, outputSize.toDouble(), outputSize.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(outputSize, outputSize);
    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<ui.Image>(
          future: decodedImage,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final image = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      const Expanded(
                        child: Text(
                          'Atur Foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => finishCrop(image),
                        child: const Text(
                          'Pakai',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    cropSize = math.min(constraints.maxWidth - 52, 300.0);
                    final baseScale = math.max(
                      cropSize / image.width,
                      cropSize / image.height,
                    );
                    final baseWidth = image.width * baseScale;
                    final baseHeight = image.height * baseScale;
                    final displayOffset = clampOffset(offset, image, cropSize);

                    return Center(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          startOffset = offset;
                          startFocal = details.focalPoint;
                          startScale = scale;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            scale = (startScale * details.scale)
                                .clamp(1.0, 4.0)
                                .toDouble();
                            offset = clampOffset(
                              startOffset + details.focalPoint - startFocal,
                              image,
                              cropSize,
                            );
                          });
                        },
                        child: Container(
                          width: cropSize,
                          height: cropSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.purple,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: ColoredBox(
                              color: const Color(0xFFE9E0F8),
                              child: Center(
                                child: Transform.translate(
                                  offset: displayOffset,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: SizedBox(
                                      width: baseWidth,
                                      height: baseHeight,
                                      child: Image.memory(
                                        widget.imageBytes,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ukuran foto',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Slider(
                        value: scale,
                        min: 1,
                        max: 4,
                        activeColor: AppColors.purple,
                        onChanged: (value) {
                          setState(() {
                            scale = value;
                            offset = clampOffset(offset, image);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 26),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: () => finishCrop(image),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Pakai Foto',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Container(
          height: 37,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.muted),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(icon, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late Future<List<ReportPost>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = loadMine();
  }

  Future<List<ReportPost>> loadMine() async {
    final response = await ApiClient.instance.get('/reports/mine') as Map;
    final data = response['data'] as List;
    return [
      for (var i = 0; i < data.length; i++)
        ReportPost.fromApi(Map<String, dynamic>.from(data[i] as Map), i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReportPost>>(
      future: reportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
            message: errorText(snapshot.error!),
            onRetry: () {},
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('Belum ada riwayat laporan.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          itemCount: posts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (_, index) => ReportCard(
            post: posts[index],
            onDeleted: () => setState(() {
              reportsFuture = loadMine();
            }),
          ),
        );
      },
    );
  }
}

class FacilityForm extends StatelessWidget {
  const FacilityForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportFormContent(
      description:
          'Komputer di meja 20 tidak berfungsi dan dongle hilang. Di meja baris ke 2 dari depan.',
      location: 'CB KOM',
      uploadLabel: 'Upload bukti',
      buttonLabel: 'Kirim',
      showTags: false,
    );
  }
}

class ItemForm extends StatelessWidget {
  const ItemForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportFormContent(
      description:
          'laptop hilang di meja 20, laptop asus vivobook seri a142a0, setelah mata kuliah pemrograman mobile siang hari. Tolong yang menemukan plis.',
      location: 'CB KOM lantai 2',
      uploadLabel: 'Upload gambar\nbarang',
      buttonLabel: 'Unggah',
      showTags: true,
    );
  }
}

class ReportFormContent extends StatefulWidget {
  const ReportFormContent({
    super.key,
    required this.description,
    required this.location,
    required this.uploadLabel,
    required this.buttonLabel,
    required this.showTags,
  });

  final String description;
  final String location;
  final String uploadLabel;
  final String buttonLabel;
  final bool showTags;

  @override
  State<ReportFormContent> createState() => _ReportFormContentState();
}

class _ReportFormContentState extends State<ReportFormContent> {
  bool uploaded = false;
  bool loading = false;
  bool loadingLocations = true;
  late final TextEditingController descriptionController;
  List<Map<String, dynamic>> locations = [];
  List<String> selectedTags = [];
  XFile? pickedImage;
  String? locationId;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.description);
    loadLocations();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> loadLocations() async {
    try {
      final campusId = AppSession.campusId;
      if (campusId == null) return;

      final response =
          await ApiClient.instance.get('/campuses/$campusId/locations') as Map;
      final data = response['data'] as List;
      locations = data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      locationId = locations.isNotEmpty
          ? locations.first['id']?.toString()
          : null;
    } catch (_) {
      locations = [];
    } finally {
      if (mounted) setState(() => loadingLocations = false);
    }
  }

  Future<void> submitReport() async {
    if (locationId == null) {
      showAppDialog(
        context,
        title: 'Lokasi belum ada',
        message: 'Lokasi kampus belum tersedia dari server.',
      );
      return;
    }

    setState(() => loading = true);
    try {
      await ApiClient.instance.multipartPost(
        '/reports',
        fields: {
          'category': widget.showTags ? 'lost_item' : 'damaged_facility',
          'campus_location_id': locationId!,
          'title': widget.showTags
              ? (selectedTags.isEmpty
                    ? 'Barang hilang'
                    : '${selectedTags.first} hilang')
              : 'Fasilitas rusak',
          'description': descriptionController.text.trim(),
        },
        listFields: {'tags': selectedTags},
        file: pickedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.showTags
                ? 'Laporan barang berhasil dibuat.'
                : 'Laporan fasilitas berhasil dikirim.',
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Gagal mengirim',
        message: errorText(error),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagOptions = widget.showTags ? itemTagOptions : facilityTagOptions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
      children: [
        const FieldLabel('Deskripsi'),
        TextAreaBox(controller: descriptionController),
        const SizedBox(height: 18),
        const FieldLabel('Lokasi'),
        loadingLocations
            ? const SmallSelect(text: 'Memuat lokasi...')
            : LocationSelect(
                locations: locations,
                value: locationId,
                fallback: widget.location,
                onChanged: (value) => setState(() => locationId = value),
              ),
        if (widget.showTags) ...[
          const SizedBox(height: 18),
          const FieldLabel('Tags'),
          TagSelector(
            options: tagOptions,
            selected: selectedTags,
            onToggle: (tag) => setState(() {
              selectedTags.contains(tag)
                  ? selectedTags.remove(tag)
                  : selectedTags.add(tag);
            }),
          ),
        ],
        const SizedBox(height: 18),
        const FieldLabel('Gambar'),
        UploadBox(
          label: pickedImage == null ? widget.uploadLabel : pickedImage!.name,
          uploaded: uploaded,
          onTap: () async {
            final image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (image == null) return;
            setState(() {
              pickedImage = image;
              uploaded = true;
            });
          },
        ),
        const SizedBox(height: 46),
        Center(
          child: SizedBox(
            width: 202,
            height: 40,
            child: FilledButton(
              onPressed: loading ? null : submitReport,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                loading ? 'Mengirim...' : widget.buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class TextAreaBox extends StatelessWidget {
  const TextAreaBox({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.field,
        border: Border.all(color: AppColors.muted),
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        controller: controller,
        maxLength: 150,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterStyle: TextStyle(color: AppColors.muted, fontSize: 9),
        ),
        style: const TextStyle(color: AppColors.text, height: 1.35),
      ),
    );
  }
}

class TagSelector extends StatelessWidget {
  const TagSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.muted),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((tag) {
          final active = selected.contains(tag);
          return FilterChip(
            label: Text(tag),
            selected: active,
            selectedColor: AppColors.purple,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: active ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => onToggle(tag),
          );
        }).toList(),
      ),
    );
  }
}

class SmallSelect extends StatelessWidget {
  const SmallSelect({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        border: Border.all(color: AppColors.muted),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.muted)),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class LocationSelect extends StatelessWidget {
  const LocationSelect({
    super.key,
    required this.locations,
    required this.value,
    required this.fallback,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> locations;
  final String? value;
  final String fallback;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return SmallSelect(text: fallback);
    }

    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items: locations
            .map(
              (location) => DropdownMenuItem<String>(
                value: location['id']?.toString(),
                child: Text(
                  location['name'].toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.field,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class UploadBox extends StatelessWidget {
  const UploadBox({
    super.key,
    required this.label,
    required this.uploaded,
    required this.onTap,
  });

  final String label;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 126,
        decoration: BoxDecoration(
          color: uploaded ? const Color(0xFFD9F7E1) : const Color(0xFFB7B5F4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.purple, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: uploaded ? const Color(0xFF31B65F) : Colors.black,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  uploaded ? Icons.check : Icons.image,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchSuggestion extends StatelessWidget {
  const SearchSuggestion({
    super.key,
    required this.text,
    this.active = false,
    this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: active ? AppColors.text : AppColors.muted,
              size: 18,
            ),
            const SizedBox(width: 18),
            Text(
              text,
              style: TextStyle(
                color: active ? AppColors.text : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.chat, required this.onTap});

  final ChatPreview chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Avatar(style: chat.avatarStyle, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.text),
                      children: [
                        TextSpan(
                          text: chat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: ' ${chat.username}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chat.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              chat.time,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.purple : AppColors.field,
          borderRadius: BorderRadius.circular(13),
          boxShadow: mine
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: mine ? Colors.white : AppColors.text,
            fontSize: 12,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    required this.sending,
  });

  final ValueChanged<String> onSend;
  final bool sending;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.muted),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showAppDialog(
              context,
              title: 'Kamera',
              message: 'Nanti tombol ini dipakai untuk melampirkan foto.',
            ),
            child: Container(
              width: 35,
              height: 35,
              margin: const EdgeInsets.only(left: 4),
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan ...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.sending
                ? null
                : () {
                    final message = controller.text.trim();
                    if (message.isEmpty) return;
                    widget.onSend(message);
                    controller.clear();
                  },
            icon: widget.sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined, color: AppColors.purple),
          ),
        ],
      ),
    );
  }
}

void showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
