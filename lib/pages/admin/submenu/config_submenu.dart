import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/pages/admin/configuration/academic_data_page.dart';
import 'package:novacole/pages/admin/configuration/classe_data_page.dart';
import 'package:novacole/pages/admin/configuration/expense_lines_data_page.dart';
import 'package:novacole/pages/admin/configuration/fees/fees_select_level_page.dart';
import 'package:novacole/pages/admin/configuration/payment_method_data_page.dart';
import 'package:novacole/pages/admin/configuration/period_data_page.dart';
import 'package:novacole/pages/admin/configuration/school_data_page.dart';
import 'package:novacole/pages/admin/configuration/select_model_bulletin_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class ConfigSubmenuPage extends StatefulWidget {
  const ConfigSubmenuPage({super.key});

  @override
  ConfigSubmenuPageState createState() {
    return ConfigSubmenuPageState();
  }
}

class ConfigSubmenuPageState extends State<ConfigSubmenuPage> {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Configurations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubMenuWidget(
                icon: FontAwesomeIcons.schoolCircleCheck,
                title: "Écoles",
                subtitle: 'Mes écoles',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SchoolDataPage()),
                  );
                },
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.academic),
                child: SubMenuWidget(
                  icon: Icons.calendar_month,
                  title: 'Années scolaires',
                  subtitle: "Création, ouverture, clôture...",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AcademicDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.classe),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.peopleLine,
                  title: 'Classes',
                  subtitle: 'Classes scolaires',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ClassesDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.paymentMethod),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.moneyCheck,
                  title: 'Moyens de paiement',
                  subtitle: 'Moyens de paiement mis à disposition des clients',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PaymentMethodDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.expense),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.moneyBillTransfer,
                  title: 'Lignes de dépenses',
                  subtitle: 'Dépenses courantes à suivre',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ExpenseLineDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.period),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.calendarDays,
                  title: 'Périodes scolaire',
                  subtitle: 'Création, ouverture, clôture ...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PeriodDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.tuition),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.moneyBill,
                  title: 'Frais de scolarité',
                  subtitle: "Écolages, frais d'inscriptions...",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FeesSelectLevelPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.update(Entity.school),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.file,
                  title: 'Modèles de bulletin',
                  subtitle: 'Choix du modèle de bulletin',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SelectModelBulletinPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}