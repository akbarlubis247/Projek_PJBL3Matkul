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
  });

  final String name;
  final String email;
  final String nim;
  final Uint8List? profilePhoto;
  final List<Report> reports;
  final void Function(String name, String email, String nim, Uint8List? photo)
  onSave;
  final VoidCallback onLogout;

  @override
  State<_ProfileNavPage> createState() => _ProfileNavPageState();
}

class _ProfileNavPageState extends State<_ProfileNavPage> {
  late final _name = TextEditingController(text: widget.name);
  late final _email = TextEditingController(text: widget.email);
  late final _nim = TextEditingController(text: widget.nim);
  Uint8List? _photo;

  @override
  void initState() {
    super.initState();
    _photo = widget.profilePhoto;
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
            subtitle: 'Kelola akun dan riwayat laporan',
          ),
          Container(
            color: const Color(0xFFF5F3FF),
            child: const TabBar(
              tabs: [
                Tab(text: 'History'),
                Tab(text: 'Akun'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil disimpan.')),
                        );
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
        ],
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
