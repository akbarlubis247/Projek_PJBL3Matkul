part of '../main.dart';

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
