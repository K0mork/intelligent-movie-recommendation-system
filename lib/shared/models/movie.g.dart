// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  overview: json['overview'] as String,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  releaseDate: json['release_date'] as String?,
  voteAverage: (json['vote_average'] as num).toDouble(),
  voteCount: (json['vote_count'] as num).toInt(),
  genreIds:
      (json['genre_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  adult: json['adult'] as bool,
  originalLanguage: json['original_language'] as String,
  originalTitle: json['original_title'] as String,
  popularity: (json['popularity'] as num).toDouble(),
  video: json['video'] as bool,
);

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
  'release_date': instance.releaseDate,
  'vote_average': instance.voteAverage,
  'vote_count': instance.voteCount,
  'genre_ids': instance.genreIds,
  'adult': instance.adult,
  'original_language': instance.originalLanguage,
  'original_title': instance.originalTitle,
  'popularity': instance.popularity,
  'video': instance.video,
};
