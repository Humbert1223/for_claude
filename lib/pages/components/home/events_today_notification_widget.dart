import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/event_page.dart';

class EventTodayNotificationWidget extends StatefulWidget {
  const EventTodayNotificationWidget({super.key});

  @override
  EventTodayNotificationWidgetState createState() =>
      EventTodayNotificationWidgetState();
}

class EventTodayNotificationWidgetState
    extends State<EventTodayNotificationWidget> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final user = await UserModel.fromLocalStorage();
      if ((user?.schools ?? []).isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final filters = [
        {
          'field': 'event_date',
          'operator': 'DATE',
          'value': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }
      ];

      final response = await MasterCrudModel('event').search(
        paginate: '0',
        filters: filters,
      );

      if (mounted) {
        setState(() {
          _events = response != null
              ? List<Map<String, dynamic>>.from(response)
              : [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EventPage()),
            );
          },
          icon: Icon(
            Icons.calendar_month_rounded,
            size: 26,
            color: Theme.of(context).primaryColor,
          ),
          tooltip: 'Événements',
        ),
        if (!_loading && _events.isNotEmpty)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha:0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  _events.length > 9 ? '9+' : '${_events.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}