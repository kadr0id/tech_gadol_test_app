# tech_gadol_test_app

A responsive Flutter application that displays a product catalog consuming the DummyJSON API. Built with a focus on clean architecture, predictable state management, and a reusable design system.

## 1. Setup & Run Instructions

**Prerequisites:**
* Flutter SDK: 3.19.x (Stable channel) or higher.
* Dart SDK: 3.3.x or higher.

**Getting Started:**

1. Clone the repository.
2. Navigate to the project directory:
   cd techgadol_catalog
3. Fetch the dependencies:
   flutter pub get
4. Run the unit and widget tests to ensure everything is functioning correctly:
   flutter test
5. Run the application:
   flutter run

## 2. Architecture Overview

The application follows a Clean Architecture / Layered Architecture approach to ensure the separation of concerns, testability, and scalability.

**Folder Structure:**
* lib/data/: Contains models, data sources, and repositories. Responsible for API calls (dio) and JSON parsing.
* lib/application/: Contains the business logic and state management (flutter_bloc).
* lib/presentation/: Contains UI elements, divided into screens and widgets.
* lib/core/: Contains app-wide configurations like routing (go_router) and the design system/theming.

**Key Technical Decisions:**
* State Management: Used Bloc (flutter_bloc). It provides a highly predictable, event-driven state machine that is easy to unit test.
* Routing: Used GoRouter for declarative navigation. It seamlessly handles deep linking (e.g., /products/:id) and responsive master-detail layouts on larger screens.
* Debouncing: Utilized rxdart's EventTransformer within the Bloc to debounce search events (500ms), preventing API spam while typing.

## 3. Design System Rationale

The app includes a mini design system to maintain UI consistency and adapt to user preferences.

* Theming: Built on top of Flutter's Material 3 ThemeData and ColorScheme. It supports both light and dark modes out-of-the-box, automatically reacting to the system theme (ThemeMode.system).
* Components API:
    - ProductCard: Designed to be completely stateless, accepting only the Product entity and an onTap callback. This makes it highly reusable.
    - ProductCardShimmer: Utilized the shimmer_animation package to create a skeleton loader that exactly mirrors the ProductCard's layout, improving perceived performance.
* Responsive Design: Used LayoutBuilder in the router configuration. On screens >= 768px, it splits the view into a Master-Detail layout (List on the left, details on the right) without navigating to a new page, strictly following the spec.

## 4. Limitations & Future Improvements

Due to the 3-4 hours time constraint, some architectural and feature shortcuts were taken. If given more time, I would improve the following:

1. Offline Caching (Enhancement B): I would implement local storage using Isar or Hive to cache the first page of products and categories, allowing the app to launch offline.
2. Localization (l10n): Hardcoded English strings were used in the UI. In a production app, I would implement flutter_localizations with .arb files.
3. Advanced Error Handling: Currently, the app shows a generic error message. I would implement an Either<Failure, Success> pattern using the fpdart or dartz package to strictly type API errors (e.g., NetworkFailure, ServerFailure).
4. Dependency Injection: Replace the manual RepositoryProvider injection with a DI package like get_it and injectable for better scalability.

## 5. AI Tools Usage

AI tools (specifically LLMs) were used strategically to speed up boilerplate generation, which is a standard practice for my workflow to maximize efficiency:

* JSON Parsing & Models: Used AI to quickly generate the Product model from the DummyJSON payload and implement the fallback logic for missing/negative fields.
* Testing Boilerplate: Used AI to generate the basic setup for mocktail and bloc_test, which I then manually refined to test specific edge cases (like the pagination hasReachedMax logic and negative price handling).
* Refinement: AI output was heavily reviewed and modified to strictly adhere to the project's layered architecture and to implement specific features like the rxdart debouncer.

### Offline Support & Caching Strategy

**Storage Choice:** For this 3-4 hour assessment, I chose `shared_preferences` to store the raw JSON response as a string.
* *Why:* It requires zero boilerplate or code generation (unlike `Drift` or `Isar`), making it perfect for caching a simple catalog endpoint under strict time limits. For a full-scale production app with complex relations and querying needs, I would migrate to **Isar** or **Drift**. **Hive** is also a great NoSQL alternative, but `shared_preferences` is sufficient for a single-key JSON cache.

**Invalidation Strategy (TTL):** I implemented a Time-To-Live (TTL) strategy. The cache is considered "fresh" for 1 hour.
* When fetching data, the app always attempts the network call first to get the most up-to-date data.
* If the network call fails (e.g., no internet), it falls back to the local cache.
* If the data is served from the cache, the UI displays a visual indicator (a "No Internet" offline banner).