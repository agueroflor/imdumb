# IMDUMB

Aplicación Flutter para explorar, buscar y gestionar películas usando TMDB API, con soporte para favoritos locales y configuración remota de features.

## Resumen del Proyecto

IMDUMB permite navegar catálogos de películas (populares, mejor valoradas, próximos estrenos), ver detalles completos con sinopsis, calificaciones, imágenes y elenco. Los usuarios pueden marcar favoritos (almacenados con Hive), recomendar películas y buscar títulos. Integra Firebase Remote Config para habilitar/deshabilitar búsqueda dinámicamente y Firebase Analytics para tracking de eventos.

**Features principales:**
- Exploración de películas por categorías (popular, top rated, upcoming)
- Detalle completo: sinopsis, rating, carousel de imágenes, lista de actores
- Búsqueda con debounce y parámetros configurables
- Favoritos persistentes localmente (Hive)
- Sistema de recomendaciones con validación de comentarios
- Paginación infinita
- Remote Config para feature flags
- Analytics tracking automático

## Arquitectura

IMDUMB implementa **Clean Architecture adaptada** con organización **Feature-First**. El código se divide en:

- **Data Layer**: Repositorios que manejan HTTP, errores, conectividad. Modelos (DTOs) mapean JSON ↔ Dart.
- **Presentation Layer**: BLoC para state management. Pages (screens) y widgets reutilizables.
- **Core**: Servicios compartidos (DI, Analytics, Remote Config, Storage, Error Handling).

Cada feature (`movies`, `splash`) es autocontenido con sus propias capas. Los BLoCs reciben eventos, llaman repositorios, emiten estados que la UI consume reactivamente.

```
┌─────────────────────────────────────────────────┐
│           PRESENTATION LAYER                    │
│  ┌──────────┐         ┌────────────────┐       │
│  │  Pages   │ ◄─────► │     BLoCs      │       │
│  │ Widgets  │ events  │  (State Mgmt)  │       │
│  └──────────┘ states  └────────────────┘       │
└─────────────────────────┬───────────────────────┘
                          │ calls
┌─────────────────────────▼───────────────────────┐
│              DATA LAYER                         │
│  ┌──────────────┐      ┌────────────────┐      │
│  │ Repository   │ ◄──► │    Models      │      │
│  │ (HTTP/Error) │      │    (DTOs)      │      │
│  └──────────────┘      └────────────────┘      │
└─────────────────────────┬───────────────────────┘
                          │ HTTP
              ┌───────────▼──────────┐
              │     TMDB API         │
              └──────────────────────┘

┌─────────────────────────────────────────────────┐
│               CORE SERVICES                     │
│  Analytics | Remote Config | Storage | DI       │
└─────────────────────────────────────────────────┘
```

**Justificación**: Escalabilidad (features autocontenidos), separación clara de responsabilidades (testing aislado por capa), BLoC garantiza estado predecible, DI facilita mocking.

## Tech Stack

| Paquete | Versión | Uso |
|---------|---------|-----|
| **Flutter** | 3.32.8 | Framework |
| **Dart SDK** | ^3.8.1 | Lenguaje |
| dio | ^5.9.0 | Cliente HTTP |
| flutter_bloc | ^9.1.1 | State management (BLoC) |
| equatable | ^2.0.8 | Comparación de objetos (BLoC states) |
| get_it | ^8.0.4 | Dependency Injection |
| hive | ^2.2.3 | Base de datos NoSQL local |
| hive_flutter | ^1.1.0 | Integración Hive + Flutter |
| shared_preferences | ^2.5.3 | Storage key-value |
| firebase_core | ^4.4.0 | Inicialización Firebase |
| firebase_analytics | ^12.1.1 | Tracking de eventos |
| firebase_remote_config | ^6.1.4 | Feature flags dinámicos |
| flutter_dotenv | ^6.0.0 | Variables de entorno |
| connectivity_plus | ^6.1.2 | Verificación de conectividad |
| flutter_html | ^3.0.0-beta.2 | Renderizado HTML (sinopsis) |
| cupertino_icons | ^1.0.8 | Iconos iOS |
| build_runner | ^2.4.13 | Generación de código (dev) |
| hive_generator | ^2.0.1 | Generación TypeAdapters (dev) |
| bloc_test | ^10.0.0 | Testing BLoCs (dev) |
| mocktail | ^1.0.4 | Mocking (dev) |

## Cómo Correr el Proyecto

**Requisitos:**
- Flutter SDK: `3.32.8` o superior
- Cuenta Firebase (Analytics + Remote Config)
- TMDB API Key: [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)

**Pasos:**

1. Clonar repositorio:
```bash
git clone <repository-url>
cd imdumb
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Generar código (Hive adapters):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configurar variables de entorno:

Crear `.env.development` y `.env.production` en la raíz:
```env
TMDB_API_KEY=tu_api_key_aqui
TMDB_BASE_URL=https://api.themoviedb.org/3
```

5. Configurar Firebase (ver sección siguiente)

6. Ejecutar app:

**Development:**
```bash
flutter run -t lib/main_dev.dart
```

**Production:**
```bash
flutter run -t lib/main_prod.dart
```

**Default (development):**
```bash
flutter run
```

## Configuración Firebase

**Servicios utilizados:**
- Firebase Analytics
- Firebase Remote Config

**Archivos de configuración:**

Android: `android/app/google-services.json`
iOS: `ios/Runner/GoogleService-Info.plist`

Descargar desde Firebase Console y ubicar en los paths indicados.

**Remote Config:**

La app usa Remote Config para habilitar/deshabilitar búsqueda y configurar parámetros dinámicamente. Parámetros implementados:

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `search_enabled` | Boolean | `false` | Habilita búsqueda |
| `search_min_characters` | Number | `3` | Caracteres mínimos |
| `search_debounce_ms` | Number | `500` | Debounce en ms |
| `search_placeholder` | String | `"Buscar películas..."` | Placeholder input |
| `min_app_version` | Number | `1` | Versión mínima requerida |
| `maintenance_mode` | Boolean | `false` | Modo mantenimiento |
| `maintenance_message` | String | `""` | Mensaje mantenimiento |

Crear estos parámetros en Firebase Console > Remote Config.

**Implementación:**

`FirebaseRemoteConfigService` (`lib/core/remote_config/firebase_remote_config_service.dart`) fetches config en `AppInitializer` durante splash. El estado se expone mediante snapshot pattern:

```dart
final config = remoteConfigService.snapshot.appConfig;
if (config.searchEnabled) { /* mostrar búsqueda */ }
```

## Endpoints TMDB

Base URL: `https://api.themoviedb.org/3`

| Endpoint | Método | Uso |
|----------|--------|-----|
| `/movie/popular` | GET | Películas populares (paginado) |
| `/movie/top_rated` | GET | Mejor valoradas (paginado) |
| `/movie/upcoming` | GET | Próximos estrenos (paginado) |
| `/movie/{id}?append_to_response=images,credits` | GET | Detalle + imágenes + actores |
| `/search/movie?query={query}` | GET | Búsqueda (paginado) |

**Parámetros comunes:**
- `api_key` (required): API key de TMDB
- `language` (optional): Default `es-MX`
- `page` (optional): Paginación, default `1`

**URLs de imágenes:**
- Posters: `https://image.tmdb.org/t/p/w500{poster_path}`
- Backdrops: `https://image.tmdb.org/t/p/original{backdrop_path}`

## SOLID

El proyecto aplica principios SOLID:

- **Single Responsibility**: Cada clase tiene una responsabilidad única (`MovieRepository` → datos, `HomeBloc` → estado home, `FirebaseAnalyticsService` → analytics).
- **Open/Closed**: Interfaces (`AnalyticsService`, `RemoteConfigService`) permiten extensión sin modificación. Nuevas implementaciones se agregan sin tocar código existente.
- **Liskov Substitution**: `FirebaseAnalyticsService` sustituye `AnalyticsService` sin romper contratos. `MovieDetailModel extends MovieModel` funciona en cualquier contexto de `MovieModel`.
- **Interface Segregation**: Interfaces específicas (`AnalyticsService` vs `RemoteConfigService`) evitan métodos innecesarios.
- **Dependency Inversion**: Service locator inyecta abstracciones (`serviceLocator<AnalyticsService>()`). BLoCs reciben repositorios por constructor, no instancian dependencias internamente.

Ejemplos concretos en: `lib/core/analytics/`, `lib/core/di/service_locator.dart`, `lib/features/movies/presentation/blocs/`, `lib/features/movies/data/repositories/`.

## Screenshots

//TO-DO: Agregar capturas de pantalla

- Home page
- Detalle de película
- Búsqueda
- Favoritos
- Dialog de recomendación
