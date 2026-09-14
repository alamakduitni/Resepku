class StringFormatter {
  StringFormatter._();

  static String cookingTime(int minutes) {
    return '$minutes menit';
  }

  static String rating(double value) {
    return value.toStringAsFixed(1);
  }

  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String initials(String fullName) {
    final words =
        fullName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
