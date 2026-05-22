part of '../main.dart';

class _CreateNavIcon extends StatelessWidget {
  const _CreateNavIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 58 : 52,
      height: active ? 48 : 42,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF7C3AED) : const Color(0xFFDDD6FE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFF6D28D9) : const Color(0xFFC4B5FD),
          width: active ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF7C3AED,
            ).withValues(alpha: active ? .36 : .18),
            blurRadius: active ? 18 : 12,
            offset: Offset(0, active ? 7 : 4),
          ),
        ],
      ),
      child: Icon(
        Icons.add,
        color: active ? Colors.white : const Color(0xFF6D28D9),
        size: active ? 32 : 29,
      ),
    );
  }
}
