import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/widgets/app_loading_overlay.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthController _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _auth.login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: MySpacing.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: MyCard(
                paddingAll: 32,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText.headlineSmall('Promosells', textAlign: TextAlign.center),
                      MySpacing.height(4),
                      MyText.bodyMedium(
                        'Sign in to continue',
                        muted: true,
                        textAlign: TextAlign.center,
                      ),
                      MySpacing.height(28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Email is required' : null,
                      ),
                      MySpacing.height(16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      MySpacing.height(24),
                      Obx(() {
                        final error = _auth.errorMessage.value;
                        if (error == null) return MySpacing.empty();
                        return Padding(
                          padding: MySpacing.bottom(16),
                          child: MyText.bodySmall(error, color: Theme.of(context).colorScheme.error),
                        );
                      }),
                      Obx(() => AppLoadingOverlay(
                            isLoading: _auth.isLoading.value,
                            replaceContent: false,
                            child: MyButton.block(
                              onPressed: _auth.isLoading.value ? null : _submit,
                              child: MyText.titleSmall('Sign In', color: Colors.white),
                            ),
                          )),
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
