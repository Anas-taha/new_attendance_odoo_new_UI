# Home Architecture Migration Guide

This guide documents how the Home module was migrated from the old screen-based structure to the new feature-based structure.

## 1) Old Architecture (Before)

Home files were located under `lib/screens/home/`:

- `lib/screens/home/home_screen.dart`
- `lib/screens/home/home_controller.dart`
- `lib/screens/home/widgets/greeting_widget.dart`

Issues in the old setup:

- Feature logic and presentation were grouped by screen folder, not by feature layers.
- Controller and screen were harder to scale as the module grew.
- Home feature boundaries were not explicit in `features/` folders.

## 2) New Architecture (After)

Home is now organized under `lib/features/home/`:

- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`
- `lib/features/home/presentation/controllers/home_controller.dart`
- `lib/features/home/presentation/pages/home_screen.dart`

Current decision for simplicity:

- Domain entities and use cases were intentionally removed.
- Controller calls repository methods directly.
- UI side effects remain in presentation (screen listens to controller UI events).

## 3) Migration Steps Performed

### Step A - Create feature boundaries

1. Added `HomeRepository` interface in domain layer.
2. Added `HomeRepositoryImpl` in data layer.
3. Wired repository implementation to existing services:
   - `HrService`
   - `LocalStorageService`
   - `OdooRPCService`

### Step B - Simplify architecture

1. Removed extra abstraction files for simplicity:
   - entities
   - use cases
2. Updated repository API to return primitive/model-friendly values (for example, `Map<String, dynamic>` for summary).
3. Updated controller to directly use repository methods.

### Step C - Move controller and page to feature presentation layer

1. Moved controller from:
   - `lib/screens/home/home_controller.dart`
   to:
   - `lib/features/home/presentation/controllers/home_controller.dart`
2. Moved page from:
   - `lib/screens/home/home_screen.dart`
   to:
   - `lib/features/home/presentation/pages/home_screen.dart`
3. Deleted old files in `lib/screens/home/` for controller/page.

### Step D - Update imports and app wiring

Updated references in:

- `lib/app/app_bending.dart` (GetX binding import for `HomeController`)
- `lib/main.dart` (route import for `HomeScreen`)
- `lib/screens/login_screen.dart` (navigation import for `HomeScreen`)

### Step E - Verify and format

1. Formatted touched files with Dart formatter.
2. Ran Dart analyzer on updated scope.
3. Confirmed no analysis errors in migrated files.

## 4) Final Structure Snapshot

```text
lib/
  features/
    home/
      data/
        repositories/
          home_repository_impl.dart
      domain/
        repositories/
          home_repository.dart
      presentation/
        controllers/
          home_controller.dart
        pages/
          home_screen.dart
  screens/
    home/
      widgets/
        greeting_widget.dart
```

## 5) Optional Next Cleanup

To complete full Home presentation co-location, move:

- `lib/screens/home/widgets/greeting_widget.dart`

to:

- `lib/features/home/presentation/widgets/greeting_widget.dart`

and update imports accordingly.
