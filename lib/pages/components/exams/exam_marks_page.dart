import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/exams/student_exam_mark_line.dart';
import 'package:novacole/utils/constants.dart';

class ExamMarksPage extends StatefulWidget {
  final Map<String, dynamic> exam;

  const ExamMarksPage({super.key, required this.exam});

  @override
  ExamMarksPageState createState() => ExamMarksPageState();
}

class ExamMarksPageState extends State<ExamMarksPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String? subjectId;

  List<Map<String, dynamic>> marks = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> subjects = [];
  bool loadingSubject = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    Future.delayed(Duration.zero, () async {
      setState(() {
        marks = List<Map<String, dynamic>>.from(widget.exam['marks'] ?? []);
      });
    });

    UserModel.fromLocalStorage().then((user) {
      if (user?.accountType == 'teacher') {
        MasterCrudModel.post('/auth/user/profile/${Entity.teacher}')
            .then((teacher) {
          setState(() {
            subjects =
                List<Map<String, dynamic>>.from(widget.exam['subjects'] ?? [])
                    .where((subject) {
                  return List<String>.from(subject['teacher_ids'] ?? [])
                      .contains(teacher?['id']);
                }).toList();
            loadingSubject = false;
          });
          _animationController.forward();
        });
      } else {
        setState(() {
          subjects =
          List<Map<String, dynamic>>.from(widget.exam['subjects'] ?? []);
          loadingSubject = false;
        });
        _animationController.forward();
      }
    });

    loadStudents().then((data) {
      setState(() {
        students = data;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        child: body(theme, isDark),
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
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                "Notes d'examen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.exam['name'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(245),
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
                child: _buildSubjectSelector(theme, isDark),
              ),
              const SizedBox(height: 12),
              _buildModernListHeader(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector(ThemeData theme, bool isDark) {
    if (loadingSubject) {
      return Container(
        height: 80,
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
              'Chargement des matières...',
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Sélectionner une matière',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModelFormInputSelect(
            key: Key(subjects.length.toString()),
            onChange: _onSearch,
            item: {
              'field': 'subject_id',
              'name': 'Matière',
              'options': List<Map<String, dynamic>>.from(subjects)
                  .map((el) => {'value': el['id'], 'label': el['name']})
                  .toList(),
              'required': true,
              'type': 'select',
              'placeholder': 'Choisir une matière',
            },
          ),
        ],
      ),
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
          Expanded(
            child: Row(
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
                Expanded(
                  child: Text(
                    'Nom & prénom(s)',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5)
                      : Colors.white.withValues(alpha:0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Non coefficientée',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSearch(value) async {
    setState(() {
      subjectId = value;
    });
  }

  Future<List<Map<String, dynamic>>> loadStudents() async {
    List<Map<String, dynamic>>? response = await MasterCrudModel.load(
      '/exam/registrations/${widget.exam['id']}',
      data: {'paginate': false},
    );
    return response != null ? List<Map<String, dynamic>>.from(response) : [];
  }

  Widget body(ThemeData theme, bool isDark) {
    if (subjectId == null || subjectId!.isEmpty) {
      return _buildEmptyState(theme, isDark, 'filter');
    }

    if (students.isEmpty) {
      return _buildEmptyState(theme, isDark, 'students');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          var mark = List.from(marks)
              .where((s) => s['subject_id'] == subjectId)
              .where((s) => s['student_id'] == students[index]['id'])
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
              child: StudentExamMarkLine(
                key: ValueKey("${students[index]['id']}_$subjectId"),
                student: students[index],
                mark: mark,
                exam: widget.exam,
                subject: subjectId!,
                onChange: (m) {
                  addOrUpdate(m);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, String type) {
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
                type == 'filter' ? Icons.filter_list_rounded : Icons.person_off_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              type == 'filter' ? 'Sélectionnez une matière' : 'Aucun étudiant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'filter'
                  ? 'Choisissez une matière pour\ncommencer la saisie'
                  : 'Aucun étudiant inscrit\npour cet examen',
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

  void addOrUpdate(Map<String, dynamic> mark) {
    if (mark.containsKey('deleted') && mark['deleted'] == true) {
      setState(() {
        marks.removeWhere(
              (s) =>
          s['student_id'] == mark['student_id'] &&
              s['subject_id'] == mark['subject_id'],
        );
      });
      return;
    }
    var index = marks.indexWhere(
          (s) =>
      s['student_id'] == mark['student_id'] &&
          s['subject_id'] == mark['subject_id'],
    );
    if (index != -1) {
      setState(() {
        marks[index] = mark;
      });
    } else {
      setState(() {
        marks.add(mark);
      });
    }
  }
}