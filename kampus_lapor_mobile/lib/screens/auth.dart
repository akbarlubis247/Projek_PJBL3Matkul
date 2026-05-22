part of '../main.dart';

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
              Uri.parse(
                '$base/api/${_registerMode ? 'civitas/register' : 'auth/login/civitas'}',
              ),
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
