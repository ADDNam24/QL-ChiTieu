import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _month = DateFormat('MM/yyyy');
  static final DateFormat _monthKey = DateFormat('yyyy-MM');

  static String formatDate(DateTime value) => _date.format(value);
  static String formatMonth(DateTime value) => _month.format(value);
  static String monthKey(DateTime value) => _monthKey.format(value);
}
