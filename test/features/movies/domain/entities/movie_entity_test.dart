import 'package:flutter_test/flutter_test.dart';
import 'package:filmflow/features/movies/domain/entities/movie_entity.dart';

void main() {
  group('MovieEntity', () {
    const testMovie = MovieEntity(
      id: 123,
      title: 'Test Movie',
      overview: 'This is a test movie overview',
      posterPath: '/test-poster.jpg',
      backdropPath: '/test-backdrop.jpg',
      releaseDate: '2023-06-15',
      voteAverage: 7.5,
      voteCount: 1500,
      genreIds: [28, 12, 16],
      adult: false,
      originalLanguage: 'en',
      originalTitle: 'Test Movie Original',
      popularity: 125.5,
      video: false,
    );

    test('creates instance with all required properties', () {
      const movie = MovieEntity(
        id: 456,
        title: 'Another Movie',
        overview: 'Another overview',
        voteAverage: 8.0,
        voteCount: 2000,
        genreIds: [18, 27],
        adult: true,
        originalLanguage: 'ja',
        originalTitle: 'Another Original Title',
        popularity: 99.9,
        video: true,
      );

      expect(movie.id, 456);
      expect(movie.title, 'Another Movie');
      expect(movie.overview, 'Another overview');
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.voteAverage, 8.0);
      expect(movie.voteCount, 2000);
      expect(movie.genreIds, [18, 27]);
      expect(movie.adult, true);
      expect(movie.originalLanguage, 'ja');
      expect(movie.originalTitle, 'Another Original Title');
      expect(movie.popularity, 99.9);
      expect(movie.video, true);
    });

    group('getFullPosterUrl', () {
      test('returns full URL when posterPath is not null', () {
        const baseUrl = 'https://image.tmdb.org/t/p/w500';
        final fullUrl = testMovie.getFullPosterUrl(baseUrl);

        expect(fullUrl, equals('$baseUrl/test-poster.jpg'));
      });

      test('returns null when posterPath is null', () {
        const movieWithoutPoster = MovieEntity(
          id: 789,
          title: 'No Poster Movie',
          overview: 'Movie without poster',
          voteAverage: 6.0,
          voteCount: 100,
          genreIds: [35],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'No Poster Original',
          popularity: 50.0,
          video: false,
        );

        final fullUrl = movieWithoutPoster.getFullPosterUrl('https://base.url');
        expect(fullUrl, isNull);
      });
    });

    group('getFullBackdropUrl', () {
      test('returns full URL when backdropPath is not null', () {
        const baseUrl = 'https://image.tmdb.org/t/p/w1280';
        final fullUrl = testMovie.getFullBackdropUrl(baseUrl);

        expect(fullUrl, equals('$baseUrl/test-backdrop.jpg'));
      });

      test('returns null when backdropPath is null', () {
        const movieWithoutBackdrop = MovieEntity(
          id: 789,
          title: 'No Backdrop Movie',
          overview: 'Movie without backdrop',
          voteAverage: 6.0,
          voteCount: 100,
          genreIds: [35],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'No Backdrop Original',
          popularity: 50.0,
          video: false,
        );

        final fullUrl = movieWithoutBackdrop.getFullBackdropUrl('https://base.url');
        expect(fullUrl, isNull);
      });
    });

    group('votePercentage', () {
      test('calculates correct percentage from vote average', () {
        const movie1 = MovieEntity(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          voteAverage: 7.5,
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original 1',
          popularity: 50.0,
          video: false,
        );

        expect(movie1.votePercentage, equals(75.0));

        const movie2 = MovieEntity(
          id: 2,
          title: 'Movie 2',
          overview: 'Overview 2',
          voteAverage: 10.0,
          voteCount: 200,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original 2',
          popularity: 50.0,
          video: false,
        );

        expect(movie2.votePercentage, equals(100.0));
      });

      test('clamps percentage to valid range', () {
        const movieWithHighVote = MovieEntity(
          id: 3,
          title: 'High Vote Movie',
          overview: 'Overview',
          voteAverage: 15.0, // Invalid high value
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original',
          popularity: 50.0,
          video: false,
        );

        expect(movieWithHighVote.votePercentage, equals(100.0));

        const movieWithNegativeVote = MovieEntity(
          id: 4,
          title: 'Negative Vote Movie',
          overview: 'Overview',
          voteAverage: -1.0, // Invalid negative value
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original',
          popularity: 50.0,
          video: false,
        );

        expect(movieWithNegativeVote.votePercentage, equals(0.0));
      });
    });

    group('releaseYear', () {
      test('returns correct year from valid release date', () {
        expect(testMovie.releaseYear, equals(2023));

        const movieWith2020 = MovieEntity(
          id: 5,
          title: '2020 Movie',
          overview: 'Overview',
          releaseDate: '2020-12-31',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original',
          popularity: 50.0,
          video: false,
        );

        expect(movieWith2020.releaseYear, equals(2020));
      });

      test('returns null when release date is null', () {
        const movieWithoutDate = MovieEntity(
          id: 6,
          title: 'No Date Movie',
          overview: 'Overview',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original',
          popularity: 50.0,
          video: false,
        );

        expect(movieWithoutDate.releaseYear, isNull);
      });

      test('returns null when release date is invalid', () {
        const movieWithInvalidDate = MovieEntity(
          id: 7,
          title: 'Invalid Date Movie',
          overview: 'Overview',
          releaseDate: 'invalid-date-format',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original',
          popularity: 50.0,
          video: false,
        );

        expect(movieWithInvalidDate.releaseYear, isNull);
      });
    });

    group('equality and hashCode', () {
      test('two movies with same id are equal', () {
        const movie1 = MovieEntity(
          id: 100,
          title: 'Movie A',
          overview: 'Overview A',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [28],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original A',
          popularity: 50.0,
          video: false,
        );

        const movie2 = MovieEntity(
          id: 100,
          title: 'Movie B', // Different title
          overview: 'Overview B', // Different overview
          voteAverage: 8.0, // Different rating
          voteCount: 200,
          genreIds: [16],
          adult: true,
          originalLanguage: 'ja',
          originalTitle: 'Original B',
          popularity: 75.0,
          video: true,
        );

        expect(movie1, equals(movie2));
        expect(movie1.hashCode, equals(movie2.hashCode));
      });

      test('two movies with different ids are not equal', () {
        const movie1 = MovieEntity(
          id: 100,
          title: 'Same Movie',
          overview: 'Same Overview',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [28],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Same Original',
          popularity: 50.0,
          video: false,
        );

        const movie2 = MovieEntity(
          id: 101, // Different id
          title: 'Same Movie',
          overview: 'Same Overview',
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [28],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Same Original',
          popularity: 50.0,
          video: false,
        );

        expect(movie1, isNot(equals(movie2)));
        expect(movie1.hashCode, isNot(equals(movie2.hashCode)));
      });
    });

    test('toString includes id and title', () {
      final toString = testMovie.toString();

      expect(toString, contains('123'));
      expect(toString, contains('Test Movie'));
      expect(toString, contains('MovieEntity'));
    });
  });
}
