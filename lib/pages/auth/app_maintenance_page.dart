import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive/hive.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppMaintenancePage extends StatefulWidget {
  const AppMaintenancePage({super.key});

  @override
  AppMaintenancePageState createState() {
    return AppMaintenancePageState();
  }
}

class AppMaintenancePageState extends State<AppMaintenancePage>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _clearAllAppData() async {
    try {
      // Récupérer les données utilisateur depuis le serveur
      final userData = await authProvider.fromServer();
      if (userData == null) {
        throw Exception('Impossible de récupérer les données utilisateur');
      }

      UserModel user = UserModel.fromMap(userData);

      // Nettoyer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Nettoyer les fichiers locaux
      try {
        final appDir = await getApplicationDocumentsDirectory();
        if (appDir.existsSync()) {
          appDir.deleteSync(recursive: true);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur suppression fichiers: $e');
        }
      }

      // Nettoyer le cache
      try {
        final cacheDir = await getTemporaryDirectory();
        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur suppression cache: $e');
        }
      }

      // Nettoyer Hive
      try {
        await Hive.deleteFromDisk();
      } catch (e) {
        if (kDebugMode) {
          print('Erreur suppression Hive: $e');
        }
      }

      // Restaurer l'utilisateur avec son token
      await authProvider.setCurrentUser(user);
      await authProvider.refreshUser();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du nettoyage: $e');
      }
      return false;
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirmation requise',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cette action va supprimer toutes les données locales :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            _buildWarningItem('Préférences d\'application'),
            _buildWarningItem('Données en cache'),
            _buildWarningItem('Fichiers temporaires'),
            _buildWarningItem('Données hors ligne'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Vos données de compte seront préservées et rechargées automatiquement',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performClearData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearData() async {
    setState(() => _isProcessing = true);

    // Afficher le dialogue de progression
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildProgressDialog(),
    );

    // Attendre un peu pour l'UX
    await Future.delayed(const Duration(seconds: 1));

    final success = await _clearAllAppData();

    if (mounted) {
      Navigator.pop(context); // Fermer le dialogue de progression
    }

    setState(() => _isProcessing = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  Widget _buildProgressDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nettoyage en cours...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Succès'),
          ],
        ),
        content: const Text(
          'Les données locales ont été nettoyées avec succès. '
          'Votre compte a été rechargé.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try{
                await restartApp(context);
              }catch(e){
                if (kDebugMode) {
                  print(e.toString());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Redémarrer'),
          ),
        ],
      ),
    );
  }

  static Future<void> restartApp(BuildContext context) async {
    try {
      await Hive.close();
      HiveService.reinit();
      Phoenix.rebirth(context);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du redémarrage: $e');
      }
      HiveService.reinit();
      Phoenix.rebirth(context);
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Erreur'),
          ],
        ),
        content: const Text(
          'Une erreur est survenue lors du nettoyage. '
              'Veuillez réessayer ou contacter le support.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showClearDataDialog();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: AppBar(
        leading: AppBarBackButton(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Maintenance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête informatif
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Maintenance de l\'application',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effectuez des opérations de maintenance pour optimiser les performances de l\'application',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Option de nettoyage
                _buildMaintenanceCard(
                  context: context,
                  icon: Icons.cleaning_services_rounded,
                  iconColor: Colors.orange,
                  title: 'Nettoyer les données locales',
                  description:
                  'Supprime le cache, les préférences et les fichiers temporaires',
                  buttonText: 'Nettoyer',
                  buttonColor: Colors.orange,
                  onPressed: _isProcessing ? null : _showClearDataDialog,
                  warnings: [
                    'Si vous avez des données non synchronisées, elles seront perdues',
                    'Cette action est irréversible',
                    'Les données en ligne restent intactes',
                    'Redémarrage de l\'app recommandé',
                  ],
                ),

                const SizedBox(height: 16),

                // Avertissement général
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Assurez-vous d\'avoir une connexion internet stable avant d\'effectuer ces opérations.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback? onPressed,
    required List<String> warnings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Icône et titre
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Avertissements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Avertissements',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...warnings.map(
                            (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isProcessing) ...[
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          _isProcessing ? 'Traitement...' : buttonText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}