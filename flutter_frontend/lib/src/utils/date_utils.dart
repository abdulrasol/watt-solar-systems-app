import 'package:intl/intl.dart';
import 'package:watt/l10n/app_localizations.dart';

class AppDateUtils {
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(date);
  }

  static String timeAgo(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 30) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays >= 1) {
      return l10n.time_ago_days(difference.inDays);
    } else if (difference.inHours >= 1) {
      return l10n.time_ago_hours(difference.inHours);
    } else if (difference.inMinutes >= 1) {
      return l10n.time_ago_minutes(difference.inMinutes);
    } else {
      return l10n.time_ago_just_now;
    }
  }
}
