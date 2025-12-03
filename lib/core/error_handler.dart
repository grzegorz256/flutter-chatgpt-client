import 'package:flutter/material.dart';

/// Error handling utilities
class ErrorHandler {
  ErrorHandler._();

  /// Shows a user-friendly error message
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Shows a success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Converts exception to user-friendly message
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Błąd połączenia. Sprawdź połączenie internetowe.';
    }
    if (errorString.contains('timeout')) {
      return 'Przekroczono limit czasu. Spróbuj ponownie.';
    }
    if (errorString.contains('api key') || errorString.contains('unauthorized')) {
      return 'Nieprawidłowy klucz API. Sprawdź konfigurację.';
    }
    if (errorString.contains('rate limit')) {
      return 'Przekroczono limit zapytań. Poczekaj chwilę.';
    }
    if (errorString.contains('token')) {
      return 'Przekroczono limit tokenów. Skróć wiadomość.';
    }

    return 'Wystąpił błąd: ${error.toString()}';
  }
}

