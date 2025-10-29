import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/services/assessment_sync_service.dart';
import 'package:novacole/services/classe_sync_service.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/services/registration_sync_service.dart';
import 'package:novacole/services/subject_sync_service.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/sync_manager.dart';

class SynchronisationPage extends StatefulWidget {
  const SynchronisationPage({super.key});

  @override
  SynchronisationPageState createState() {
    return SynchronisationPageState();
  }
}

class SynchronisationPageState extends State<SynchronisationPage> {
  List<String> currentSyncing = [];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Synchronisation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Élèves',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Synchroniser les données des élèves'),
              trailing: Visibility(
                visible: !currentSyncing.contains(Entity.registration),
                replacement: SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingIndicator(
                    type: LoadingIndicatorType.inkDrop,
                    size: 16,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    if (currentSyncing.contains(Entity.registration)) {
                      return;
                    }
                    await SyncManager.setLastSyncNow(Entity.registration, reinit: true);
                    setState(() {
                      currentSyncing.add(Entity.registration);
                    });
                    RegistrationSyncService.syncAllRegistrationsFromApi().then((
                      _,
                    ) {
                      setState(() {
                        currentSyncing.remove(Entity.registration);
                      });
                    });
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Évaluations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Synchroniser les données des évaluations'),
              trailing: Visibility(
                visible: !currentSyncing.contains(Entity.assessment),
                replacement: SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingIndicator(
                    type: LoadingIndicatorType.inkDrop,
                    size: 16,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    if (currentSyncing.contains(Entity.assessment)) {
                      return;
                    }
                    await SyncManager.setLastSyncNow(Entity.assessment, reinit: true);
                    setState(() {
                      currentSyncing.add(Entity.assessment);
                    });
                    AssessmentSyncService.syncAllAssessmentFromApi().then((
                        _,
                        ) {
                      setState(() {
                        currentSyncing.remove(Entity.assessment);
                      });
                    });
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Classes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Synchroniser les données des classes'),
              trailing: Visibility(
                visible: !currentSyncing.contains(Entity.classe),
                replacement: SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingIndicator(
                    type: LoadingIndicatorType.inkDrop,
                    size: 16,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    if (currentSyncing.contains(Entity.classe)) {
                      return;
                    }
                    await SyncManager.setLastSyncNow(Entity.classe, reinit: true);
                    setState(() {
                      currentSyncing.add(Entity.classe);
                    });
                    ClasseSyncService.syncAllClasseFromApi().then((
                        _,
                        ) {
                      setState(() {
                        currentSyncing.remove(Entity.classe);
                      });
                    });
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Matières',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Synchroniser les données des matières'),

              trailing: Visibility(
                visible: !currentSyncing.contains(Entity.subject),
                replacement: SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingIndicator(
                    type: LoadingIndicatorType.inkDrop,
                    size: 16,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    if (currentSyncing.contains(Entity.subject)) {
                      return;
                    }
                    await SyncManager.setLastSyncNow(Entity.subject, reinit: true);
                    setState(() {
                      currentSyncing.add(Entity.subject);
                    });
                    SubjectSyncService.syncAllSubjectFromApi().then((
                        _,
                        ) {
                      setState(() {
                        currentSyncing.remove(Entity.subject);
                      });
                    });
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Synchroniser les données des notes'),
              trailing: Visibility(
                visible: !currentSyncing.contains(Entity.mark),
                replacement: SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingIndicator(
                    type: LoadingIndicatorType.inkDrop,
                    size: 16,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    if (currentSyncing.contains(Entity.mark)) {
                      return;
                    }
                    await SyncManager.setLastSyncNow(Entity.mark, reinit: true);
                    setState(() {
                      currentSyncing.add(Entity.mark);
                    });
                    MarkSyncService.syncAllNotesToApi().then((
                        _,
                        ) {
                      setState(() {
                        currentSyncing.remove(Entity.mark);
                      });
                    });
                  },
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {


                    setState(() {
                      currentSyncing = [Entity.registration];
                    });
                    await SyncManager.setLastSyncNow(Entity.registration, reinit: true);
                    await RegistrationSyncService.syncAllRegistrationsFromApi();


                    setState(() {
                      currentSyncing = [Entity.assessment];
                    });
                    await SyncManager.setLastSyncNow(Entity.assessment, reinit: true);
                    await AssessmentSyncService.syncAllAssessmentFromApi();


                    setState(() {
                      currentSyncing = [Entity.classe];
                    });
                    await SyncManager.setLastSyncNow(Entity.classe, reinit: true);
                    await ClasseSyncService.syncAllClasseFromApi();


                    setState(() {
                      currentSyncing = [Entity.subject];
                    });
                    await SyncManager.setLastSyncNow(Entity.subject, reinit: true);
                    await SubjectSyncService.syncAllSubjectFromApi();


                    setState(() {
                      currentSyncing = [Entity.mark];
                    });
                    await SyncManager.setLastSyncNow(Entity.mark, reinit: true);
                    await MarkSyncService.syncAllNotesToApi();

                    setState(() {
                      currentSyncing = [];
                    });

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tout synchroniser'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void syncAll() async {
    bool? proceed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Synchronisation'),
          content: const Text(
            'Voulez-vous synchroniser les données de l\'application ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
    if (proceed == true) {}
  }
}
