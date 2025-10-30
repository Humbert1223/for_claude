import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/admin/actors/tutor_details.dart';

class StudentTutorListPage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentTutorListPage({super.key, required this.student});

  @override
  StudentTutorListPageState createState() {
    return StudentTutorListPageState();
  }
}

class StudentTutorListPageState extends State<StudentTutorListPage> {
  List<Map<String, dynamic>> tutors = [];
  bool isLoading = false;

  @override
  void initState() {
    _loadTutors();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    } else {
      if (tutors.isEmpty) {
        return const EmptyPage();
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            _loadTutors();
          },
          child: ListView(
            primary: false,
            shrinkWrap: true,
            children: tutors.map((tutor) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TutorDetails(tutor: tutor);
                    }));
                  },
                  title: Row(
                    children: [
                      if (tutor['photo_url'] != null)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                tutor['photo_url'],
                              ),
                              fit: BoxFit.cover
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/person.jpeg',
                              ),
                              fit: BoxFit.cover
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${tutor['full_name']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Téléphone : ${tutor['phone']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Adresse : ${tutor['address']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_outlined),
                ),
              );
            }).toList(),
          ),
        );
      }
    }
  }

  _loadTutors() async {
    setState(() {
      isLoading = true;
    });
    var res = await MasterCrudModel('tutor').search(
      paginate: '0',
      filters: [
        {
          'field': 'student_ids',
          'operator': 'all',
          'value': [widget.student['id']]
        },
      ],
      query: {'order_by': 'last_name'},
    );
    if (res != null) {
      setState(() {
        tutors = List<Map<String, dynamic>>.from(res);
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
