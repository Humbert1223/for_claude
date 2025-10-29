import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/models/form.dart';
import 'package:path_provider/path_provider.dart';

class AttributeWidget extends StatefulWidget {
  final dynamic entity;
  final Map<String, dynamic> data;
  final Function? onLoaded;

  const AttributeWidget(
      {super.key, required this.entity, this.onLoaded, required this.data});

  @override
  State createState() {
    return _AttributeWidgetState();
  }
}

class _AttributeWidgetState extends State<AttributeWidget> {
  List _inputs = [];

  @override
  void initState() {
    super.initState();
    _loadDataModels();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Table(
                border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey[400] ?? Colors.grey)),
                children: _inputs
                    .map<TableRow>((e) => TableRow(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey[400] ?? Colors.grey))),
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  e['name'].toString(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: _parseAttr(
                                    e, widget.data[e['field']].toString()),
                              ),
                            ),
                          ],
                        ))
                    .toList())),
      ),
    );
  }

  void _loadDataModels() async {
    Map<String, dynamic>? value = {};
    if (widget.entity.runtimeType == String) {
      value = await CoreForm().get(entity: widget.entity);
    }else{
      value = widget.entity;
    }
    List inputs = value!=null && value.isNotEmpty ? value['inputs'] : [];
    setState(() {
      _inputs = inputs;
      if (widget.onLoaded != null) {
        widget.onLoaded!();
      }
    });
  }

  Widget _parseAttr(input, value) {
    if (value.toString() == 'null') {
      return const Text(
        '-',
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
      );
    }
    switch (input['type']) {
      case 'date':
        DateTime? date = DateTime.tryParse(value);
        return Text(
          (date != null) ? DateFormat.yMMMd('fr').format(date) : '-',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        );
      case 'photo':
      case 'file':
        String downloading = '';
        return TextButton(
          style: TextButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.w500)),
          onPressed: () async {

          },
          child: (downloading.isEmpty)
              ? const Text("Télécharger")
              : Text("En cours ... $downloading"),
        );
      default:
        return Text(
          value ?? '-',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print("Cannot get download folder path");
      }
    }
    return directory?.path;
  }
}
