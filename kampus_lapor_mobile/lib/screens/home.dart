part of '../main.dart';

class _HomePage extends StatefulWidget {
  const _HomePage({
    required this.reports,
    required this.tags,
    required this.locations,
    required this.onMessage,
  });

  final List<Report> reports;
  final List<String> tags;
  final List<CampusLocation> locations;
  final ValueChanged<Report> onMessage;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _query = '';
  String _tag = 'Semua';
  String _location = 'Semua';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.reports.where((report) {
      final matchQuery =
          report.title.toLowerCase().contains(_query.toLowerCase()) ||
          report.description.toLowerCase().contains(_query.toLowerCase()) ||
          report.tag.toLowerCase().contains(_query.toLowerCase());
      final matchTag = _tag == 'Semua' || report.tag == _tag;
      final matchLocation =
          _location == 'Semua' || report.location == _location;
      return matchQuery && matchTag && matchLocation;
    }).toList();

    return ListView(
      children: [
        _Header(
          title: 'Kampus Lapor',
          subtitle: 'Cari barang hilang dan hubungi pelapor',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: .08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari barang hilang...',
                    hintStyle: TextStyle(color: Color(0xFF8A7BA3)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF7C3AED)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      value: _tag,
                      values: ['Semua', ...widget.tags],
                      icon: Icons.sell_outlined,
                      onChanged: (v) => setState(() => _tag = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterDropdown(
                      value: _location,
                      values: [
                        'Semua',
                        ...widget.locations.map((location) => location.label),
                      ],
                      icon: Icons.place_outlined,
                      onChanged: (v) => setState(() => _location = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Barang Hilang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...filtered.map(
                (report) => _LostItemCard(
                  report: report,
                  onMessage: () => widget.onMessage(report),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
