part of '../main.dart';

class _CreateReportPage extends StatefulWidget {
  const _CreateReportPage({
    required this.tags,
    required this.locations,
    required this.onSubmit,
  });

  final List<String> tags;
  final List<CampusLocation> locations;
  final ValueChanged<Report> onSubmit;

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

  List<String> get _locationValues => widget.locations.isEmpty
      ? ['Belum ada lokasi']
      : widget.locations.map((location) => location.label).toList();

  String get _selectedLocation =>
      _locationValues.contains(_location) ? _location! : _locationValues.first;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Header(
          title: 'Buat Laporan',
          subtitle: 'Laporkan barang hilang atau fasilitas rusak',
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
                  _ModernFormDropdown(
                    label: 'Kategori',
                    value: _category,
                    values: const ['Barang Hilang', 'Fasilitas Rusak'],
                    icon: Icons.category_outlined,
                    onChanged: (value) =>
                        setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 12),
                  if (_category == 'Barang Hilang') ...[
                    _ModernFormDropdown(
                      label: 'Tag barang',
                      value: _tag,
                      values: widget.tags,
                      icon: Icons.sell_outlined,
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
                  _ModernFormDropdown(
                    label: 'Lokasi kejadian',
                    value: _selectedLocation,
                    values: _locationValues,
                    icon: Icons.place_outlined,
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
