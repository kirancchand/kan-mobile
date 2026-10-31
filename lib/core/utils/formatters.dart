import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final DateFormat _dateTime = DateFormat('d MMM, h:mm a');
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');

  static String currency(num amount) => _currency.format(amount);

  static String dateTime(DateTime dt) => _dateTime.format(dt);

  static String date(DateTime dt) => _date.format(dt);

  static String time(DateTime dt) => _time.format(dt);

  /// "3h ago" / "2d ago" style relative time for feeds and listings.
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative) {
      final until = dt.difference(now);
      if (until.inDays > 0) return 'in ${until.inDays}d';
      if (until.inHours > 0) return 'in ${until.inHours}h';
      return 'in ${until.inMinutes}m';
    }
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
