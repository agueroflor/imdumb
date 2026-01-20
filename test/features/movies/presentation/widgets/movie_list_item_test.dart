import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imdumb/features/movies/presentation/widgets/movie_list_item.dart';

void main() {
  group('MovieListItem', () {
    testWidgets('renders movie title and poster', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('displays rating stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 7.5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('7.5/10 IMDb'), findsOneWidget);
    });

    testWidgets('displays genre chips when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.0,
              genres: const ['Acción', 'Aventura', 'Drama'],
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ACCIÓN'), findsOneWidget);
      expect(find.text('AVENTURA'), findsOneWidget);
      expect(find.text('DRAMA'), findsOneWidget);
    });

    testWidgets('displays duration when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.0,
              duration: '120 min',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('120 min'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.0,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Movie'));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('displays custom trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.0,
              trailing: const Icon(Icons.delete),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('displays custom subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movieId: 1,
              title: 'Test Movie',
              posterUrl: 'https://test.com/poster.jpg',
              voteAverage: 8.0,
              subtitle: const Text('Custom subtitle'),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Custom subtitle'), findsOneWidget);
    });
  });
}
