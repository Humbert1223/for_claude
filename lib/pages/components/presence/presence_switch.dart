import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class PresenceSwitch extends StatefulWidget {
  final Map<String, dynamic> repartition;
  final Map<String, dynamic> filterForm;
  final Map<String, dynamic> irregularityForm;
  final int index;

  const PresenceSwitch({
    super.key,
    required this.filterForm,
    required this.repartition,
    required this.irregularityForm,
    required this.index,
  });

  @override
  PresenceSwitchState createState() => PresenceSwitchState();
}

class PresenceSwitchState extends State<PresenceSwitch> with SingleTickerProviderStateMixin {
  late bool _switchState = true;
  late bool _changing = false;
  late Map<String, dynamic>? absence;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    absence = widget.repartition['absence'];
    _switchState = absence == null;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _animationController.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _switchState
                ? Theme.of(context).colorScheme.primary.withValues(alpha:0.2)
                : Colors.red.withValues(alpha:0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_switchState
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red)
                  .withValues(alpha:0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Barre de couleur latérale
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _switchState
                          ? [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha:0.7),
                      ]
                          : [
                        Colors.red,
                        Colors.red.withValues(alpha:0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _switchState
                          ? [
                        Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
                        Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                      ]
                          : [
                        Colors.red.withValues(alpha:0.2),
                        Colors.red.withValues(alpha:0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.repartition['name']
                          .toString()
                          .split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _switchState
                            ? Theme.of(context).colorScheme.primary
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.repartition['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.repartition['student']['matricule'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.repartition['student']['age']} ans",
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: SizedBox(
                  width: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: _switchState,
                          onChanged: _changing ? null : _onChange,
                          activeThumbColor: Theme.of(context).colorScheme.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.red.withValues(alpha:0.5),
                          trackOutlineColor: WidgetStateProperty.resolveWith(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.primary.withValues(alpha:0.5);
                              }
                              return Colors.red;
                            },
                          ),
                        ),
                      ),
                      if (_changing)
                        const Positioned(
                          child: LoadingIndicator(
                            type: LoadingIndicatorType.inkDrop,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onChange(bool value) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value
                      ? Theme.of(context).colorScheme.primary.withValues(alpha:0.1)
                      : Colors.red.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: value ? Theme.of(context).colorScheme.primary : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirmation',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "Voulez-vous marquer ${widget.repartition['name']} comme ${value ? 'présent(e)' : 'absent(e)'} ?",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _changing = true;
                });

                if (!value) {
                  Map<String, dynamic> data = {
                    'form_id': widget.irregularityForm['id'],
                    'entity': widget.irregularityForm['entity'],
                    'irregularity_date': widget.filterForm['date'],
                    'irregularity_time': widget.filterForm['time'],
                    'classe_id': widget.filterForm['classeId'],
                    'subject_id': widget.filterForm['subjectId'],
                    'student_id': widget.repartition['student_id'],
                    'type': 'absence'
                  };
                  Map<String, dynamic>? response =
                  await MasterCrudModel('irregularity').create(data);
                  if (response != null) {
                    setState(() {
                      _switchState = value;
                      absence = response;
                    });
                  }
                } else {
                  if (absence != null) {
                    Map<String, dynamic>? response =
                    await MasterCrudModel.delete(
                      absence?['id'],
                      'irregularity',
                    );
                    if (response != null) {
                      setState(() {
                        _switchState = value;
                        absence = null;
                      });
                    }
                  }
                }

                setState(() {
                  _changing = false;
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: value ? Theme.of(context).colorScheme.primary : Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}