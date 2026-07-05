import 'package:intl/intl.dart';

class FormatHelper {
  static final NumberFormat _currencyFormat = NumberFormat.currency(customPattern: '₹#,##,##0.00');
  static final NumberFormat _currencyFormatNoDecimals = NumberFormat.currency(customPattern: '₹#,##,##0');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _dateTimeFormat24 = DateFormat('dd/MM/yyyy HH:mm');

  static String formatCurrency(double value, {bool showDecimals = true}) {
    if (showDecimals) {
      return _currencyFormat.format(value);
    }
    return _currencyFormatNoDecimals.format(value);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date.toLocal());
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date.toLocal());
  }

  static String formatDateTime24(DateTime date) {
    return _dateTimeFormat24.format(date.toLocal());
  }
}
