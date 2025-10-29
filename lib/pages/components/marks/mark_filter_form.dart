import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/hive/assessment.dart';
import 'package:novacole/hive/classe.dart';
import 'package:novacole/hive/subject.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/hive-service.dart';

class MarkFilterForm extends StatefulWidget {
  final Function onSearch;

  const MarkFilterForm({super.key, required this.onSearch});

  @override
  MarkFilterFormState createState() => MarkFilterFormState();
}

class MarkFilterFormState extends State<MarkFilterForm> {
  String? classId;
  String? subjectId;
  String? assessmentId;

  Key classeKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
  Key subjectKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
  Key assessKey = Key(DateTime.now().millisecondsSinceEpoch.toString());

  UserModel? user;
  Box<Classe>? classesBox;
  Box<Subject>? subjectsBox;
  Box<Assessment>? assessmentsBox;

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    user = await UserModel.fromLocalStorage();
    if (user == null || user!.school == null) return;

    classesBox = await HiveService.classesBox(user!);
    subjectsBox = await HiveService.subjectsBox(user!);
    assessmentsBox = await HiveService.assessmentsBox(user!);

    if (mounted) {
      setState(() {
        isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> _getClasses() {
    if (classesBox == null || user == null) return [];

    final classList = classesBox!.values
        .where((classe) => classe.academicId == user!.academic)
        .toList()
      ..sort((a, b) => (a.levelOrder ?? 0).compareTo(b.levelOrder ?? 0));

    return classList
        .map((c) => {'value': c.remoteId.toString(), 'label': c.name})
        .toList();
  }

  List<Map<String, dynamic>> _getSubjects() {
    if (subjectsBox == null || classId == null || classId!.isEmpty) {
      return [];
    }

    final subjectList = subjectsBox!.values
        .where((sub) => sub.classeId == classId)
        .toList();

    return subjectList
        .map((s) => {'value': s.remoteId.toString(), 'label': s.name})
        .toList();
  }

  List<Map<String, dynamic>> _getAssessments() {
    if (assessmentsBox == null) return [];

    if (classId != null && classId!.isNotEmpty) {
      final assessmentList = assessmentsBox!.values
          .where((ass) => ass.classeIds.contains(classId) && ass.closed == false)
          .toList();

      return assessmentList
          .map((a) => {'value': a.remoteId.toString(), 'label': a.name})
          .toList();
    }

    return [];
  }

  void search() {
    widget.onSearch({
      'classeId': classId,
      'subjectId': subjectId,
      'assessmentId': assessmentId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isInitialized || user == null || classesBox == null || subjectsBox == null || assessmentsBox == null) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chargement des filtres...',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha:0.3),
            theme.colorScheme.primaryContainer.withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        children: [
          // First row: Classe & Évaluation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: classesBox!.listenable(),
                  builder: (context, _) {
                    final classes = _getClasses();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && classId != null) {
                        final classExists = classes.any((c) => c['value'] == classId);
                        if (!classExists) {
                          setState(() {
                            classId = null;
                            subjectId = null;
                            assessmentId = null;
                            classeKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                            subjectKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                            assessKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                          });
                          search();
                        }
                      }
                    });

                    return ModelFormInputSelect(
                      key: classeKey,
                      decorationTextStyle: const TextStyle(
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChange: (value) {
                        setState(() {
                          classId = value;
                          assessmentId = null;
                          subjectId = null;
                          subjectKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                          assessKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                        });
                        search();
                      },
                      item: {
                        'field': 'classe_id',
                        'type': 'select',
                        'options': classes,
                        'name': 'Classe',
                        'placeholder': 'Sélectionner une classe',
                        'value': classId,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: assessmentsBox!.listenable(),
                  builder: (context, _) {
                    final assessments = _getAssessments();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && assessmentId != null) {
                        final assessmentExists = assessments.any((a) => a['value'] == assessmentId);
                        if (!assessmentExists) {
                          setState(() {
                            assessmentId = null;
                            assessKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                          });
                          search();
                        }
                      }
                    });

                    return ModelFormInputSelect(
                      key: assessKey,
                      decorationTextStyle: const TextStyle(
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChange: (value) {
                        setState(() {
                          assessmentId = value;
                        });
                        search();
                      },
                      item: {
                        'field': 'assessment_id',
                        'type': 'select',
                        'name': 'Évaluation',
                        'placeholder': 'Sélectionner une évaluation',
                        'value': assessmentId,
                        'options': assessments,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: Matière
          AnimatedBuilder(
            animation: subjectsBox!.listenable(),
            builder: (context, _) {
              final subjects = _getSubjects();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && subjectId != null) {
                  final subjectExists = subjects.any((s) => s['value'] == subjectId);
                  if (!subjectExists) {
                    setState(() {
                      subjectId = null;
                      subjectKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                    });
                    search();
                  }
                }
              });

              return ModelFormInputSelect(
                key: subjectKey,
                decorationTextStyle: const TextStyle(
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
                onChange: (value) {
                  setState(() {
                    subjectId = value;
                  });
                  search();
                },
                item: {
                  'field': 'subject_id',
                  'type': 'select',
                  'options': subjects,
                  'name': 'Matière',
                  'placeholder': 'Sélectionner une matière',
                  'value': subjectId,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}