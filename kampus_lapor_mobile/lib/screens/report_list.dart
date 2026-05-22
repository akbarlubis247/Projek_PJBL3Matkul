part of '../main.dart';

class _ReportListPage extends StatelessWidget {
  const _ReportListPage({
    required this.reports,
    required this.onRefresh,
    required this.refreshKey,
  });

  final List<Report> reports;
  final Future<void> Function() onRefresh;
  final String refreshKey;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _ReportListBody(
        reports: reports,
        onRefresh: onRefresh,
        refreshKey: refreshKey,
      ),
    );
  }
}

class _ReportListBody extends StatefulWidget {
  const _ReportListBody({
    required this.reports,
    required this.onRefresh,
    required this.refreshKey,
  });

  final List<Report> reports;
  final Future<void> Function() onRefresh;
  final String refreshKey;

  @override
  State<_ReportListBody> createState() => _ReportListBodyState();
}

class _ReportListBodyState extends State<_ReportListBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRefresh());
  }

  @override
  void didUpdateWidget(covariant _ReportListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRefresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _Header(
          title: 'Daftar Laporan',
          subtitle: 'Pantau status dari admin untuk laporan yang dibuat',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: widget.reports
                .map(
                  (report) => _ReportCard(
                    report: report,
                    trailing: _StatusLabel(status: report.status),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
