class ActorModel {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  ActorModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    return ActorModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  String get profileUrl {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }
}
