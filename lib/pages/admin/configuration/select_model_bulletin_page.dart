import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/configuration/customize_bulletin_template_page.dart';
import 'package:novacole/utils/constants.dart';

class SelectModelBulletinPage extends StatefulWidget {
  const SelectModelBulletinPage({super.key});

  @override
  SelectModelBulletinPageState createState() => SelectModelBulletinPageState();
}

class SelectModelBulletinPageState extends State<SelectModelBulletinPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? school;

  final String imagePath =
      'https://novacole-bucket.fr-par-1.linodeobjects.com/templates/images/bulletins';

  late final List<Map<String, dynamic>> templates = [
    {'name': 'Défaut', 'value': 'default', 'img': "$imagePath/default.png"},
    {'name': 'Classique', 'value': 'classic', 'img': "$imagePath/classic.png"},
    {'name': 'Étendu', 'value': 'expanded', 'img': "$imagePath/expanded.png"},
    {'name': 'Fado', 'value': 'fado', 'img': "$imagePath/fado.png"},
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    UserModel.fromLocalStorage().then((value) async {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic>? sc = await MasterCrudModel.find(
        '/metamorph/master/${Entity.school}/${value?.school}',
      );
      setState(() {
        school = sc;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          "Modèles de bulletin",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorPadding: EdgeInsets.zero,
          tabAlignment: TabAlignment.fill,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.white,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            border: Border.all(style: BorderStyle.none),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: 'COLLÈGE'),
            Tab(text: 'LYCÉE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TemplatesGrid(
            templates: templates,
            degree: 'college',
            selected: activeTemplate('college'),
            onActive: onActive,
          ),
          TemplatesGrid(
            templates: templates,
            degree: 'high_school',
            selected: activeTemplate('high_school'),
            onActive: onActive,
          ),
        ],
      ),
    );
  }

  String activeTemplate(String degree) {
    if (school == null) return 'default';
    List<Map<String, dynamic>> templates = List<Map<String, dynamic>>.from(
      school?['bulletin_templates'] ?? [],
    );
    return templates.firstWhereOrNull(
          (element) => element['degree'] == degree,
        )?['name'] ??
        'default';
  }

  Future<void> onActive(String degree, String name) async {
    _showBottomSheet();
    Map<String, dynamic>? data = await MasterCrudModel.patch(
      '/school/bulletin-template',
      {'degree': degree, 'name': name},
    );

    if (data != null) {
      if (mounted) {
        setState(() {
          school = data;
        });
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _showBottomSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [LoadingIndicator(), Text('Activation en cours ...')],
          ),
        );
      },
      isDismissible: false,
    );
  }
}

class TemplatesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> templates;
  final String? selected;
  final Function onActive;
  final String degree;

  const TemplatesGrid({
    super.key,
    required this.templates,
    required this.degree,
    this.selected = 'default',
    required this.onActive,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = selected == template['value'];

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        imageUrl: template['img'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            elevation: isSelected ? 4 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: template['img'],
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        template['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CustomizeBulletinTemplatePage(
                                        bulletinData: template,
                                        degree: degree,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.design_services,
                                size: 30,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: IconButton(
                              onPressed: () async {
                                onActive(degree, template['value']);
                              },
                              color: Theme.of(context).colorScheme.primary,
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
