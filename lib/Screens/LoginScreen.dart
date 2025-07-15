import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _pwdVisibility = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.white,
              shadowColor: Colors.orange[200],
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Image.asset("content/images/chefUtensil.png", scale: 1.8),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: Column(
                          spacing: 10,
                          children: <Widget>[
                            const Text(
                              "Welcome back chef!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Log in to continue cooking",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // EMAIL
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: FormBuilderTextField(
                          name: "mail",
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: "Required",
                            ),
                            FormBuilderValidators.email(
                              errorText: "Invalid mail",
                            ),
                            //FormBuilderValidators.match(RegExp(r"^[a-zA-Z0-9.+]+@[a-zA-Z]+\.[a-zA-Z]+"), errorText: "Invalid mail")
                          ]),
                          decoration: InputDecoration(
                            labelText: "Email",
                            icon: const Icon(Icons.mail_outline_rounded),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      // PASSWORD
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: FormBuilderTextField(
                          name: "pwd",
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: "Required",
                            ),
                            FormBuilderValidators.password(),
                          ]),
                          decoration: InputDecoration(
                            labelText: "Password",
                            icon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pwdVisibility = !_pwdVisibility;
                                });
                              },
                              icon: (_pwdVisibility)
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            ),
                          ),
                          obscureText: !_pwdVisibility,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.saveAndValidate()) {
                              final formFields = _formKey.currentState!.value;

                              var app = {
                                "mail": formFields["mail"],
                                "pwd": formFields["pwd"],
                              };

                              print(app);
                            }
                          },
                          child: const Text("Log in!"),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: Row(
                          children: const <Widget>[
                            Expanded(child: Divider(thickness: 2.0)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("or", style: TextStyle(fontSize: 16)),
                            ),
                            Expanded(child: Divider(thickness: 2.0)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Text("Log in with Google"),
                        ),
                      ),

                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Are you a new user?",
                            style: TextStyle(fontSize: 14),
                          ),

                          TextButton(
                            onPressed: () {},
                            child: const Text("Sign-in"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
