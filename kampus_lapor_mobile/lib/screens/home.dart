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
    // Saring laporan agar hanya menampilkan barang hilang yang berstatus "Aktif" di beranda
    final filtered = widget.reports.where((report) {
      if (report.status != 'Aktif') {
        return false;
      }
      
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
      physics: const BouncingScrollPhysics(),
      children: [
        // Premium brand bar ala Instagram/Twitter
        const _Header(
          title: 'Campus Lapor',
          subtitle: 'Cari barang hilang & hubungi pemiliknya secara instan',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Sleek
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: .06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari barang hilang...',
                    hintStyle: TextStyle(color: Color(0xFF8A7BA3), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF7C3AED), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Tag Berbentuk Chip/Pills Horizontal (Instagram style explore tags)
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    'Semua',
                    ...widget.tags,
                  ].map((tag) {
                    final isSelected = _tag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _tag = tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFDDD6FE),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Sleek Dropdown untuk Lokasi agar hemat tempat & elegan
              Row(
                children: [
                  const Icon(Icons.filter_list, color: Color(0xFF7C3AED), size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Filter Lokasi:',
                    style: TextStyle(
                      color: Color(0xFF2B2438),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _location,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7C3AED)),
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: Colors.white,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() => _location = value);
                            }
                          },
                          items: [
                            'Semua',
                            ...widget.locations.map((loc) => loc.label),
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Subtitle feed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Feed Barang Hilang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2B2438),
                    ),
                  ),
                  Text(
                    '${filtered.length} Laporan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A7BA3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Feed Cards List
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.feed_outlined, size: 48, color: Color(0xFFC4B5FD)),
                      SizedBox(height: 10),
                      Text(
                        'Tidak ada laporan barang hilang.',
                        style: TextStyle(color: Color(0xFF8A7BA3), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
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
