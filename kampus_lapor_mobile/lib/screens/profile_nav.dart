part of '../main.dart';

class _ProfileNavPage extends StatefulWidget {
  const _ProfileNavPage({
    required this.name,
    required this.email,
    required this.nim,
    required this.profilePhoto,
    required this.reports,
    required this.onSave,
    required this.onLogout,
    this.onMarkAsFound,
  });

  final String name;
  final String email;
  final String nim;
  final Uint8List? profilePhoto;
  final List<Report> reports;
  final Future<bool> Function(String name, String email, String nim, Uint8List? photo) onSave;
  final VoidCallback onLogout;
  final ValueChanged<Report>? onMarkAsFound;

  @override
  State<_ProfileNavPage> createState() => _ProfileNavPageState();
}

class _ProfileNavPageState extends State<_ProfileNavPage> {
  late final _name = TextEditingController(text: widget.name);
  late final _email = TextEditingController(text: widget.email);
  late final _nim = TextEditingController(text: widget.nim);
  Uint8List? _photo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photo = widget.profilePhoto;
  }

  @override
  void didUpdateWidget(covariant _ProfileNavPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profilePhoto != oldWidget.profilePhoto) {
      _photo = widget.profilePhoto;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _nim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(
            title: 'Profil Civitas',
            subtitle: 'Kelola identitas diri dan riwayat laporan Anda',
          ),
          // Custom Segmented Control TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9D5FF).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF7C3AED),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Riwayat Laporan'),
                Tab(text: 'Pengaturan Akun'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // RIWAYAT LAPORAN TAB
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: widget.reports.isEmpty
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded, size: 48, color: Color(0xFFC4B5FD)),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada riwayat laporan.',
                                  style: TextStyle(color: Color(0xFF8A7BA3), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        ]
                      : widget.reports.map((report) {
                          final canMarkAsFound = report.category == 'Barang Hilang' &&
                              (report.status == 'Aktif' || report.status == 'Dilaporkan') &&
                              widget.onMarkAsFound != null;
                          return _ReportCard(
                            report: report,
                            trailing: canMarkAsFound
                                ? TextButton.icon(
                                    onPressed: () => widget.onMarkAsFound!(report),
                                    icon: const Icon(Icons.check_circle_rounded, size: 14),
                                    label: const Text(
                                      'Selesai',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF065F46),
                                      backgroundColor: const Color(0xFFD1FAE5),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        }).toList(),
                ),
                // PENGATURAN AKUN TAB
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    // Premium Camera Photo Picker Stack
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7C3AED),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFF5F3FF),
                              backgroundImage: _photo != null ? MemoryImage(_photo!) : null,
                              child: _photo == null
                                  ? Text(
                                      _name.text.isNotEmpty ? _name.text.substring(0, 1).toUpperCase() : 'C',
                                      style: const TextStyle(
                                        color: Color(0xFF7C3AED),
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickProfilePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7C3AED),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form fields
                    _buildField(
                      controller: _name,
                      label: 'Nama Lengkap',
                      icon: Icons.person_rounded,
                    ),
                    _buildField(
                      controller: _nim,
                      label: 'NIM / Nomor Identitas',
                      icon: Icons.badge_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    _buildField(
                      controller: _email,
                      label: 'Email Instansi/Kampus',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    // Simpan Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.24),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                setState(() {
                                  _isSaving = true;
                                });
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await widget.onSave(
                                  _name.text.trim(),
                                  _email.text.trim(),
                                  _nim.text.trim(),
                                  _photo,
                                );
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                  if (success) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Profil berhasil disimpan dan disinkronkan ke server.'),
                                        backgroundColor: Color(0xFF7C3AED),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: const Color(0xFFFEF2F2),
                        ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photo = bytes);
  }
}
