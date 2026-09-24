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
**Required dependency for file dialogs:** `zenity` (GTK dialog backend)
```bash
sudo apt install zenity libmpv-dev mpv libgtk-3-dev lld
sudo -E env "PATH=$PATH" flutter build linux --release -v
```

> **Note:** The `file_picker` package requires `zenity` (or `kdialog`/`qarma`) to show native file dialogs on Linux. On GNOME-based distros (Ubuntu, Zorin OS, Fedora, etc.), install `zenity`. On KDE Plasma, install `kdialog` instead.

### Linux (Flatpak / Flathub)

App ID: `nexina.omni.preview`

> **Note:** The Flatpak manifest now bundles `zenity` (built from source), so file dialogs work out-of-the-box without host dependencies.

#### 1. Activate `flutpak` and Generate Offline Bundle
Flathub builds apps 100% offline using pre-declared package and SDK SHA-256 hashes.
Use [`flutpak`](https://pub.dev/packages/flutpak) to generate the offline sources and manifest:
```bash
# Activate flutpak CLI tool
dart pub global activate flutpak

# Generate offline sources and Flathub manifest for tag/release v1.0.1
flutpak generate
```
*This generates `flatpak/generated/pubspec-sources.json` (containing 466 offline package & engine sources) and the release manifest `flatpak/generated/nexina.omni.preview.yml`.*

#### 2. Test Local Flatpak Build
```bash
# Install Freedesktop SDK and LLVM extension
flatpak install flathub org.freedesktop.Sdk//24.08 org.freedesktop.Platform//24.08 org.freedesktop.Sdk.Extension.llvm19//24.08

sudo apt install flatpak-builder

# Build the flatpak package locally using generated manifest
flatpak-builder --user --install --force-clean build-dir flatpak/generated/nexina.omni.preview.yml

# Test running the built flatpak locally
flatpak-builder --run build-dir flatpak/generated/nexina.omni.preview.yml omni_preview

# Run Flathub linter
flatpak-builder-lint manifest flatpak/generated/nexina.omni.preview.yml
```

#### 3. Submit to Flathub
1. Fork [flathub/flathub](https://github.com/flathub/flathub) on GitHub.
2. Create a new branch named `nexina.omni.preview`.
3. Add `flatpak/generated/nexina.omni.preview.yml`, `pubspec-sources.json`, and `flathub.json`.
4. Submit a Pull Request against `flathub/flathub`.


