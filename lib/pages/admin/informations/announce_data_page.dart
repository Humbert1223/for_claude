import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/announces/announces_details_pages.dart';
import 'package:novacole/utils/tools.dart';

class AnnounceDataPage extends StatefulWidget {
  const AnnounceDataPage({super.key});

  @override
  AnnounceDataPageState createState() {
    return AnnounceDataPageState();
  }
}

class AnnounceDataPageState extends State<AnnounceDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (post) {
              return PostInfoWidget(post: post);
            },
            dataModel: 'post',
            paginate: PaginationValue.paginated,
            title: 'Annonces',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school}
              ],
            },
            onItemTap: (post, updateLine) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AnnounceDetailsPage(announce: post);
              }));
            },
          )
        : Container();
  }
}

class PostInfoWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostInfoWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Déterminer la couleur du statut
    final statusColor = _getStatusColor(post['status'].toString());

    return Row(
      children: [
        // Icône avec gradient
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha:0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.article_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),

        // Contenu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du post
              Text(
                post['name'],
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
              const SizedBox(height: 10),

              // Métadonnées
              Row(
                children: [
                  // Date de modification
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400.withValues(alpha:0.15),
                            Colors.blue.shade500.withValues(alpha:0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blue.shade300.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              NovaTools.dateFormat(post['updated_at']),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha:0.2),
                          statusColor.withValues(alpha:0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withValues(alpha:0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha:0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha:0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post['status'].toString().tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fonction pour déterminer la couleur selon le statut
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'publié':
      case 'active':
      case 'actif':
        return Colors.green.shade600;
      case 'draft':
      case 'brouillon':
        return Colors.orange.shade600;
      case 'pending':
      case 'en attente':
        return Colors.amber.shade700;
      case 'archived':
      case 'archivé':
        return Colors.grey.shade600;
      case 'rejected':
      case 'refusé':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}