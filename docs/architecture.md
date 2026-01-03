# FidelyKey Architecture

This project follows **Clean Architecture** principles to ensure scalability, testability, and separation of concerns.

## Folder Structure (`/lib`)

```text
lib/
├── core/                       # Shared kernel
│   ├── error/                  # Custom Exceptions & Failures
│   ├── network/                # Network info, interceptors (if using API)
│   ├── theme/                  # Theme data, colors, typography (Poppins/JetBrains Mono)
│   ├── constants/              # App constants (Strings, Assets, Config)
│   └── utils/                  # Utility functions (Encryption helpers, Date formatters)
│
├── features/                   # Features separated by domain
│   └── totp/                   # The core TOTP feature
│       ├── data/               # Data Layer
│       │   ├── datasources/    # Local Storage (FlutterSecureStorage), Remote (optional)
│       │   ├── models/         # DTOs (Data Transfer Objects) with JSON serialization
│       │   │   └── totp_account_model.dart
│       │   └── repositories/   # Implementation of Domain Repositories
│       │       └── totp_repository_impl.dart
│       │
│       ├── domain/             # Domain Layer (Pure Dart, no Flutter UI dependencies usually)
│       │   ├── entities/       # Business Objects
│       │   │   └── totp_account.dart
│       │   ├── repositories/   # Repository Interfaces (Contracts)
│       │   │   └── totp_repository.dart
│       │   └── usecases/       # Business Logic / Interactors
│       │       ├── add_account.dart
│       │       ├── get_all_accounts.dart
│       │       ├── generate_totp_code.dart
│       │       └── delete_account.dart
│       │
│       └── presentation/       # Presentation Layer (UI & State Management)
│           ├── providers/      # Riverpod Providers (Controllers/ViewModels)
│           │   └── totp_list_provider.dart
│           ├── widgets/        # Reusable feature-specific widgets
│           │   ├── totp_card.dart
│           │   └── privacy_blur.dart
│           └── pages/          # Screens
│               ├── home_page.dart
│               └── scan_qr_page.dart
│
├── main.dart                   # Entry point
└── app.dart                    # Root Widget (Routing, Theme setup)
```

## Layer Responsibilities

1.  **Domain**: The heart of the app. Defines *what* the app does (Entities & Usecases). Completely independent of external libraries/UI.
2.  **Data**: Handles *how* data is stored/retrieved. Implements Domain repositories. Maps Models to Entities.
3.  **Presentation**: Handles *how* data is shown. Consumes Domain Usecases via State Management (Riverpod).

## Key Libraries Integration
-   **Riverpod**: Used in Presentation for state and Dependency Injection.
-   **Freezed**: Used in Domain (Entities) and Data (Models) for immutability and unions. 
-   **Flutter Secure Storage**: Accessed via `data/datasources/local_datasource.dart`.
