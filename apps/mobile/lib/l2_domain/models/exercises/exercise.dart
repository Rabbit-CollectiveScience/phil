abstract class Exercise {
  final String id;
  final String name;
  final String description;
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.isCustom,
  });

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ isCustom.hashCode;
}
