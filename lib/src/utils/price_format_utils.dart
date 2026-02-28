import 'package:intl/intl.dart';

class PriceFormatUtils {
  /// Formats a double value with thousand separators and 2 decimal places.
  /// Example: 266312.0 -> "266,312.00"
  static String formatPrice(double price) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return formatter.format(price);
  }

  /// Returns a formatted price string with the currency symbol.
  /// Example: (266312.0, "IQD") -> "IQD 266,312.00"
  static String formatWithCurrency(double price, String? symbol) {
    final s = symbol ?? '';
    final formattedPrice = formatPrice(price);
    // You can adjust the order here if needed for specific locales
    return "$s $formattedPrice";
  }
}

extension PriceExtension on double {
  String toPrice() => PriceFormatUtils.formatPrice(this);
  String toPriceWithCurrency(String? symbol) => PriceFormatUtils.formatWithCurrency(this, symbol);
}
