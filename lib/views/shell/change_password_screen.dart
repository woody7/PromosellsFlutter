import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/services/auth_api.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of Changepassword.jsx.
///
/// Two fixes over the React version, both purely client-side:
///  - It posts to a hardcoded `https://localhost:7151/...` instead of the
///    configured API base URL — this uses ApiConfig.baseUrl instead.
///  - Its success handler calls `onChangePasswordSuccess()`, a prop App.js
///    never actually passes to this route, so submitting throws in the
///    console and the screen never confirms anything happened either way.
///    This shows a real inline success/error message instead.
///  - "Confirm Password" is captured but never compared against "New
///    Password" anywhere (client or server) in the original — added that
///    check here since it's clearly what the field is for.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  String? _newPasswordError;
  String? _confirmPasswordError;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _newPasswordError = _newPasswordController.text.length < 6 ? 'Password should be at least 6 characters.' : null;
      _confirmPasswordError = _confirmPasswordController.text != _newPasswordController.text ? 'Passwords do not match.' : null;
      _successMessage = null;
      _errorMessage = null;
    });
    if (_newPasswordError != null || _confirmPasswordError != null) return;

    setState(() => _isSubmitting = true);
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      await AuthApi.changePassword(
        email: email,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      setState(() {
        _successMessage = 'Password changed successfully.';
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } on AuthApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: MySpacing.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: MyCard(
            paddingAll: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText.titleMedium('Change Password', textAlign: TextAlign.center),
                MySpacing.height(20),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
                ),
                MySpacing.height(12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'New Password', border: const OutlineInputBorder(), errorText: _newPasswordError),
                ),
                MySpacing.height(12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      InputDecoration(labelText: 'Confirm Password', border: const OutlineInputBorder(), errorText: _confirmPasswordError),
                ),
                MySpacing.height(16),
                if (_successMessage != null) ...[
                  MyText.bodySmall(_successMessage!, color: Colors.green),
                  MySpacing.height(8),
                ],
                if (_errorMessage != null) ...[
                  MyText.bodySmall(_errorMessage!, color: Theme.of(context).colorScheme.error),
                  MySpacing.height(8),
                ],
                MyButton.block(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : MyText.titleSmall('Change Password', color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
