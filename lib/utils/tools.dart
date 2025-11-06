import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:open_file/open_file.dart';

class NovaTools {
  static Future<Map<String, dynamic>> loadJsonData(String path) async {
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }

  static String dateFormat(String? date) {
    DateTime? created = DateTime.tryParse(date ?? '');
    return (created != null)
        ? DateFormat.yMMMd('fr').format(created).toString()
        : '-';
  }

  static Future download({
    required String uri,
    required String name,
    required Map<String, dynamic> data,
    String? type,
  }) async {
    String? path = await MasterCrudModel.download(uri, name, data);
    if (path != null) {
      OpenFile.open(path, type: type ?? "application/pdf");
    } else {
      Fluttertoast.showToast(
        msg: "Aucune donnée trouvée",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  static Future<void> showDownloadingDialog(BuildContext context, {String? message, Widget? indicator}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SimpleDialog(
        children: [
          indicator ?? LoadingIndicator(type: LoadingIndicatorType.inkDrop),
          const SizedBox(height: 16),
          Center(
            child: Text(
              message ?? "En cours...",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String capitalize(string) {
  return "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}";
}

String currency(dynamic number) {
  if (number == null) {
    return '-';
  }
  return NumberFormat.currency(
    symbol: 'F',
    decimalDigits: 0,
    locale: 'fr-FR',
  ).format(double.tryParse(number.toString()));
}

String number(dynamic number, {int? digit = 0}) {
  if (number == null) {
    return '-';
  }
  return NumberFormat.decimalPatternDigits(
    locale: 'fr',
    decimalDigits: digit,
  ).format(double.tryParse(number.toString()));
}

String tagTransform(string) {
  List<String> tagStringed = string.toString().trim().split(' ');
  return "#${tagStringed.map((e) => capitalize(e)).toList().join()} ";
}

String smallSentence(String bigSentence, {int number = 60}) {
  if (bigSentence.trim().length > number) {
    return '${bigSentence.trim().substring(0, number)}...';
  } else {
    return bigSentence.trim();
  }
}

String? escapeHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String? parsedString = parse(document.body?.text).documentElement?.text;

  return parsedString;
}

String? uppercase(String? string) {
  return string?.toUpperCase();
}
