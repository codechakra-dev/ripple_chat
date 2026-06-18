class EmailValidation {
  static bool isValidEmail(String text) {
    // This is a standard rule template for matching emails
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(text);
  }
}