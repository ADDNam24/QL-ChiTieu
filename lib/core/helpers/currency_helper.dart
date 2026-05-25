import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static String format(double value) => _formatter.format(value);

  static String compact(double value) {
    final absValue = value.abs();
    if (absValue >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} tỷ';
    }
    if (absValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}tr';
    }
    if (absValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
