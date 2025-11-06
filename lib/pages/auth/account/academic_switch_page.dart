import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/main.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:provider/provider.dart';

class UserAcademicSelectForm extends StatefulWidget {
  const UserAcademicSelectForm({super.key});

  @override
  UserAcademicSelectFormState createState() => UserAcademicSelectFormState();
}

class UserAcademicSelectFormState extends State<UserAcademicSelectForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMainContainer(context, auth),
        );
      },
    );
  }

  // Construction du conteneur principal
  Widget _buildMainContainer(BuildContext context, AuthProvider auth) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSelectInput(context, auth),
          ],
        ),
      ),
    );
  }

  // Construction de l'en-tête avec icône et textes
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _buildIconContainer(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Année scolaire',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "L'année que vous souhaitez gérer",
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Construction du conteneur d'icône
  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.calendar_today_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // Construction du champ de sélection
  Widget _buildSelectInput(BuildContext context, AuthProvider auth) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ModelFormInputSelect(
        item: {
          'field': 'academic_id',
          'entity': 'academic',
          'type': 'selectresource',
          'name': 'Année scolaire',
          'placeholder': 'Sélectionner une année',
          'value': auth.currentUser.academic,
          'filters': [
            {
              'field': 'school_id',
              'operator': '=',
              'value': auth.currentUser.school,
            },
            {
              'field': 'started_at',
              'operator': '!=',
              'value': null,
            },
          ],
        },
        onChange: (value) => _handleAcademicYearChange(context, auth, value),
      ),
    );
  }

  // Gestion du changement d'année scolaire
  Future<void> _handleAcademicYearChange(
      BuildContext context,
      AuthProvider auth,
      dynamic value,
      ) async {
    // Affichage du dialog de chargement
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => _buildLoadingDialog(context),
    );

    try {
      // Mise à jour de l'année scolaire
      final response = await MasterCrudModel.patch(
        '/auth/user/academic/update',
        {'academic_id': value},
      );

      if (response != null) {
        // Rafraîchissement des données utilisateur
        await auth.refreshUser();

        // Fermeture du dialog de chargement
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Navigation vers la page d'accueil
        if (context.mounted) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/',
                (route) => false,
          );
        }
      } else {
        // Gestion du cas où la réponse est nulle
        if (context.mounted) {
          Navigator.of(context).pop();
          _showErrorSnackBar(context, 'Erreur lors de la mise à jour');
        }
      }
    } catch (e) {
      // Gestion des erreurs
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(
          context,
          'Erreur de chargement: ${e.toString()}',
        );
      }
    }
  }

  // Construction du dialog de chargement
  Widget _buildLoadingDialog(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Changement en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Affichage d'un message d'erreur
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}