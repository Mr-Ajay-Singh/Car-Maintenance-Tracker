import 'package:flutter/material.dart';

class ToastMessage {
  static void show(BuildContext context, String message,
      {bool isError = false}) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor:Theme.of(context).colorScheme.onSecondary,
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, isError: true);
  }
}
