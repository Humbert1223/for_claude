import 'package:flutter/material.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/pages/admin/informations/announce_data_page.dart';
import 'package:novacole/pages/admin/informations/event_data_page.dart';

class InformationSubmenuPage extends StatefulWidget {
  const InformationSubmenuPage({super.key});

  @override
  InformationSubmenuPageState createState() {
    return InformationSubmenuPageState();
  }
}

class InformationSubmenuPageState extends State<InformationSubmenuPage> {
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Informations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubMenuWidget(
                icon: Icons.newspaper,
                title: 'Annonces',
                subtitle: 'Annonces, articles...',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AnnounceDataPage()),
                  );
                },
              ),
              SubMenuWidget(
                icon: Icons.calendar_today,
                title: 'Événements',
                subtitle: 'Réunion des parents, programme de semaine culturelle ...',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EventDataPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}