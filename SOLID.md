# Principios SOLID en IMDUMB

Este documento identifica cómo se aplican los principios SOLID en el código del proyecto.

---

## S - Single Responsibility Principle (Responsabilidad Única)

**Definición:** Una clase debe tener una única razón para cambiar. Cada clase se enfoca en una responsabilidad específica.

### Ejemplo 1: `MovieRepository`
**Ubicación:** `lib/features/movies/data/repositories/movie_repository.dart`

**Responsabilidad única:** Gestionar acceso a datos de películas desde TMDB API.

```dart
class MovieRepository {
  // Solo maneja: HTTP calls, retry logic, conectividad, conversión de errores
  Future<List<MovieModel>> fetchMovies(String category, {int page = 1})
  Future<MovieDetailModel> fetchMovieDetail(int movieId)
  Future<List<MovieModel>> searchMovies(String query, {int page = 1})
}
```

**Por qué lo cumple:** No maneja estado de UI, no procesa lógica de presentación, no gestiona almacenamiento local. Solo obtiene y transforma datos de la API.

---

### Ejemplo 2: `HiveService`
**Ubicación:** `lib/core/local/hive_service.dart`

**Responsabilidad única:** Gestionar persistencia de favoritos en Hive.

```dart
class HiveService {
  // Solo maneja: CRUD de favoritos en Hive
  Future<void> saveFavoriteMovie(...)
  Future<void> removeFavoriteMovie(int id)
  List<HiveMovieModel> getAllFavorites()
}
```

**Por qué lo cumple:** No mezcla lógica de analytics, remote config, ni SharedPreferences. Solo favoritos con Hive.

---

### Ejemplo 3: `HomeBloc`
**Ubicación:** `lib/features/movies/presentation/blocs/home_bloc.dart`

**Responsabilidad única:** Gestionar estado de la pantalla Home.

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // Solo maneja eventos y estados de Home
  on<LoadHomeMovies>(_onLoadHomeMovies);
}
```

**Por qué lo cumple:** No gestiona búsqueda, favoritos, ni detalle. Cada BLoC maneja su propia pantalla.

---

## O - Open/Closed Principle (Abierto/Cerrado)

**Definición:** Las clases deben estar abiertas a extensión pero cerradas a modificación. Se pueden agregar nuevas funcionalidades sin modificar código existente.

### Ejemplo 1: `AnalyticsService` interface
**Ubicación:** `lib/core/analytics/analytics_service.dart`

```dart
abstract class AnalyticsService {
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters});
  Future<void> logScreenView({required String screenName, String? screenClass});
}
```

**Implementación actual:** `FirebaseAnalyticsService`

**Por qué lo cumple:** Se pueden agregar nuevas implementaciones (`MixpanelAnalyticsService`, `AmplitudeAnalyticsService`) sin modificar código existente. Solo cambiar registro en `service_locator.dart`:

```dart
// Cambiar de Firebase a Mixpanel sin tocar consumidores
serviceLocator.registerLazySingleton<AnalyticsService>(
  () => MixpanelAnalyticsService(),
);
```

---

### Ejemplo 2: Jerarquía `AppException`
**Ubicación:** `lib/core/error/app_exception.dart`

```dart
abstract class AppException implements Exception { }
class NoInternetException extends AppException { }
class TimeoutException extends AppException { }
class ServerException extends AppException { }
```

**Por qué lo cumple:** Nuevas excepciones se agregan heredando de `AppException` sin modificar la clase base ni el handler. Para agregar `RateLimitException`:

```dart
class RateLimitException extends AppException {
  const RateLimitException() : super('Rate limit', 'Demasiadas peticiones...');
}
```

---

### Ejemplo 3: `RemoteConfigService` interface
**Ubicación:** `lib/core/remote_config/remote_config_service.dart`

**Por qué lo cumple:** Actualmente usa Firebase, pero se puede extender a AWS AppConfig o LaunchDarkly sin modificar consumidores.

---

## L - Liskov Substitution Principle (Sustitución de Liskov)

**Definición:** Las subclases deben poder reemplazar a sus clases base sin romper la funcionalidad del programa.

### Ejemplo 1: `FirebaseAnalyticsService` implementa `AnalyticsService`
**Ubicación:**
- Interface: `lib/core/analytics/analytics_service.dart`
- Implementación: `lib/core/analytics/firebase_analytics_service.dart`

```dart
// Service Locator
serviceLocator.registerLazySingleton<AnalyticsService>(
  () => FirebaseAnalyticsService(),
);

// Consumo
final _analyticsService = serviceLocator<AnalyticsService>();
_analyticsService.logEvent(name: 'movie_viewed', parameters: {...});
```

**Por qué lo cumple:** Cualquier código que use `AnalyticsService` funciona correctamente con `FirebaseAnalyticsService`. En tests se puede sustituir por `MockAnalyticsService` sin romper contratos.

---

### Ejemplo 2: `MovieDetailModel` extiende comportamiento
**Ubicación:** `lib/features/movies/data/models/movie_detail_model.dart`

```dart
class MovieDetailModel {
  final int id;
  final String title;
  // Campos adicionales: overview, images, cast
}
```

**Por qué lo cumple:** Aunque no hereda de `MovieModel` directamente, el patrón se mantiene. Componentes que aceptan datos básicos de película funcionan con `MovieDetailModel`.

---

### Ejemplo 3: BLoC states
**Ubicación:** `lib/features/movies/presentation/blocs/`

```dart
abstract class HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {}
class HomeError extends HomeState {}
```

**Por qué lo cumple:** `BlocBuilder<HomeBloc, HomeState>` maneja cualquier estado derivado sin conocer implementación específica.

---

## I - Interface Segregation Principle (Segregación de Interfaces)

**Definición:** Las interfaces no deben forzar a implementar métodos innecesarios. Interfaces específicas son mejores que una general.

### Ejemplo 1: `AnalyticsService` vs `RemoteConfigService`
**Ubicación:**
- `lib/core/analytics/analytics_service.dart`
- `lib/core/remote_config/remote_config_service.dart`

```dart
// Interfaces separadas aunque ambas usen Firebase
abstract class AnalyticsService {
  Future<void> logEvent(...);
  Future<void> logScreenView(...);
}

abstract class RemoteConfigService {
  Future<void> initialize();
  bool getBool(String key);
  String getString(String key);
}
```

**Por qué lo cumple:** No existe una interfaz gigante `FirebaseService` con métodos de analytics + remote config + crashlytics. Cada servicio implementa solo lo que necesita.

**Anti-patrón evitado:**
```dart
// ✗ Incorrecto
abstract class FirebaseService {
  Future<void> logEvent(...);
  Future<void> getBool(...);
  Future<void> reportCrash(...); // No todos necesitan esto
}
```

---

### Ejemplo 2: `SharedPrefsService` vs `HiveService`
**Ubicación:**
- `lib/core/local/shared_prefs_service.dart`
- `lib/core/local/hive_service.dart`

**Por qué lo cumple:** Servicios separados para diferentes tipos de storage. `SharedPrefsService` maneja key-value simple, `HiveService` maneja objetos complejos. Nadie está forzado a implementar ambos patrones.

---

### Ejemplo 3: BLoC events segregados
**Ubicación:** `lib/features/movies/presentation/blocs/`

```dart
// HomeBloc solo eventos de home
abstract class HomeEvent {}
class LoadHomeMovies extends HomeEvent {}

// SearchBloc solo eventos de búsqueda
abstract class SearchEvent {}
class SearchQueryChanged extends SearchEvent {}
class SearchCleared extends SearchEvent {}
```

**Por qué lo cumple:** No hay interfaz global `AppEvents` que todos deban implementar. Cada BLoC define sus eventos específicos.

---

## D - Dependency Inversion Principle (Inversión de Dependencias)

**Definición:** Depender de abstracciones, no de implementaciones concretas. Las clases de alto nivel no deben depender de clases de bajo nivel.

### Ejemplo 1: Service Locator con interfaces
**Ubicación:** `lib/core/di/service_locator.dart`

```dart
// ✓ Correcto: Registro abstracción → implementación
serviceLocator.registerLazySingleton<AnalyticsService>(
  () => FirebaseAnalyticsService(),
);

// Consumo: Depende de abstracción
final _analyticsService = serviceLocator<AnalyticsService>();
```

**Por qué lo cumple:** El código depende de `AnalyticsService` (abstracción), no de `FirebaseAnalyticsService` (concreción). Facilita testing y cambio de implementación.

---

### Ejemplo 2: BLoCs reciben Repository por constructor
**Ubicación:** `lib/features/movies/presentation/blocs/home_bloc.dart`

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MovieRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial());
}
```

**Por qué lo cumple:** No instancia `MovieRepository` internamente. Recibe dependencia inyectada, permitiendo mocks en tests:

```dart
// En tests
final mockRepository = MockMovieRepository();
final bloc = HomeBloc(repository: mockRepository);
```

**Anti-patrón evitado:**
```dart
// ✗ Incorrecto
class HomeBloc {
  final repository = MovieRepository(dio: Dio(), ...); // Acoplamiento fuerte
}
```

---

### Ejemplo 3: `AppInitializer` recibe dependencias
**Ubicación:** `lib/core/config/app_initializer.dart`

```dart
class AppInitializer {
  final FirebaseRemoteConfigService remoteConfig;
  final HiveService hiveService;

  AppInitializer({
    required this.remoteConfig,
    required this.hiveService,
  });
}
```

**Por qué lo cumple:** No instancia servicios con `new`. Recibe dependencias configuradas externamente. Aunque usa clases concretas (no interfaces), aplica inyección de dependencias.

---

### Ejemplo 4: `MovieRepository` inyecta `Dio`
**Ubicación:** `lib/features/movies/data/repositories/movie_repository.dart`

```dart
class MovieRepository {
  final Dio dio;
  final Connectivity _connectivity;

  MovieRepository({
    required this.dio,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();
}
```

**Por qué lo cumple:** No crea `Dio()` internamente. Permite inyectar `MockDio` en tests. El service locator configura la instancia real.

---

## Limitaciones y Áreas de Mejora

### 1. Repository como clase concreta
`MovieRepository` es una clase concreta, no una interfaz. Para cumplir DIP estrictamente:

```dart
// Pendiente
abstract class IMovieRepository {
  Future<List<MovieModel>> fetchMovies(String category, {int page});
}

class MovieRepository implements IMovieRepository { }
```

**Justificación actual:** Para proyectos pequeños, DI con clases concretas es aceptable. En proyectos grandes se recomienda interfaces.

---

### 2. Algunos servicios inyectan concretos
`AppInitializer` recibe `FirebaseRemoteConfigService` y `HiveService` concretos en vez de interfaces.

**Justificación:** Son implementaciones únicas sin necesidad de múltiples providers. Pragmático para el tamaño actual del proyecto.

---

### 3. Models sin comportamiento (anémicos)
Los DTOs (`MovieModel`, `ActorModel`) son clases de datos sin lógica.

**Justificación:** Intencional en Clean Architecture. La capa de datos usa models anémicos para serialización. La lógica reside en repositories y BLoCs.

---

## Resumen

| Principio | Aplicación | Ubicación principal |
|-----------|-----------|---------------------|
| **SRP** | ✅ Completo | Todos los BLoCs, Repositories, Services |
| **OCP** | ✅ Completo | Interfaces: `AnalyticsService`, `RemoteConfigService`, jerarquía `AppException` |
| **LSP** | ✅ Completo | `FirebaseAnalyticsService`, BLoC states |
| **ISP** | ✅ Completo | Interfaces segregadas por responsabilidad |
| **DIP** | ⚠️  Parcial | Service Locator con interfaces. Algunos servicios usan concretos (aceptable) |

El proyecto aplica SOLID de forma pragmática, priorizando claridad y mantenibilidad sobre purismo arquitectónico.
