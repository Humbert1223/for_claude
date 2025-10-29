import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novacole/components/form_inputs/input_text.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  PasswordResetPageState createState() {
    return PasswordResetPageState();
  }
}

class PasswordResetPageState extends State<PasswordResetPage> {
  String token = '';
  String login = '';
  String password = '';
  String passwordConfirmation = '';
  bool isSaving = false;

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
              ModelFormInputText(
                onChange: (value) {
                  setState(() {
                    token = value;
                  });
                },
                item: {
                  'field': 'token',
                  'name': 'Code de réinitialisation',
                  'type': 'numeric',
                  'required': true,
                  'placeholder': 'Entrez le code de réinitialisation',
                  'icon': Icons.numbers,
                },
              ),
              SizedBox(height: 20),
              ModelFormInputText(
                onChange: (value) {
                  setState(() {
                    login = value;
                  });
                },
                item: {
                  'field': 'login',
                  'name':
                      'Adresse de recupération de mot de passe (email, téléphone)',
                  'type': 'text',
                  'required': true,
                  'placeholder': 'Entrez votre adresse email ou téléphone',
                  'icon': Icons.text_fields,
                },
              ),
              SizedBox(height: 20),
              ModelFormInputText(
                onChange: (value) {
                  setState(() {
                    password = value;
                  });
                },
                item: {
                  'field': 'password',
                  'name': 'Nouveau mot de passe',
                  'type': 'password',
                  'required': true,
                  'placeholder': 'Entrez le nouveau mot de passe',
                  'icon': Icons.lock,
                },
              ),
              SizedBox(height: 20),
              ModelFormInputText(
                onChange: (value) {
                  setState(() {
                    passwordConfirmation = value;
                  });
                },
                item: {
                  'field': 'password_confirmation',
                  'name': 'Confirmation du nouveau mot de passe',
                  'type': 'password',
                  'required': true,
                  'placeholder': 'Retapez le nouveau mot de passe',
                  'icon': Icons.lock,
                },
              ),
              SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          if (login.isEmpty || token.isEmpty || password.isEmpty || passwordConfirmation.isEmpty) {
                            Fluttertoast.showToast(
                              msg:  "Veuillez remplir tous les champs.",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            return;
                          }
                          setState(() {
                            isSaving = true;
                          });
                          try{
                            final response = await MasterCrudModel.post(
                              '/auth/reset-token',
                              data: {
                                'login': login,
                                'token': token,
                                'password': password,
                                'password_confirmation': passwordConfirmation,
                              },
                            );

                            if (response != null && response['message'] != null) {
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
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                      (route) => false,
                                );
                              }
                            }
                          }finally{
                            setState(() {
                              isSaving = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text('Réinitialiser le mot de passe'),
                      ),
                    ),
                    Visibility(
                      visible: isSaving,
                      child: Positioned(
                        child: LoadingIndicator(
                          type: LoadingIndicatorType.progressiveDots,
                        ),
                      ),
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
}
