class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!pattern.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    final pattern = RegExp(r'^\+?[0-9]{7,15}$');
    if (!pattern.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }
}
