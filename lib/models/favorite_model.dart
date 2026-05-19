// class FavoriteModel {
//   FavoriteModel({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.rating,
//     required this.genres,
//     required this.summary,
//   });

//   final int id;
//   final String name;
//   final String imageUrl;
//   final double rating;
//   final List<String> genres;
//   final String summary;

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'imageUrl': imageUrl,
//       'rating': rating,
//       'genres': genres,
//       'summary': summary,
//     };
//   }

//   factory FavoriteModel.fromMap(Map<String, dynamic> map) {
//     return FavoriteModel(
//       id: map['id'] as int,
//       name: map['name'] as String,
//       imageUrl: map['imageUrl'] as String? ?? '',
//       rating: (map['rating'] as num?)?.toDouble() ?? 0,
//       genres: List<String>.from(map['genres'] as List? ?? const []),
//       summary: map['summary'] as String? ?? '',
//     );
//   }
// }
