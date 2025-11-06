import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/utils/hive-service.dart';

class HomeUnsyncedMarkWidget extends StatefulWidget {
  const HomeUnsyncedMarkWidget({super.key});

  @override
  HomeUnsyncedMarkWidgetState createState() {
    return HomeUnsyncedMarkWidgetState();
  }
}

class HomeUnsyncedMarkWidgetState extends State<HomeUnsyncedMarkWidget> {
  UserModel? user;
  bool syncing = false;
  int count = 0;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((u) {
      setState(() {
        user = u;
      });
      if (u != null) {
        getUnsyncedMark(u).then((marks) {
          setState(() {
            count = marks.length;
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return count > 0
        ? Builder(
            builder: (context) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                color: isDark
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      // Icône d'avertissement
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Texte d'information
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(text: "Vous avez "),
                              TextSpan(
                                text: "$count",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const TextSpan(
                                text: " note(s) non synchronisées",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton de synchronisation
                      syncing
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: LoadingIndicator(
                                  type: LoadingIndicatorType.inkDrop,
                                  size: 30,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  setState(() {
                                    syncing = true;
                                  });
                                  try {
                                    await MarkSyncService.syncAllNotesToApi();
                                    if (user != null) {
                                      final marks = await getUnsyncedMark(
                                        user!,
                                      );
                                      setState(() {
                                        count = marks.length;
                                      });
                                    }
                                  } finally {
                                    setState(() {
                                      syncing = false;
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.cloud_upload_rounded,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                tooltip: 'Synchroniser les notes',
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          )
        : Container();
  }

  Future<List<Mark>> getUnsyncedMark(UserModel u) async {
    return (await HiveService.marksBox(u)).values
        .where((mark) => mark.isSynced == false || mark.remoteId == null)
        .toList();
  }
}
