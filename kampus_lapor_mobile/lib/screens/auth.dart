part of '../main.dart';

class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({
    super.key,
    required this.onLogin,
    required this.apiService,
    this.initialRegisterMode = false,
  });

  final void Function(Map<String, dynamic> user) onLogin;
  final ApiService apiService;
  final bool initialRegisterMode;

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _registerMode = widget.initialRegisterMode;
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
                        width: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 18),
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
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: _showServerDialog,
                  icon: const Icon(Icons.dns_outlined, size: 16, color: Color(0xFF7C3AED)),
                  label: Text(
                    'Server: ${_serverLabel(widget.apiService.activeBase)}',
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _serverLabel(String url) {
    if (url.contains('railway.app')) return 'Cloud Railway (Aktif)';
    if (url.contains('192.168.')) return 'Wi-Fi Lokal (${url.replaceAll("http://", "")})';
    if (url.contains('10.0.2.2')) return 'Emulator Android';
    if (url.contains('127.0.0.1') || url.contains('localhost')) return 'Localhost';
    return url.isEmpty ? 'Default' : url;
  }

  void _showServerDialog() {
    final customController = TextEditingController(text: widget.apiService.activeBase);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pengaturan Server API', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pilih tujuan server backend untuk aplikasi mobile:'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_done, color: Color(0xFF7C3AED)),
              title: const Text('Cloud Railway (Rekomendasi)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: const Text('Langsung terhubung ke cloud tanpa perlu server lokal', style: TextStyle(fontSize: 11)),
              onTap: () {
                setState(() {
                  widget.apiService.setBaseUrl('https://web-admincampus-lapor.up.railway.app');
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.wifi, color: Color(0xFF0284C7)),
              title: const Text('Wi-Fi Lokal Laptop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: const Text('http://192.168.18.55:8000', style: TextStyle(fontSize: 11)),
              onTap: () {
                setState(() {
                  widget.apiService.setBaseUrl('http://192.168.18.55:8000');
                });
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: customController,
              decoration: const InputDecoration(
                labelText: 'URL Server Kustom',
                hintText: 'http://192.168.x.x:8000',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = customController.text.trim();
              if (newUrl.isNotEmpty) {
                setState(() {
                  widget.apiService.setBaseUrl(newUrl);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
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
      final response = await widget.apiService.postAuth(body, _registerMode);
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
    } catch (e) {
      final activeUrl = widget.apiService.activeBase;
      setState(
        () => _error =
            'Tidak bisa terhubung ke server ($activeUrl).\nPastikan koneksi internet aktif atau server lokal berjalan.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
