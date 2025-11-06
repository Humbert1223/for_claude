import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/my_button.dart';
import 'package:novacole/components/my_textfield.dart';
import 'package:novacole/models/master_crud_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

const countryIso = {
  "field": "country_iso",
  "type": "select",
  "name": "Pays de résidence",
  "placeholder": "Sélectionner le pays",
  "options": [
    {"label": "Afghanistan", "value": "AF"},
    {"label": "Afrique du Sud", "value": "ZA"},
    {"label": "Albanie", "value": "AL"},
    {"label": "Algérie", "value": "DZ"},
    {"label": "Allemagne", "value": "DE"},
    {"label": "Andorre", "value": "AD"},
    {"label": "Angola", "value": "AO"},
    {"label": "Antigua-et-Barbuda", "value": "AG"},
    {"label": "Arabie saoudite", "value": "SA"},
    {"label": "Argentine", "value": "AR"},
    {"label": "Arménie", "value": "AM"},
    {"label": "Australie", "value": "AU"},
    {"label": "Autriche", "value": "AT"},
    {"label": "Azerbaïdjan", "value": "AZ"},
    {"label": "Bahamas", "value": "BS"},
    {"label": "Bahreïn", "value": "BH"},
    {"label": "Bangladesh", "value": "BD"},
    {"label": "Barbade", "value": "BB"},
    {"label": "Belgique", "value": "BE"},
    {"label": "Belize", "value": "BZ"},
    {"label": "Bénin", "value": "BJ"},
    {"label": "Bhoutan", "value": "BT"},
    {"label": "Biélorussie", "value": "BY"},
    {"label": "Birmanie", "value": "MM"},
    {"label": "Bolivie", "value": "BO"},
    {"label": "Bosnie-Herzégovine", "value": "BA"},
    {"label": "Botswana", "value": "BW"},
    {"label": "Brésil", "value": "BR"},
    {"label": "Brunei", "value": "BN"},
    {"label": "Bulgarie", "value": "BG"},
    {"label": "Burkina Faso", "value": "BF"},
    {"label": "Burundi", "value": "BI"},
    {"label": "Cambodge", "value": "KH"},
    {"label": "Cameroun", "value": "CM"},
    {"label": "Canada", "value": "CA"},
    {"label": "Cap-Vert", "value": "CV"},
    {"label": "République centrafricaine", "value": "CF"},
    {"label": "Chili", "value": "CL"},
    {"label": "Chine", "value": "CN"},
    {"label": "Chypre", "value": "CY"},
    {"label": "Colombie", "value": "CO"},
    {"label": "Comores", "value": "KM"},
    {"label": "Congo (Brazzaville)", "value": "CG"},
    {"label": "Congo (Kinshasa)", "value": "CD"},
    {"label": "Corée du Nord", "value": "KP"},
    {"label": "Corée du Sud", "value": "KR"},
    {"label": "Costa Rica", "value": "CR"},
    {"label": "Côte d'Ivoire", "value": "CI"},
    {"label": "Croatie", "value": "HR"},
    {"label": "Cuba", "value": "CU"},
    {"label": "Danemark", "value": "DK"},
    {"label": "Djibouti", "value": "DJ"},
    {"label": "Dominique", "value": "DM"},
    {"label": "Égypte", "value": "EG"},
    {"label": "Émirats arabes unis", "value": "AE"},
    {"label": "Équateur", "value": "EC"},
    {"label": "Érythrée", "value": "ER"},
    {"label": "Espagne", "value": "ES"},
    {"label": "Estonie", "value": "EE"},
    {"label": "Eswatini", "value": "SZ"},
    {"label": "États-Unis", "value": "US"},
    {"label": "Éthiopie", "value": "ET"},
    {"label": "Fidji", "value": "FJ"},
    {"label": "Finlande", "value": "FI"},
    {"label": "France", "value": "FR"},
    {"label": "Gabon", "value": "GA"},
    {"label": "Gambie", "value": "GM"},
    {"label": "Géorgie", "value": "GE"},
    {"label": "Ghana", "value": "GH"},
    {"label": "Grèce", "value": "GR"},
    {"label": "Grenade", "value": "GD"},
    {"label": "Guatemala", "value": "GT"},
    {"label": "Guinée", "value": "GN"},
    {"label": "Guinée-Bissau", "value": "GW"},
    {"label": "Guinée équatoriale", "value": "GQ"},
    {"label": "Guyana", "value": "GY"},
    {"label": "Haïti", "value": "HT"},
    {"label": "Honduras", "value": "HN"},
    {"label": "Hongrie", "value": "HU"},
    {"label": "Îles Cook", "value": "CK"},
    {"label": "Îles Marshall", "value": "MH"},
    {"label": "Îles Salomon", "value": "SB"},
    {"label": "Inde", "value": "IN"},
    {"label": "Indonésie", "value": "ID"},
    {"label": "Irak", "value": "IQ"},
    {"label": "Iran", "value": "IR"},
    {"label": "Irlande", "value": "IE"},
    {"label": "Islande", "value": "IS"},
    {"label": "Israël", "value": "IL"},
    {"label": "Italie", "value": "IT"},
    {"label": "Jamaïque", "value": "JM"},
    {"label": "Japon", "value": "JP"},
    {"label": "Jordanie", "value": "JO"},
    {"label": "Kazakhstan", "value": "KZ"},
    {"label": "Kenya", "value": "KE"},
    {"label": "Kirghizistan", "value": "KG"},
    {"label": "Kiribati", "value": "KI"},
    {"label": "Kosovo", "value": "XK"},
    {"label": "Koweït", "value": "KW"},
    {"label": "Laos", "value": "LA"},
    {"label": "Lesotho", "value": "LS"},
    {"label": "Lettonie", "value": "LV"},
    {"label": "Liban", "value": "LB"},
    {"label": "Libéria", "value": "LR"},
    {"label": "Libye", "value": "LY"},
    {"label": "Liechtenstein", "value": "LI"},
    {"label": "Lituanie", "value": "LT"},
    {"label": "Luxembourg", "value": "LU"},
    {"label": "Madagascar", "value": "MG"},
    {"label": "Malaisie", "value": "MY"},
    {"label": "Malawi", "value": "MW"},
    {"label": "Maldives", "value": "MV"},
    {"label": "Mali", "value": "ML"},
    {"label": "Malte", "value": "MT"},
    {"label": "Maroc", "value": "MA"},
    {"label": "Maurice", "value": "MU"},
    {"label": "Mauritanie", "value": "MR"},
    {"label": "Mexique", "value": "MX"},
    {"label": "Micronésie", "value": "FM"},
    {"label": "Moldavie", "value": "MD"},
    {"label": "Monaco", "value": "MC"},
    {"label": "Mongolie", "value": "MN"},
    {"label": "Monténégro", "value": "ME"},
    {"label": "Mozambique", "value": "MZ"},
    {"label": "Namibie", "value": "NA"},
    {"label": "Nauru", "value": "NR"},
    {"label": "Népal", "value": "NP"},
    {"label": "Nicaragua", "value": "NI"},
    {"label": "Niger", "value": "NE"},
    {"label": "Nigeria", "value": "NG"},
    {"label": "Norvège", "value": "NO"},
    {"label": "Nouvelle-Zélande", "value": "NZ"},
    {"label": "Oman", "value": "OM"},
    {"label": "Ouganda", "value": "UG"},
    {"label": "Ouzbékistan", "value": "UZ"},
    {"label": "Pakistan", "value": "PK"},
    {"label": "Palaos", "value": "PW"},
    {"label": "Palestine", "value": "PS"},
    {"label": "Panama", "value": "PA"},
    {"label": "Papouasie-Nouvelle-Guinée", "value": "PG"},
    {"label": "Paraguay", "value": "PY"},
    {"label": "Pays-Bas", "value": "NL"},
    {"label": "Pérou", "value": "PE"},
    {"label": "Philippines", "value": "PH"},
    {"label": "Pologne", "value": "PL"},
    {"label": "Portugal", "value": "PT"},
    {"label": "Qatar", "value": "QA"},
    {"label": "République tchèque", "value": "CZ"},
    {"label": "Roumanie", "value": "RO"},
    {"label": "Royaume-Uni", "value": "GB"},
    {"label": "Russie", "value": "RU"},
    {"label": "Rwanda", "value": "RW"},
    {"label": "Saint-Kitts-et-Nevis", "value": "KN"},
    {"label": "Saint-Marin", "value": "SM"},
    {"label": "Saint-Vincent-et-les-Grenadines", "value": "VC"},
    {"label": "Sainte-Lucie", "value": "LC"},
    {"label": "Salvador", "value": "SV"},
    {"label": "Samoa", "value": "WS"},
    {"label": "São Tomé-et-Principe", "value": "ST"},
    {"label": "Sénégal", "value": "SN"},
    {"label": "Serbie", "value": "RS"},
    {"label": "Seychelles", "value": "SC"},
    {"label": "Sierra Leone", "value": "SL"},
    {"label": "Singapour", "value": "SG"},
    {"label": "Slovaquie", "value": "SK"},
    {"label": "Slovénie", "value": "SI"},
    {"label": "Somalie", "value": "SO"},
    {"label": "Soudan", "value": "SD"},
    {"label": "Soudan du Sud", "value": "SS"},
    {"label": "Sri Lanka", "value": "LK"},
    {"label": "Suède", "value": "SE"},
    {"label": "Suisse", "value": "CH"},
    {"label": "Suriname", "value": "SR"},
    {"label": "Syrie", "value": "SY"},
    {"label": "Tadjikistan", "value": "TJ"},
    {"label": "Tanzanie", "value": "TZ"},
    {"label": "Tchad", "value": "TD"},
    {"label": "Thaïlande", "value": "TH"},
    {"label": "Timor oriental", "value": "TL"},
    {"label": "Togo", "value": "TG"},
    {"label": "Tonga", "value": "TO"},
    {"label": "Trinité-et-Tobago", "value": "TT"},
    {"label": "Tunisie", "value": "TN"},
    {"label": "Turkménistan", "value": "TM"},
    {"label": "Turquie", "value": "TR"},
    {"label": "Tuvalu", "value": "TV"},
    {"label": "Ukraine", "value": "UA"},
    {"label": "Uruguay", "value": "UY"},
    {"label": "Vanuatu", "value": "VU"},
    {"label": "Vatican", "value": "VA"},
    {"label": "Venezuela", "value": "VE"},
    {"label": "Viêt Nam", "value": "VN"},
    {"label": "Yémen", "value": "YE"},
    {"label": "Zambie", "value": "ZM"},
    {"label": "Zimbabwe", "value": "ZW"},
  ],
  "required": true,
  "default": "TG",
  "readOnly": true,
};

class RegisterPageState extends State<RegisterPage> {
  bool passIsVisible = false;

  final nameController = TextEditingController();
  final firstNameController = TextEditingController();
  final birthdateController = TextEditingController();
  final birthCityController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  String? gender = 'male';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha:0.95),
            ]
                : [
              colorScheme.primary.withValues(alpha:0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo et titre avec animation
                  Hero(
                    tag: 'logo',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha:0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha:0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/logo_3.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Rejoignez-nous dès aujourd\'hui',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha:0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section Genre avec design moderne
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest.withValues(alpha:0.3)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha:0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: RadioGroup(
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => gender = 'male'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: gender == 'male'
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio(
                                      value: 'male',
                                      activeColor: Colors.white,
                                    ),
                                    Text(
                                      'Masculin',
                                      style: TextStyle(
                                        color: gender == 'male'
                                            ? Colors.white
                                            : colorScheme.onSurface,
                                        fontWeight: gender == 'male'
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => gender = 'female'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: gender == 'female'
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio(
                                      value: 'female',
                                      activeColor: Colors.white,
                                    ),
                                    Text(
                                      'Féminin',
                                      style: TextStyle(
                                        color: gender == 'female'
                                            ? Colors.white
                                            : colorScheme.onSurface,
                                        fontWeight: gender == 'female'
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Informations personnelles
                  _buildSectionTitle('Informations personnelles', context),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: nameController,
                    hintText: "Nom",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: firstNameController,
                    hintText: "Prénom(s)",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Date de naissance",
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      filled: true,
                      fillColor: isDark
                          ? colorScheme.surfaceContainerHighest.withValues(alpha:0.3)
                          : colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha:0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                        firstDate: DateTime.now().subtract(const Duration(days: 36500)),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: colorScheme,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        setState(() {
                          birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: birthCityController,
                    hintText: "Lieu de naissance",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),

                  const SizedBox(height: 24),

                  // Section Contact
                  _buildSectionTitle('Coordonnées', context),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),

                  ModelFormInputSelect(
                    onChange: (value) {
                      setState(() {
                        countryController.text = value;
                      });
                    },
                    item: countryIso,
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: phoneController,
                    hintText: 'Téléphone',
                    obscureText: false,
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: addressController,
                    hintText: 'Adresse',
                    obscureText: false,
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                  ),

                  const SizedBox(height: 24),

                  // Section Sécurité
                  _buildSectionTitle('Sécurité', context),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: passwordController,
                    hintText: 'Mot de passe',
                    obscureText: !passIsVisible,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passIsVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          passIsVisible = !passIsVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  MyTextField(
                    controller: repeatPasswordController,
                    hintText: 'Confirmer le mot de passe',
                    obscureText: !passIsVisible,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passIsVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          passIsVisible = !passIsVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton S'inscrire avec effet moderne
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha:0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: MyButton(
                      onTap: () async {
                        showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black38,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const LoadingIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Création de votre compte...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        try {
                          Map<String, dynamic>? response = await register();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          if (response != null) {
                            if (context.mounted) {
                              Fluttertoast.showToast(
                                msg: "Compte créé avec succès !",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: colorScheme.primary,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                    (route) => false,
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      heightBtn: 56,
                      buttonText: "Créer mon compte",
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lien de connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Déjà inscrit ?",
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha:0.7),
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Termes et conditions
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigation vers les conditions
                      },
                      child: Text(
                        "Conditions d'utilisation",
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha:0.6),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les titres de section
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode de connexion de l'utilisateur
  Future register() async {
    Map<String, dynamic>? response = await MasterCrudModel.post(
      '/auth/register',
      data: {
        'name': nameController.text,
        'first_name': firstNameController.text,
        'birthdate': birthdateController.text,
        'birth_city': birthCityController.text,
        'address': addressController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'password_confirmation': repeatPasswordController.text,
        'gender': gender,
      },
    );

    if (response != null) {
      return response;
    } else {
      return null;
    }
  }
}