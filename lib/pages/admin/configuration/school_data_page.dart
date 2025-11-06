import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class SchoolDataPage extends StatefulWidget {
  const SchoolDataPage({super.key});

  @override
  SchoolDataPageState createState() {
    return SchoolDataPageState();
  }
}

class SchoolDataPageState extends State<SchoolDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then(
      (value) {
        setState(() {
          user = value;
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (school) {
              return SchoolInfoWidget(school: school);
            },
            dataModel: 'school',
            paginate: PaginationValue.paginated,
            title: 'Mes écoles',
            data: {
              'filters': [
                {'field': 'created_by', 'operator': '=', 'value': user?.id}
              ],
            },
          )
        : Container();
  }
}

class SchoolInfoWidget extends StatelessWidget {
  final Map<String, dynamic> school;

  const SchoolInfoWidget({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icône avec gradient
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha:0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),

        // Contenu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de l'école
              Text(
                school['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Informations avec icônes et texte
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Numéro d'enregistrement
                  _buildInfoRow(
                    icon: Icons.badge_rounded,
                    label: 'N°:',
                    value: school['registration_number'] ?? '-',
                    color: Colors.indigo.shade600,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),

                  // Téléphone
                  _buildInfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Tél:',
                    value: school['phone'] ?? '-',
                    color: Colors.green.shade600,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),

                  // Adresse
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'Adresse:',
                    value: school['address'] ?? '-',
                    color: Colors.orange.shade600,
                    isDark: isDark,
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget pour les lignes d'information avec icône
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha:0.9) : Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withValues(alpha:0.7) : Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}