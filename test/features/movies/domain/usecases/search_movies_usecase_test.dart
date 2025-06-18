import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:filmflow/features/movies/domain/repositories/movie_repository.dart';
import 'package:filmflow/features/movies/domain/usecases/search_movies_usecase.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

@GenerateMocks([MovieRepository])
import 'search_movies_usecase_test.mocks.dart';

void main() {
  late SearchMoviesUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = SearchMoviesUseCase(mockRepository);
  });

  group('SearchMoviesUseCase', () {
    final testMovies = [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        overview: 'Test overview 1',
        posterPath: '/poster1.jpg',
        backdropPath: '/backdrop1.jpg',
        releaseDate: '2023-01-01',
        voteAverage: 7.5,
        voteCount: 1000,
        genreIds: [28, 12],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Test Movie 1 Original',
        popularity: 100.0,
        video: false,
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        overview: 'Test overview 2',
        posterPath: '/poster2.jpg',
        backdropPath: '/backdrop2.jpg',
        releaseDate: '2023-02-01',
        voteAverage: 8.0,
        voteCount: 1500,
        genreIds: [16, 35],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Test Movie 2 Original',
        popularity: 150.0,
        video: false,
      ),
    ];

    test('calls repository with correct parameters for valid query', () async {
      const query = 'test movie';
      const page = 1;

      when(mockRepository.searchMovies(query, page: page))
          .thenAnswer((_) async => testMovies);

      final result = await useCase.call(query, page: page);

      expect(result, equals(testMovies));
      verify(mockRepository.searchMovies(query, page: page)).called(1);
    });

    test('calls repository with default page when page is not specified', () async {
      const query = 'test movie';

      when(mockRepository.searchMovies(query, page: 1))
          .thenAnswer((_) async => testMovies);

      final result = await useCase.call(query);

      expect(result, equals(testMovies));
      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });

    test('calls repository with custom page number', () async {
      const query = 'test movie';
      const page = 3;

      when(mockRepository.searchMovies(query, page: page))
          .thenAnswer((_) async => testMovies);

      final result = await useCase.call(query, page: page);

      expect(result, equals(testMovies));
      verify(mockRepository.searchMovies(query, page: page)).called(1);
    });

    test('returns empty list when repository returns empty list', () async {
      const query = 'no results';

      when(mockRepository.searchMovies(query, page: 1))
          .thenAnswer((_) async => []);

      final result = await useCase.call(query);

      expect(result, isEmpty);
      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });

    test('throws ArgumentError when query is empty', () async {
      expect(
        () => useCase.call(''),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(mockRepository.searchMovies(any, page: anyNamed('page')));
    });

    test('throws ArgumentError when query is only whitespace', () async {
      expect(
        () => useCase.call('   '),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(mockRepository.searchMovies(any, page: anyNamed('page')));
    });

    test('throws ArgumentError with correct message for empty query', () async {
      try {
        await useCase.call('');
        fail('Expected ArgumentError to be thrown');
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect(e.toString(), contains('Search query cannot be empty'));
      }
    });

    test('handles repository exceptions', () async {
      const query = 'test movie';
      final exception = Exception('Network error');

      when(mockRepository.searchMovies(query, page: 1))
          .thenThrow(exception);

      expect(
        () => useCase.call(query),
        throwsA(equals(exception)),
      );

      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });

    test('validates trimmed query but passes original to repository', () async {
      const query = '  test movie  ';

      when(mockRepository.searchMovies(query, page: 1))
          .thenAnswer((_) async => testMovies);

      await useCase.call(query);

      // Verify that the original query (with spaces) was passed to repository
      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });

    test('handles special characters in query', () async {
      const query = 'movie with special chars: @#\$%';

      when(mockRepository.searchMovies(query, page: 1))
          .thenAnswer((_) async => testMovies);

      final result = await useCase.call(query);

      expect(result, equals(testMovies));
      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });

    test('handles unicode characters in query', () async {
      const query = '映画のタイトル';

      when(mockRepository.searchMovies(query, page: 1))
          .thenAnswer((_) async => testMovies);

      final result = await useCase.call(query);

      expect(result, equals(testMovies));
      verify(mockRepository.searchMovies(query, page: 1)).called(1);
    });
  });
}