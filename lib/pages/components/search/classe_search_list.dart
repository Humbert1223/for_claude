import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/classe_details.dart';
import 'package:novacole/pages/classe_page.dart';

class ClasseSearchResultList extends StatefulWidget {
  final String? term;

  const ClasseSearchResultList({super.key, this.term});

  @override
  ClasseSearchResultListState createState() {
    return ClasseSearchResultListState();
  }
}

class ClasseSearchResultListState extends State<ClasseSearchResultList> {
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
    return Column(
      children: [
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const Icon(Icons.account_box_outlined),
          title: const Text(
            "Classes scolaires",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          trailing: TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ClasseListPage();
              }));
            },
            child: const Text(
              "Voir tous",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Divider(
          height: 2,
          color: Theme.of(context).primaryColor,
        ),
        if (widget.term != null)
          FutureBuilder(
            future: MasterCrudModel('classe').search(
              paginate: '0',
              query: {'term': widget.term, 'limit': 4},
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator(
                  type: LoadingIndicatorType.waveDot,
                );
              } else {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return Column(
                    children: List<Map<String, dynamic>>.from(snapshot.data)
                        .map((item) {
                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClasseInfoWidget(
                            classe: item,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ClasseDetails(classe: item);
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const EmptyPage(
                    icon: Icon(Icons.people),
                  );
                }
              }
            },
          )
        else
          const EmptyPage(
            icon: Icon(Icons.people),
          )
      ],
    );
  }
}
