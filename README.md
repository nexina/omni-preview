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

### Linux (Flatpak / Flathub)

App ID: `nexina.omni.preview`

> **Note:** Source is not published — the Flatpak manifest installs a
> **prebuilt release tarball** (`type: archive`) instead of building from
> source (`type: dir` / `type: git`). This keeps the private source repo
> private while still satisfying Flathub's requirement that build inputs be
> publicly, anonymously fetchable.
>
> `mpv` is built with `-Dgpl=false` (LGPLv2.1+ build) and no
> `org.freedesktop.Platform.ffmpeg-full` extension is used, keeping the
> dependency chain LGPL/MIT/ISC — compatible with the app's MIT license and
> free of GPL contamination.

#### 1. Build and package the release tarball
```bash
flutter build linux --release
cp LICENSE build/linux/x64/release/bundle/
cd build/linux/x64/release/bundle
tar czf ../../../../omni-preview-linux-x64-<version>.tar.gz .
cd -
sha256sum omni-preview-linux-x64-<version>.tar.gz
```

#### 1b. Copy Flatpak packaging files
```bash
# Copy AppStream metainfo, desktop entry, icon, and license to flatpak/ directory
cp linux/nexina.omni.preview.metainfo.xml flatpak/
cp linux/nexina.omni.preview.desktop flatpak/
cp linux/nexina.omni.preview.png flatpak/
cp LICENSE flatpak/
```

#### 2. Publish the tarball publicly
Upload `omni-preview-linux-x64-<version>.tar.gz` as a GitHub Release asset on
the public `omni-preview-releases` repo (source-free — packaging/distribution
only), tagged `v<version>`. Copy the asset URL and the `sha256sum` output into
the `preview` module's `sources:` in `flatpak/nexina.omni.preview.yml`:
```yaml
sources:
  - type: archive
    url: https://github.com/nexina/omni-preview-releases/releases/download/v<version>/omni-preview-linux-x64-<version>.tar.gz
    sha256: <sha256 from step 1>
  - type: file
    path: preview-wrapper.sh
  - type: file
    path: nexina.omni.preview.metainfo.xml
  - type: file
    path: nexina.omni.preview.desktop
  - type: file
    path: nexina.omni.preview.png
  - type: file
    path: LICENSE
```

#### 3. Test Local Flatpak Build
```bash
# Install Freedesktop SDK/Platform runtime
flatpak install flathub org.freedesktop.Sdk//24.08 org.freedesktop.Platform//24.08

sudo apt install flatpak-builder

# Build the flatpak package locally
flatpak-builder --user --install --force-clean build-dir flatpak/nexina.omni.preview.yml

# Test running the built flatpak locally
flatpak-builder --run build-dir flatpak/nexina.omni.preview.yml omni_preview

# Run the Flathub linter (same check Flathub CI runs)
flatpak install flathub org.flatpak.Builder
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest flatpak/nexina.omni.preview.yml

# Known linter exceptions (document in Flathub PR):
# - appid-url-not-reachable: false positive — linter tries `omni.nexina` from reversed app-id;
#   actual homepage is https://github.com/nexina/omni-previewer (set in metainfo.xml)
# - finish-args-portal-talk-name: required for file picker portal access

# Validate the metainfo file
flatpak install flathub org.freedesktop.appstream-glib
flatpak run org.freedesktop.appstream-glib validate linux/nexina.omni.preview.metainfo.xml
```

#### 4. Submit to Flathub
1. Fork [flathub/flathub](https://github.com/flathub/flathub) on GitHub.
2. Create a new branch named `nexina.omni.preview`.
3. Commit only the small packaging files (no app source) to the branch root:
   `nexina.omni.preview.yml`, `preview-wrapper.sh`,
   `nexina.omni.preview.metainfo.xml`, `nexina.omni.preview.desktop`,
   `nexina.omni.preview.png`, `LICENSE`.
4. Submit a Pull Request against `flathub/flathub`.

**Releasing an update:** repeat steps 1–2 (new tarball, new tag, new
`url`/`sha256` in the manifest), then push the change as a new commit/PR —
there is no automated rebuild-from-git step since the source stays private.