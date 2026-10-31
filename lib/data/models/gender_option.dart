/// Master-data option: preserves the lookup's string value/label structure.
class GenderOption {
  const GenderOption({required this.value, required this.label});
  final String value;
  final String label;

  factory GenderOption.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid gender option');
    }
    final value = json['value'];
    final label = json['label'];
    final id = value is String
        ? int.tryParse(value)
        : value is int
            ? value
            : null;
    if (id == null || id <= 0 || label is! String || label.trim().isEmpty) {
      throw const FormatException('Invalid gender option');
    }
    return GenderOption(value: '$id', label: label.trim());
  }

  Map<String, String> toJson() => {'value': value, 'label': label};
}
