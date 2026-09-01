extension StringExtensions on String {
  bool get isEmail {
    final pattern = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return pattern.hasMatch(this);
  }

  bool get isPhone {
    final pattern = RegExp(r'^\+?[0-9]{7,15}$');
    return pattern.hasMatch(this);
  }

  bool get isUrl {
    final pattern = RegExp(r'^(http|https)://');
    return pattern.hasMatch(this);
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
