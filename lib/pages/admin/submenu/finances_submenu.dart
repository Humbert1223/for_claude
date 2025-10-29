import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/pages/admin/finances/other_incoming_page.dart';
import 'package:novacole/pages/admin/finances/other_outgoing_page.dart';
import 'package:novacole/pages/admin/finances/payment_request_page.dart';
import 'package:novacole/pages/admin/finances/registration_fees_page.dart';
import 'package:novacole/pages/admin/finances/salary_fees_page.dart';
import 'package:novacole/pages/admin/finances/school_fees_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class FinancesSubmenuPage extends StatefulWidget {
  const FinancesSubmenuPage({super.key});

  @override
  FinancesSubmenuPageState createState() {
    return FinancesSubmenuPageState();
  }
}

class FinancesSubmenuPageState extends State<FinancesSubmenuPage> {
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
          'Finances',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.paymentRequest),
                child: SubMenuWidget(
                  icon: Icons.monetization_on_outlined,
                  title: "Demandes de paiement",
                  subtitle: "Les demandes de paiement effectuées par les parents et partenaires",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdminPaymentRequestPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.operation),
                child: SubMenuWidget(
                  icon: Icons.money,
                  title: "Frais d'inscription",
                  subtitle: "Gestion des frais d'inscription",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegistrationFeesPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.operation),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.moneyBill1,
                  title: 'Frais de scolarité',
                  subtitle: 'Gestion des frais de scolarité',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SchoolFeesPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.operation),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.wallet,
                  title: 'Salaires',
                  subtitle: 'Gestion des charges salariales',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SalaryFeesPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.operation),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.handHoldingDollar,
                  title: 'Autres recettes',
                  subtitle: 'Cotisations, vente de fourniture ...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OtherIncomingPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.operation),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.dollarSign,
                  title: 'Autres charges',
                  subtitle: 'Électricité, achat fournitures ...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OtherOutgoingPage()),
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