import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/core/extensions/list_extension.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        leading: AppBarBackButton(),
        title: const Text(
          "Modèles de bulletin",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: Colors.white.withValues(alpha:0.8),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.all(4),
                      tabs: const [
                        Tab(text: 'COLLÈGE'),
                        Tab(text: 'LYCÉE'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: LoadingIndicator())
                : TabBarView(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator(),
              const SizedBox(height: 16),
              Text(
                'Activation en cours...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = selected == template['value'];

        return _TemplateCard(
          template: template,
          isSelected: isSelected,
          degree: degree,
          onActive: onActive,
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final bool isSelected;
  final String degree;
  final Function onActive;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.degree,
    required this.onActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPreview(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey.shade200,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha:0.2)
                    : Colors.black.withValues(alpha:0.06),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: template['img'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      template['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.palette_outlined,
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
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon: isSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            onPressed: () {
                              if (!isSelected) {
                                onActive(degree, template['value']);
                              }
                            },
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey.shade600,
                            filled: isSelected,
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
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height - 80,
          margin: const EdgeInsets.only(top: 80),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      template['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: template['img'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color.withValues(alpha:0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: filled ? color.withValues(alpha:0.3) : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: color,
          ),
        ),
      ),
    );
  }
}