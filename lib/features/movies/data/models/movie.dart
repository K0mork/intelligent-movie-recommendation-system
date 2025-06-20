import 'package:json_annotation/json_annotation.dart';
import 'package:filmflow/features/movies/domain/entities/movie_entity.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  final int id;
  final String title;
  final String overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'vote_count')
  final int voteCount;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;
  final bool adult;
  @JsonKey(name: 'original_language')
  final String originalLanguage;
  @JsonKey(name: 'original_title')
  final String originalTitle;
  final double popularity;
  final bool video;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.video,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);

  factory Movie.fromTMDBJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      voteAverage: double.tryParse(json['vote_average']?.toString() ?? '0.0') ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? <int>[],
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      popularity: double.tryParse(json['popularity']?.toString() ?? '0.0') ?? 0.0,
      video: json['video'] ?? false,
    );
  }

  factory Movie.fromOMDBJson(Map<String, dynamic> json) {
    return Movie(
      id: int.tryParse(json['imdbID']?.replaceAll('tt', '') ?? '0') ?? 0,
      title: json['Title'] ?? '',
      overview: json['Plot'] ?? '',
      posterPath: json['Poster'] != 'N/A' ? json['Poster'] : null,
      backdropPath: null,
      releaseDate: json['Released'],
      voteAverage: double.tryParse(json['imdbRating'] ?? '0') ?? 0.0,
      voteCount: int.tryParse(json['imdbVotes']?.replaceAll(',', '') ?? '0') ?? 0,
      genreIds: [],
      adult: json['Rated'] == 'R',
      originalLanguage: 'en',
      originalTitle: json['Title'] ?? '',
      popularity: 0.0,
      video: false,
    );
  }

  String get fullPosterUrl {
    if (posterPath == null) return '';
    
    if (posterPath!.startsWith('http')) {
      return posterPath!;
    }
    
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropUrl => backdropPath != null 
    ? 'https://image.tmdb.org/t/p/w780$backdropPath' 
    : '';

  /// MovieEntityへの変換メソッド
  MovieEntity toEntity() {
    return MovieEntity(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      genreIds: genreIds,
      adult: adult,
      originalLanguage: originalLanguage,
      originalTitle: originalTitle,
      popularity: popularity,
      video: video,
    );
  }
}