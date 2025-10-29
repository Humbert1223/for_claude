import 'package:flutter/material.dart';
import 'package:novacole/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  String appVersion = '';
  String appBuildNumber = '';

  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuildNumber = packageInfo.buildNumber;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo_3.png'),
                        fit: BoxFit.contain,
                      )),
                ),
              ),
              const Text(
                kAppName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  fontFamily: 'roboto',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Version $appVersion (build $appBuildNumber)',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'roboto',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '© 2024 EVOLUTION PLUS CORP.',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'roboto',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                kAppDescription,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'roboto',
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: TextButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(kAppPrivacyUrl));
                  },
                  child: const Text(
                    'Politique de Confidentialité',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
