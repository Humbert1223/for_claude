import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novacole/components/form_inputs/input_text.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/auth/account/password_reset_page.dart';

class SendPasswordResetPage extends StatefulWidget {
  const SendPasswordResetPage({super.key});

  @override
  SendPasswordResetPageState createState() {
    return SendPasswordResetPageState();
  }
}

class SendPasswordResetPageState extends State<SendPasswordResetPage> {
  String canal = 'email';
  String login = '';
  bool isSending = false;

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
      appBar: AppBar(title: const Text('Réinitialisation du mot de passe')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Center(
                child: Text(
                  'Réinitialisation du mot de passe',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              RadioGroup(
                onChanged: (String? value) {
                  setState(() {
                    canal = value ?? 'email';
                    login = '';
                  });
                },
                groupValue: canal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 16,
                        child: RadioListTile<String>(
                          title: const Text('E-mail'),
                          value: 'email',
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 16,
                        child: RadioListTile<String>(
                          title: const Text('Téléphone'),
                          value: 'tel',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Visibility(
                visible: canal == 'email',
                child: ModelFormInputText(
                  onChange: (value) {
                    setState(() {
                      login = value;
                    });
                  },
                  item: {
                    'field': 'email',
                    'name': 'Adresse e-mail',
                    'type': 'email',
                    'required': true,
                    'placeholder': 'Entrez votre adresse e-mail',
                    'icon': Icons.email,
                  },
                ),
              ),
              Visibility(
                visible: canal == 'tel',
                child: ModelFormInputText(
                  onChange: (value) {
                    setState(() {
                      login = value;
                    });
                  },
                  item: {
                    'field': 'tel',
                    'name': 'Entrez votre numéro de téléphone',
                    'type': 'phone',
                    'required': true,
                    'placeholder': 'Entrez votre numéro de téléphone',
                    'icon': Icons.phone,
                  },
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            if (login.isEmpty) {
                              Fluttertoast.showToast(
                                msg: canal == 'email'
                                    ? "Veuillez entrer l'adresse email"
                                    : "Veuillez entrer le numéro de téléphone",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }
                            try{
                              setState(() {
                                isSending = true;
                              });
                              final response = await MasterCrudModel.post(
                                '/auth/send-reset-token',
                                data: {'login': login, 'canal': canal},
                              );

                              if (response != null &&
                                  response['message'] != null) {
                                if (context.mounted) {
                                  Fluttertoast.showToast(
                                    msg: response['message'],
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    textColor: Colors.white,
                                  );
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
                                    return PasswordResetPage();
                                  }));
                                }
                              }
                            }finally{
                              setState(() {
                                isSending = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Envoyer le lien de réinitialisation'),
                  ),
                  Visibility(
                    visible: isSending,
                    child: Positioned(
                      child: LoadingIndicator(
                        type: LoadingIndicatorType.progressiveDots,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Visibility(
                visible: canal == 'email',
                replacement: Text(
                  'Vous recevrez un SMS avec un code pour réinitialiser votre mot de passe.',
                  textAlign: TextAlign.center,
                ),
                child: Text(
                  'Vous recevrez un e-mail avec un code pour réinitialiser votre mot de passe.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PasswordResetPage();
                      },
                    ),
                  );
                },
                child: Text("J'ai déjà un code de réinitialisation"),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
