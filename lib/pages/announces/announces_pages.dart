import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/announces/announces_details_pages.dart';

class AnnouncesPage extends StatefulWidget {
  const AnnouncesPage({super.key});

  @override
  AnnouncesPageState createState() {
    return AnnouncesPageState();
  }
}

class AnnouncesPageState extends State<AnnouncesPage> {
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
          'Actualités',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: FutureBuilder(
        future: MasterCrudModel('post').search(
          paginate: '0',
          data: {
            'columns': ['name', 'updated_at', 'image', 'school_id', 'created_by'],
            'relations': ['school', 'user']
          },
        ),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          } else {
            if (snap.hasData &&
                snap.data != null &&
                List.from(snap.data).isNotEmpty) {
              return ListView(
                children: [
                  ...List.from(snap.data).map((announce) {
                    String date = DateFormat('dd MMM yyyy').format(
                      DateTime.parse(
                        announce['updated_at'],
                      ),
                    );
                    String heure = DateFormat('HH:mm').format(
                      DateTime.parse(
                        announce['updated_at'],
                      ),
                    );
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AnnounceDetailsPage(announce: announce);
                              },
                            ),
                          );
                        },
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(right: 10),
                              color: Colors.white,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/un_journal.png'),
                                )),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 160,
                                  child: Text(
                                    announce['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Publié le: $date à $heure",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Par: ${announce['user']?['name'] ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  })
                ],
              );
            } else {
              return const EmptyPage(
                icon: Icon(FontAwesomeIcons.newspaper),
                sub: Text('Aucune actualité'),
              );
            }
          }
        },
      ),
    );
  }
}
