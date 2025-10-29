import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/utils/tools.dart';

class ClasseCardDownloadPage extends StatelessWidget {
  final Map<String, dynamic> classe;

  const ClasseCardDownloadPage({super.key, required this.classe});

  @override
  Widget build(BuildContext context) {
    const templates = ['default', 'fado'];
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
          "Impression des carte de classe",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 100),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0, bottom: 5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${classe['name']}",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                  Text(
                    "Serie : ${classe['serie']?['name'] ?? '-'}",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(
                        context,
                      ).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                  Text(
                    "Effectif : ${classe['effectif'] ?? '-'}",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(
                        context,
                      ).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                  Text(
                    "Titulaire : ${classe['titulaire_full_name'] ?? '-'}",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(
                        context,
                      ).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Card(
              elevation: 10,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            "https://novacole-bucket.fr-par-1.linodeobjects.com/templates/images/cards/${templates[index]}.png",
                          ),
                          fit: BoxFit.fill,
                          opacity: 0.7,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      onPressed: () {
                        _handleDownload(context, templates[index]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Icon(Icons.cloud_download_rounded),
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 20);
          },
          itemCount: templates.length,
        ),
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, template) async {
    Map<String, dynamic> data = {'template': template};

    if (context.mounted) {
      _showDownloadingDialog(context);
    }

    try {
      await NovaTools.download(
        uri: "/reports/classe/${classe['id']}/school-card",
        name: "carte_identite_scolaire_${classe['name']}.pdf",
        data: data,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showDownloadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        children: [
          LoadingIndicator(type: LoadingIndicatorType.inkDrop),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Téléchargement en cours...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
