import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/hive/classe.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/hive/registration.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/marks/mark_filter_form.dart';
import 'package:novacole/pages/components/marks/student_mark_line.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  MarksPageState createState() => MarksPageState();
}

class MarksPageState extends State<MarksPage> with SingleTickerProviderStateMixin {
  Key listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
  Map<String, dynamic> filterForm = {};

  bool isSyncing = false;
  bool isInitialized = false;

  UserModel? user;
  Box<Classe>? classeBox;
  Box<Registration>? registrationBox;
  Box<Mark>? markBox;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    user = await UserModel.fromLocalStorage();
    if (user == null || user!.school == null) return;

    classeBox = await HiveService.classesBox(user!);
    registrationBox = await HiveService.registrationsBox(user!);
    markBox = await HiveService.marksBox(user!);

    if (mounted) {
      setState(() {
        isInitialized = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: _buildModernAppBar(theme, isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(theme, isDark),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grade_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              "Notes d'évaluation",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (!isSyncing)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.cloud_sync_rounded, color: Colors.white),
              onPressed: () async {
                await syncData();
                setState(() {
                  filterForm = {};
                  listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                });
              },
              tooltip: 'Synchroniser',
            ),
          ),
        const SizedBox(width: 8),
      ],
      bottom: !isSyncing
          ? PreferredSize(
        preferredSize: const Size.fromHeight(270),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MarkFilterForm(onSearch: _onSearch),
              ),
              const SizedBox(height: 12),
              _buildModernListHeader(theme, isDark),
            ],
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildModernListHeader(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            theme.colorScheme.primary.withValues(alpha:0.2),
            theme.colorScheme.primary.withValues(alpha:0.1),
          ]
              : [
            theme.colorScheme.primary.withValues(alpha:0.15),
            theme.colorScheme.primary.withValues(alpha:0.08),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha:0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Nom & prénom(s)',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '(Non coefficientée)',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSearch(form) {
    setState(() {
      filterForm = form;
      listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  List<Registration> _getFilteredStudents() {
    if (registrationBox == null || filterForm['classeId'] == null) {
      return [];
    }

    List<Registration> list = registrationBox!.values
        .where((registration) => registration.classeId == filterForm['classeId'])
        .toList();

    list.sort((a, b) => a.fullName.compareTo(b.fullName));
    return list;
  }

  List<Mark> _getFilteredMarks() {
    if (markBox == null ||
        filterForm['subjectId'] == null ||
        filterForm['assessmentId'] == null) {
      return [];
    }
    return markBox!.values
        .where((mark) =>
    mark.subjectId == filterForm['subjectId'] &&
        mark.assessmentId == filterForm['assessmentId'] &&
        mark.studentId.isNotEmpty)
        .toList();
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (isSyncing) {
      return _buildSyncingIndicator(theme);
    }

    if (!isInitialized || registrationBox == null || markBox == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Initialisation...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final hasClasse = classeBox?.isNotEmpty ?? false;
    final hasCompleteFilter = filterForm['classeId'] != null &&
        filterForm['assessmentId'] != null &&
        filterForm['subjectId'] != null;

    if (!hasCompleteFilter) {
      return _buildEmptyState(hasClasse, theme, isDark);
    }

    return _buildMarksList(theme, isDark);
  }

  Widget _buildSyncingIndicator(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha:0.2),
                    theme.colorScheme.primary.withValues(alpha:0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const LoadingIndicator(type: LoadingIndicatorType.inkDrop),
            ),
            const SizedBox(height: 24),
            Text(
              'Synchronisation en cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter, cela peut prendre\nquelques minutes...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksList(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        registrationBox!.listenable(),
        markBox!.listenable(),
      ]),
      builder: (context, _) {
        final repartitions = _getFilteredStudents();
        final marks = _getFilteredMarks();

        if (repartitions.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha:0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha:0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun élève trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Il n\'y a pas d\'élèves inscrits\ndans cette classe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListView.builder(
            key: listKey,
            itemCount: repartitions.length,
            itemBuilder: (context, index) {
              Mark? filtered = marks
                  .where(
                    (mark) =>
                mark.studentId == repartitions[index].studentId &&
                    mark.assessmentId == filterForm['assessmentId'] &&
                    mark.subjectId == filterForm['subjectId'],
              )
                  .toList()
                  .firstOrNull;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + (index * 30)),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha:0.08)
                          : Colors.black.withValues(alpha:0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha:0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: StudentMarkLine(
                    student: repartitions[index],
                    mark: filtered,
                    assessment: filterForm['assessmentId'],
                    subject: filterForm['subjectId'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool hasClasse, ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha:0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha:0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: hasClasse
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha:0.2),
                    theme.colorScheme.primary.withValues(alpha:0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sélectionnez les filtres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez une classe, une matière\net une évaluation pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        )
            : InkWell(
          onTap: () => syncData(reinit: true),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha:0.2),
                      theme.colorScheme.primary.withValues(alpha:0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_download_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Synchronisation requise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Touchez pour synchroniser\nles données',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cliquez ici',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> syncData({bool reinit = false}) async {
    Connectivity().checkConnectivity().then((result) async {
      if (!result.contains(ConnectivityResult.none)) {
        setState(() {
          isSyncing = true;
        });
        await SyncManager.setLastSyncNow(Entity.classe, reinit: reinit);
        await SyncManager.setLastSyncNow(Entity.subject, reinit: reinit);
        await SyncManager.setLastSyncNow(Entity.assessment, reinit: reinit);
        await SyncManager.setLastSyncNow(Entity.mark, reinit: reinit);
        await SyncManager.setLastSyncNow(Entity.registration, reinit: reinit);
        await SyncManager.triggerSyncAllForMarks();
        setState(() {
          isSyncing = false;
        });
      }
    });
  }
}