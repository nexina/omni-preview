# omni_viewer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building & Packaging

### Windows (Microsoft Store / MSIX Packaging)
1. Build release binaries:
   ```bash
   flutter build windows --release
   ```
2. Generate MSIX Package (with automatic declarative file associations for Microsoft Store):
   ```bash
   dart run msix:create
   ```
   *The generated `.msix` file will be in `build/windows/x64/runner/Release/omni_preview.msix`.*

### Android (Google Play Store)
1. Build Android App Bundle (.aab):
   ```bash
   flutter build appbundle --release
   ```

### Linux
```bash
sudo apt install libmpv-dev mpv libgtk-3-dev lld
sudo -E env "PATH=$PATH" flutter build linux --release -v
```
