import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of App.js's inactivity/session-timeout logic: after
/// [_inactivityTimeout] with no activity, shows a non-dismissible warning;
/// if it's not acknowledged within [_autoLogoutGrace], logs out.
///
/// React tracks mousedown/keydown/scroll/touchstart; the Flutter equivalent
/// is pointer-down/scroll (via [Listener]) plus a hardware-keyboard handler
/// for web/desktop. Only wraps the authenticated shell — mirrors App.js's
/// `if (isLogin) return;` guard by only ever being mounted once logged in
/// (see main.dart's AuthGate).
class SessionTimeoutWrapper extends StatefulWidget {
  const SessionTimeoutWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper> {
  static const _inactivityTimeout = Duration(minutes: 10);
  static const _autoLogoutGrace = Duration(seconds: 60);

  Timer? _inactivityTimer;
  Timer? _autoLogoutTimer;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    _inactivityTimer?.cancel();
    _autoLogoutTimer?.cancel();
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    _resetInactivityTimer();
    return false; // Don't consume — this is only for activity tracking.
  }

  void _onPointerActivity([PointerEvent? _]) => _resetInactivityTimer();

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, _showTimeoutDialog);
  }

  void _showTimeoutDialog() {
    if (_dialogOpen || !mounted) return;
    _dialogOpen = true;
    _autoLogoutTimer = Timer(_autoLogoutGrace, _autoLogout);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: MyText.titleMedium('Session Timeout'),
        content: MyText.bodyMedium("You've been inactive for a while. Continue your session?"),
        actions: [
          TextButton(onPressed: () => _handleLogoutTapped(dialogContext), child: const Text('Logout')),
          MyButton(
            onPressed: () => _handleContinueTapped(dialogContext),
            child: MyText.bodyMedium('Continue Session', color: Colors.white),
          ),
        ],
      ),
    ).then((_) => _dialogOpen = false);
  }

  void _handleContinueTapped(BuildContext dialogContext) {
    _autoLogoutTimer?.cancel();
    Navigator.of(dialogContext).pop();
    _resetInactivityTimer();
  }

  void _handleLogoutTapped(BuildContext dialogContext) {
    _autoLogoutTimer?.cancel();
    Navigator.of(dialogContext).pop();
    Get.find<AuthController>().logout();
  }

  void _autoLogout() {
    if (_dialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    Get.find<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerActivity,
      onPointerSignal: _onPointerActivity,
      child: widget.child,
    );
  }
}
