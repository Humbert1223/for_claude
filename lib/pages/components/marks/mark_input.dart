import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/hive-service.dart';

class MarkInput extends StatefulWidget {
  final Mark? mark;
  final String assessment;
  final String student;
  final String subject;

  const MarkInput({
    super.key,
    this.mark,
    required this.assessment,
    required this.student,
    required this.subject,
  });

  @override
  MarkInputState createState() => MarkInputState();
}

class MarkInputState extends State<MarkInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool saving = false;
  bool hasFocus = false;

  Box<Mark>? markBox;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBox();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      hasFocus = _focusNode.hasFocus;
    });
    if(!hasFocus){
      _processMark();
    }
  }

  Future<void> _initializeBox() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null || user.school == null) return;

    markBox = await HiveService.marksBox(user);

    if (mounted) {
      setState(() {
        isInitialized = true;
        _updateController();
      });
    }
  }

  void _updateController() {
    if (markBox == null) return;

    final currentMark = markBox!.values
        .where((mark) =>
    mark.studentId == widget.student &&
        mark.assessmentId == widget.assessment &&
        mark.subjectId == widget.subject)
        .firstOrNull;

    if (!hasFocus && currentMark?.value != null) {
      _controller.text = currentMark!.value.toString();
    } else if (!hasFocus && currentMark?.value == null) {
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isInitialized || markBox == null) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: markBox!.listenable(),
      builder: (context, _) {
        _updateController();

        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: hasFocus
                    ? (isDark
                    ? theme.colorScheme.primaryContainer.withValues(alpha:0.3)
                    : theme.colorScheme.primaryContainer.withValues(alpha:0.2))
                    : (isDark
                    ? theme.colorScheme.surface
                    : Colors.white),
                border: Border.all(
                  color: hasFocus
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: hasFocus ? 2 : 0,
                ),
              ),
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getMarkColor(theme),
                  letterSpacing: 0.5,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d*)')),
                ],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  hintText: hasFocus ? '0 - 20' : '--',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.3),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onFieldSubmitted: (_) {
                  _focusNode.unfocus();
                  _processMark();
                },
                onEditingComplete: () {
                  _focusNode.unfocus();
                  _processMark();
                },
              ),
            ),

            // Loading Indicator
            if (saving)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha:0.8),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Sync Status Indicator
            if (!saving && _controller.text.isNotEmpty)
              Positioned(
                top: 4,
                right: 4,
                child: _buildSyncIndicator(theme),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSyncIndicator(ThemeData theme) {
    final currentMark = markBox!.values
        .where((mark) =>
    mark.studentId == widget.student &&
        mark.assessmentId == widget.assessment &&
        mark.subjectId == widget.subject)
        .firstOrNull;

    final isSynced = currentMark?.isSynced ?? false;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSynced ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isSynced ? Colors.green : Colors.orange).withValues(alpha:0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        isSynced ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }

  Color _getMarkColor(ThemeData theme) {
    final valueStr = _controller.text.replaceAll(',', '.');
    final value = double.tryParse(valueStr);

    if (value == null) return theme.colorScheme.onSurface;

    if (value >= 16) return Colors.green.shade700;
    if (value >= 14) return Colors.blue.shade700;
    if (value >= 10) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Future<void> _processMark() async {
    final String valueStr = _controller.text.replaceAll(',', '.');
    final double? value = double.tryParse(valueStr);

    final existingMark = markBox!.values
        .where((mark) =>
    mark.studentId == widget.student &&
        mark.assessmentId == widget.assessment &&
        mark.subjectId == widget.subject)
        .firstOrNull;

    if (_controller.text.isEmpty) {
      if (existingMark?.remoteId == null) {
        return;
      }
    }

    if(existingMark != null && existingMark.value == value){
      return;
    }

    if (value != null && (value > 20 || value < 0)) {
      _showErrorToast("Note invalide ! Entrez une valeur entre 0 et 20");
      _updateController();
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final localNote = await NoteService.upsertNoteOffline(
        studentId: widget.student,
        assessmentId: widget.assessment,
        subjectId: widget.subject,
        value: value,
      );

      final connectivity = await (Connectivity().checkConnectivity());
      final isOnline = !connectivity.contains(ConnectivityResult.none);

      if (isOnline && localNote != null) {
        await NoteService.syncNoteToApi(localNote);
        _showSuccessToast("Note enregistrée et synchronisée");
      } else if (localNote != null) {
        _showInfoToast("Note enregistrée localement");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Erreur : $e");
      }
      _showErrorToast("Erreur lors de l'enregistrement");
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange.shade600,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

class NoteService {
  static Future<Mark?> upsertNoteOffline({
    required String studentId,
    required String assessmentId,
    required String subjectId,
    double? value,
  }) async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null || user.school == null) return null;

    Box<Mark> markBox = await HiveService.marksBox(user);

    Mark? existing = markBox.values
        .where(
          (mark) =>
      mark.studentId == studentId &&
          mark.assessmentId == assessmentId &&
          mark.subjectId == subjectId,
    )
        .firstOrNull;

    if (existing != null) {
      existing.value = value;
      existing.updatedAt = DateTime.now();
      existing.isSynced = false;
      await existing.save();
    } else {
      Mark note = Mark()
        ..studentId = studentId
        ..schoolId = user.school!
        ..assessmentId = assessmentId
        ..subjectId = subjectId
        ..value = value
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await markBox.add(note);
    }

    return markBox.values
        .where(
          (mark) =>
      mark.studentId == studentId &&
          mark.assessmentId == assessmentId &&
          mark.subjectId == subjectId,
    )
        .firstOrNull;
  }

  static Future<Map<String, dynamic>?> syncNoteToApi(Mark note) async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null || user.school == null) return null;

    try {
      final data = {
        'assessment_id': note.assessmentId,
        'student_id': note.studentId,
        'subject_id': note.subjectId,
        'value': note.value,
      };

      final response = await MasterCrudModel.post('/process-mark', data: data);

      if (response != null && response['value'] != null) {
        note.isSynced = true;
        note.remoteId = response['id']?.toString();
        note.updatedAt = DateTime.now();
        await note.save();
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Erreur de sync : $e");
      }
      return null;
    }
  }
}