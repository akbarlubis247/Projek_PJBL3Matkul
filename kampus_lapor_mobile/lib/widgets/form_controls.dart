part of '../main.dart';

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? ['Semua'] : values;
    final safeValue = safeValues.contains(value) ? value : safeValues.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 19),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        style: const TextStyle(
          color: Color(0xFF2B2438),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        items: safeValues
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? safeValue),
      ),
    );
  }
}

class _ModernFormDropdown extends StatelessWidget {
  const _ModernFormDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? [value] : values;
    final safeValue = safeValues.contains(value) ? value : safeValues.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: .07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF6D28D9),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6D5B7F),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(18),
        style: const TextStyle(
          color: Color(0xFF2B2438),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        items: safeValues
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
