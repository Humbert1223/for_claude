import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  UpdateEmailPageState createState() => UpdateEmailPageState();
}

class UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final authController = Get.find<AuthController>();
  bool _isLoading = false;
  bool _isEdit = false;
  bool _isFetching = true;
  Map<String, dynamic>? user;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    authController.fromServer().then((currentUser) {
      setState(() {
        user = currentUser;
        _isFetching = false;
      });
      _emailController.text = user?['email'] ?? '';
    });
    super.initState();
  }

  Future<void> _updateEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic>? response = await MasterCrudModel.patch(
        '/auth/users/${user?['id']}',
        {'email': _emailController.text},
      );
      if (response != null) {
        await authController.refreshUser();
        setState(() {
          user = response;
          _isEdit = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modifier votre email",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(100)),
                        child: Icon(
                          Icons.email_outlined,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Si vous modifier votre email, vous devez à nouveau le vérifier avant de recevoir des notifications",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text("Email"),
                    emailWidget()
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox(
                      height: 50,
                    ),
              _isEdit
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget emailWidget() {
    if (_isFetching) {
      return const LoadingIndicator();
    } else {
      if (_isEdit == false) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(
                user?['email'] ?? '(Vide)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _isEdit = true;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
            ),
            InkWell(
              onTap: () async {
                if (user?['email_verified_at'] == null) {
                  await MasterCrudModel.post(
                    '/auth/send-email-verification-code',
                    data: {"user_id": user?['id']},
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text(
                          'Valider votre email',
                          style: TextStyle(fontSize: 18),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                const Text(
                                    'Un code de vérification à 6 chiffres vous a été envoyé par mail.'),
                                TextFormField(
                                  controller: _codeController,
                                  decoration: const InputDecoration(
                                    hintText: "Entre le code à 6 chiffres",
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_codeController.text.length == 6) {
                                        Map<String, dynamic>? response =
                                            await MasterCrudModel.post(
                                          '/auth/verify-email',
                                          data: {
                                            'code': _codeController.text,
                                            "user_id": user?['id']
                                          },
                                        );
                                        if (response != null) {
                                          setState(() {
                                            user = response;
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Enregistrer',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    barrierDismissible: false,
                  );
                }
              },
              child: TagWidget(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        user?['email_verified_at'] == null
                            ? Icons.warning_amber
                            : Icons.check_box_outlined,
                        color: Colors.white),
                    Text(
                      user?['email_verified_at'] != null
                          ? 'Vérifié'
                          : 'Non verifié, cliquez pour valider',
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
                color: user?['email_verified_at'] != null
                    ? Colors.green
                    : Colors.amber,
              ),
            )
          ],
        );
      } else {
        return TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: "Entre le nouveau email",
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nouveau email';
            }
            return null;
          },
        );
      }
    }
  }
}
