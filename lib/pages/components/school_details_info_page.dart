import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as get_x;
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';

class SchoolDetailsInfoPage extends StatefulWidget {
  final Widget? child;
  final String title;

  const SchoolDetailsInfoPage({super.key, this.child, required this.title});

  @override
  State<StatefulWidget> createState() {
    return SchoolDetailsInfoPageState();
  }
}

class SchoolDetailsInfoPageState extends State<SchoolDetailsInfoPage> {
  Map<String, dynamic>? school;
  final authController = get_x.Get.find<AuthController>();
  @override
  void initState() {
    school = authController.currentSchool.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(85),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0, bottom: 5),
            child:
                (school == null)
                    ? SizedBox()
                    : Row(
                      children: [
                        ModelPhotoWidget(
                          model: school!,
                          editable: false,
                          photoKey: 'logo_url',
                          height: 90,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${school!['name']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle?.color,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 160,
                              child: Text(
                                "${school!['address']}",
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14.0,
                                  color:
                                      Theme.of(
                                        context,
                                      ).appBarTheme.titleTextStyle?.color,
                                ),
                              ),
                            ),
                            Text(
                              "Tél : ${school!['phone'] ?? '-'}",
                              style: TextStyle(
                                fontSize: 14.0,
                                color:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle?.color,
                              ),
                            ),
                            Text(
                              "Type : ${StringTranslateExtension(school!['type'].toString()).tr()}",
                              style: TextStyle(
                                fontSize: 14.0,
                                color:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(8.0), child: widget.child),
    );
  }
}
