# napstack

A new Flutter project.

## Build — `--dart-define` (Appwrite, RevenueCat)

- **Nigdy** nie trzymaj `APPWRITE_PROJECT_ID` ani `RC_PUBLIC_KEY_ANDROID` w kodzie; podawane przy buildzie.
- Lokalnie: w katalogu projektu utwórz `.env` (jest w `.gitignore`), potem:
  - `python3 tool/sync_dart_defines_from_env.py` — generuje `dart_defines.local.json`
  - `flutter run --dart-define-from-file=dart_defines.local.json`
- APK release (przykład):
  - `flutter build apk --dart-define=APPWRITE_PROJECT_ID=... --dart-define=RC_PUBLIC_KEY_ANDROID=...`
  - lub ten sam plik: `--dart-define-from-file=ścieżka/do/dart_defines.local.json`
- Puste `APPWRITE_PROJECT_ID` w kodzie: musisz nadać define przy każdym buildzie, inaczej backend nie wskaże projektu.
- **GitHub Actions** (`.github/workflows/android-release.yml`): dodaj w repo **Settings → Secrets and variables → Actions** wpisy `APPWRITE_PROJECT_ID` i `RC_PUBLIC_KEY_ANDROID` — workflow wstrzykuje je do `flutter build appbundle` przez `--dart-define`.

### Wersja i numer buildu (Etap 10)

- `pubspec.yaml` → `version: x.y.z+build` (np. `1.0.0+1`). Android `versionCode` bierze się z `+build`.
- `version.txt` — lustrzana kopia; utrzymywana przez:
  - `bash script/bump_build.sh` — przed wydaniem w Google Play zwiększ sam numer po `+`.
- Gradle **nie** wstrzykuje `--dart-define` (robi to wyłącznie `flutter run` / `flutter build`); w `android/app/build.gradle.kts` są tylko `versionCode` / `versionName` z `flutter.versionCode` / `flutter.versionName`.

### Testy (Etap 11)

- Wszystkie: `flutter test` (w tym `test/integration/boot_recovery_test.dart`).
- Uwaga: katalogu projektu `integration_test/` używaj z pakietem `integration_test` i **podłączonym urządzeniem** (`flutter test integration_test/ -d …`); smoke boot recovery jest w `test/integration/`, żeby przechodził w CI bez emulatora.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
