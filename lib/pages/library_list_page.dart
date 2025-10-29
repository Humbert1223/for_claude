import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/pages/components/pdf_document_viewer.dart';
import 'package:novacole/utils/constants.dart';

class LibraryListPage extends StatefulWidget {
  const LibraryListPage({super.key});

  @override
  LibraryListPageState createState() {
    return LibraryListPageState();
  }
}

class LibraryListPageState extends State<LibraryListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (library) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModelPhotoWidget(
              model: library,
              width: 80,
              height: 100,
              editIconSize: 9,
              editable: false,
              photoKey: 'thumbnail_url',
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    "${library['name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    library['description'].toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Text(
                  "Type: ${library['type'].toString().tr()}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Niveau: ${library['level_name']}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Discipline: ${library['discipline_name']}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      dataModel: Entity.document,
      paginate: PaginationValue.paginated,
      title: 'Documents',
      canDelete: (data) => false,
      canEdit: (data) => false,
      canAdd: false,
      optionVisible: false,
      query: {'order_by': 'last_name'},
      data: {},
      onItemTap: (document, updateLine) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PdfDocumentViewerPage(
                pdfPath: document['document_url'],
                title: document['name'],
              );
            },
          ),
        );
      },
    );
  }
}
