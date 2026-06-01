part of '../main.dart';

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case 'Aktif':
      case 'Dilaporkan':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        border = const Color(0xFFA7F3D0);
        break;
      case 'Menunggu Diambil':
      case 'Proses':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        border = const Color(0xFFFDE68A);
        break;
      case 'Sudah Diambil':
      case 'Selesai':
      case 'Sudah Diperbaiki':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        border = const Color(0xFFBFDBFE);
        break;
      default:
        bg = const Color(0xFFF8FAFC);
        fg = const Color(0xFF475569);
        border = const Color(0xFFE2E8F0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LostItemCard extends StatelessWidget {
  const _LostItemCard({required this.report, required this.onMessage});

  final Report report;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final hasImage = report.photoBytes != null;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE9D5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ala Instagram/Twitter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEDE9FE),
                  backgroundImage: report.reporterPhoto != null ? MemoryImage(report.reporterPhoto!) : null,
                  child: report.reporterPhoto == null
                      ? Text(
                          report.reporter.isNotEmpty ? report.reporter.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reporter,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: Color(0xFF2B2438),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              report.tag,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            report.date,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF8A7BA3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusLabel(status: report.status),
              ],
            ),
          ),
          
          // Image ala Instagram (jika ada)
          if (hasImage)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F3FF),
                ),
                child: Image.memory(report.photoBytes!, fit: BoxFit.cover),
              ),
            )
          else
            // Jika tidak ada gambar, tampilkan banner dekoratif ungu tipis yang manis
            Container(
              height: 4,
              width: double.infinity,
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
            ),
            
          // Content ala Twitter/Instagram (Caption & deskripsi)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2B2438),
                  ),
                ),
                if (report.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF645A73),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                
                // Lokasi bergaya modern
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        report.location,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF3E8FF), height: 1),
                const SizedBox(height: 10),
                
                // Tombol Hubungi/Pesan ala Instagram Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onMessage,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                        backgroundColor: const Color(0xFFF5F3FF),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFDDD6FE)),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text(
                        'Hubungi Pelapor',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
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

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, this.trailing});

  final Report report;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE9D5FF), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF5F3FF),
          radius: 22,
          child: Icon(
            report.category == 'Barang Hilang'
                ? Icons.inventory_2_outlined
                : Icons.handyman_outlined,
            color: const Color(0xFF7C3AED),
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: Color(0xFF2B2438),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${report.category} • ${report.location}\n${report.date}',
            style: const TextStyle(color: Color(0xFF8A7BA3), fontSize: 11.5, height: 1.3),
          ),
        ),
        trailing: trailing ?? _StatusLabel(status: report.status),
      ),
    );
  }
}
