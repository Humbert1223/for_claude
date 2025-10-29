import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novacole/models/master_crud_model.dart';

class ExamMarkInput extends StatefulWidget {
  final Map<String, dynamic>? mark;
  final Map<String, dynamic> exam;
  final String student;
  final String subject;
  final Function? onChange;

  const ExamMarkInput({
    super.key,
    this.mark,
    required this.exam,
    required this.student,
    required this.subject,
    this.onChange,
  });

  @override
  ExamMarkInputState createState() => ExamMarkInputState();
}

class ExamMarkInputState extends State<ExamMarkInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Map<String, dynamic>? mark;
  bool saving = false;
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.mark != null) {
      _controller.text = (widget.mark?['value'] != null)
          ? widget.mark!['value'].toString()
          : '';
      mark = widget.mark;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      hasFocus = _focusNode.hasFocus;
    });
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
    final isExamClosed = widget.exam['closed'] == true;

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isExamClosed
                ? (isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3)
                : Colors.grey.shade100)
                : (hasFocus
                ? (isDark
                ? theme.colorScheme.primaryContainer.withValues(alpha:0.3)
                : theme.colorScheme.primaryContainer.withValues(alpha:0.2))
                : (isDark ? theme.colorScheme.surface : Colors.white)),
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
            enabled: !saving && !isExamClosed,
            textAlign: hasFocus ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExamClosed
                  ? theme.colorScheme.onSurface.withValues(alpha:0.5)
                  : _getMarkColor(theme),
              letterSpacing: 0.5,
            ),
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d*)')),
            ],
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
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
              suffixIcon: hasFocus && !isExamClosed
                  ? IconButton(
                icon: Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  _focusNode.unfocus();
                  _processMark();
                },
                tooltip: 'Enregistrer',
              )
                  : null,
            ),
            onFieldSubmitted: (_) {
              _focusNode.unfocus();
              _processMark();
            },
          ),
        ),

        // Closed Exam Indicator
        if (isExamClosed)
          Positioned(
            top: 4,
            right: 4,
            child: Tooltip(
              message: 'Examen clôturé',
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha:0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
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

        // Mark Status Indicator
        if (!saving && !isExamClosed && _controller.text.isNotEmpty)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha:0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
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
    String uri = mark == null
        ? '/exam/mark/create/${widget.exam['id']}'
        : '/exam/mark/update/${widget.exam['id']}/${mark!['id']}';

    if (mark == null && _controller.text.isEmpty) {
      return;
    }

    setState(() {
      saving = true;
    });

    Map<String, dynamic> data = {};
    data['student_id'] = widget.student;
    data['subject_id'] = widget.subject;
    data['value'] = _controller.text.isNotEmpty
        ? double.tryParse(_controller.text.replaceAll(',', '.'))
        : null;

    try {
      var response = mark == null
          ? await MasterCrudModel.post(uri, data: data)
          : await MasterCrudModel.patch(uri, data);

      if (response != null && response['id'] != null) {
        _controller.text =
        response['value'] != null ? response['value'].toString() : '';

        if (response['deleted'] != null && response['deleted'] == true) {
          _controller.text = '';
          _showInfoToast('Note supprimée');
        } else {
          _showSuccessToast('Note enregistrée');
        }

        if (widget.onChange != null) {
          widget.onChange!(response);
          if (response['deleted'] != null && response['deleted'] == true) {
            setState(() {
              mark = null;
            });
          } else {
            setState(() {
              mark = response;
            });
          }
        }
      } else {
        _controller.text =
        (mark != null && mark!['value'] != null) ? mark!['value'].toString() : '';
        _showErrorToast('Erreur lors de l\'enregistrement');
      }
    } catch (e) {
      _controller.text =
      (mark != null && mark!['value'] != null) ? mark!['value'].toString() : '';
      _showErrorToast('Erreur: ${e.toString()}');
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