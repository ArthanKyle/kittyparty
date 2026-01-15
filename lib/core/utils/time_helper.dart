import 'package:intl/intl.dart';

class TimeFormat {
  /// Safe parser for DateTime | ISO String | null
  static DateTime? _parse(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      // 🔒 Do NOT convert again
      return value.isUtc ? value.toLocal() : value;
    }

    if (value is String) {
      try {
        final dt = DateTime.parse(value);

        // ✅ Convert ONLY if UTC
        return dt.isUtc ? dt.toLocal() : dt;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Jan 15, 2026 • 7:41 PM
  static String dateTime(dynamic value) {
    final dt = _parse(value);
    if (dt == null) return "—";
    return DateFormat("MMM d, yyyy • h:mm a").format(dt);
  }

  /// Jan 15, 2026
  static String dateOnly(dynamic value) {
    final dt = _parse(value);
    if (dt == null) return "—";
    return DateFormat("MMM d, yyyy").format(dt);
  }

  /// 7:41 PM
  static String timeOnly(dynamic value) {
    final dt = _parse(value);
    if (dt == null) return "—";
    return DateFormat("h:mm a").format(dt);
  }

  /// Just now / 5m ago / Yesterday
  static String relative(dynamic value) {
    final dt = _parse(value);
    if (dt == null) return "—";

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return DateFormat("MMM d").format(dt);
  }
}
