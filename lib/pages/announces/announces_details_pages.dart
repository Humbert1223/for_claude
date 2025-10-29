import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class AnnounceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> announce;

  const AnnounceDetailsPage({super.key, required this.announce});

  @override
  AnnounceDetailsPageState createState() {
    return AnnounceDetailsPageState();
  }
}

class AnnounceDetailsPageState extends State<AnnounceDetailsPage> {
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
          'Détails',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: FutureBuilder(
        future: MasterCrudModel('post').get(
          '${widget.announce['id']}',
          query: {'relations': 'user,school'}
        ),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          } else {
            if (snap.hasData && snap.data != null) {
              String date = DateFormat('dd MMM yyyy').format(
                DateTime.parse(
                  snap.data['updated_at'],
                ),
              );
              String heure = DateFormat('HH:mm').format(
                DateTime.parse(
                  snap.data['updated_at'],
                ),
              );
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(right: 10),
                      color: Colors.white,
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage('assets/images/un_journal.png'),
                        )),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 160,
                      child: Text(
                        "${snap.data['name']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Publié le: $date à $heure",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Par: ${snap.data['user']?['name'] ?? '-'}",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: HtmlWidget(
                        snap.data['content'],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const EmptyPage(
                icon: Icon(FontAwesomeIcons.newspaper),
                sub: Text('Erreur de chargement !'),
              );
            }
          }
        },
      ),
    );
  }
}
