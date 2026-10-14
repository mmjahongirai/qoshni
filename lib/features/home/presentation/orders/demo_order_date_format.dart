import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDemoOrderDateTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toString();
  final local = dateTime.toLocal();
  return DateFormat.yMMMd(locale).add_jm().format(local);
}
