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
        return LibraryInfoWidget(library: library);
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

class LibraryInfoWidget extends StatelessWidget {
  final Map<String, dynamic> library;

  const LibraryInfoWidget({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail avec overlay et badge type
        Stack(
          children: [
            // Image principale
            Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha:0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ModelPhotoWidget(
                      model: library,
                      width: 90,
                      height: 110,
                      editIconSize: 9,
                      editable: false,
                      photoKey: 'thumbnail_url',
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha:0.6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Badge type en haut
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade500,
                      Colors.blue.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  library['type'].toString().tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Informations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                library['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Description
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha:0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha:0.1)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  library['description'] ?? '[Aucune description]',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Tags Niveau et Discipline
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Niveau
                  _buildInfoTag(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: library['level_name'],
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                    ],
                    isDark: isDark,
                  ),
                  // Discipline
                  _buildInfoTag(
                    icon: Icons.book_rounded,
                    label: library['discipline_name'],
                    colors: [
                      Colors.teal.shade400,
                      Colors.teal.shade600,
                    ],
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTag({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withValues(alpha:0.15)).toList(),
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.first.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colors.last,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.last,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}