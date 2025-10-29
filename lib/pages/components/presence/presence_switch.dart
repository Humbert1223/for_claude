import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class PresenceSwitch extends StatefulWidget {
  final Map<String, dynamic> repartition;
  final Map<String, dynamic> filterForm;
  final Map<String, dynamic> irregularityForm;

  const PresenceSwitch({
    super.key,
    required this.filterForm,
    required this.repartition,
    required this.irregularityForm,
  });

  @override
  PresenceSwitchState createState() {
    return PresenceSwitchState();
  }
}

class PresenceSwitchState extends State<PresenceSwitch> {
  late bool _switchState = true;
  late bool _changing = false;
  late Map<String, dynamic>? absence;

  @override
  void initState() {
    absence = widget.repartition['absence'];
    _switchState = absence == null;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          widget.repartition['name'],
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Matricule : ${widget.repartition['student']['matricule']}",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            Text(
              "Âge : ${widget.repartition['student']['age']}",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 50,
          child: Stack(
            children: [
              Positioned(
                child: Switch(
                  value: _switchState,
                  onChanged: _changing ? null : _onChange,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.red,
                  trackOutlineColor: WidgetStateProperty.resolveWith(
                    (final Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return null;
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
                )
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
          title: const Text('Absence'),
          content: Text(
              "Voulez-vous marquer ${widget.repartition['name']} comme ${value ? 'présent(e)' : 'absent(e)'} ?"),
          actions: [
            TextButton(
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
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Non',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
