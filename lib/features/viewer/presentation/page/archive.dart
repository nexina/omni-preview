import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/main/presentation/widget/file_icon.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';

class ArchieveViewer extends StatelessWidget {
  final WorkingFile workingFile;
  const ArchieveViewer({super.key, required this.workingFile});

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(workingFile.path),
            desc: getFilePathWithoutFileName(workingFile.path),
          ),
          ArchieveView(filePath: workingFile.workingPath),
          OmniFooter(),
        ],
      ),
    );
  }
}

class ArchieveView extends StatefulWidget {
  final String filePath;
  const ArchieveView({super.key, required this.filePath});

  @override
  State<ArchieveView> createState() => _ArchieveViewState();
}

class _ArchieveViewState extends State<ArchieveView> {
  Archive? archive;
  String currentPath = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    try {
      final bytes = await File(widget.filePath).readAsBytes();
      final decodedArchive = await compute(_decodeArchive, {
        'bytes': bytes,
        'path': widget.filePath,
      });
      if (mounted) {
        setState(() {
          archive = decodedArchive;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (archive == null) {
      return const Expanded(
        child: Center(
          child: Text(
            "Failed to load archive",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    Set<String> folders = {};
    List<String> filesInDir = [];

    for (final file in archive!) {
      if (!file.isFile) continue;
      String name = file.name;
      if (name.startsWith(currentPath)) {
        String relative = name.substring(currentPath.length);
        if (relative.isEmpty) continue;

        int slashIndex = relative.indexOf('/');
        if (slashIndex != -1) {
          String folderName = relative.substring(0, slashIndex);
          folders.add(folderName);
        } else {
          filesInDir.add(relative);
        }
      }
    }

    List<String> sortedFolders = folders.toList()..sort();
    filesInDir.sort();

    return Expanded(
      child: (folders.isEmpty && filesInDir.isEmpty && currentPath.isEmpty)
          ? const Center(
              child: Text(
                "No files found",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(Colors.white),
                  trackColor: WidgetStateProperty.all(Colors.white24),
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
              child: ListView(
                children: [
                  if (currentPath.isNotEmpty)
                    ListTile(
                      leading: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "..",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          if (currentPath.endsWith('/')) {
                            currentPath = currentPath.substring(
                              0,
                              currentPath.length - 1,
                            );
                          }
                          int lastSlash = currentPath.lastIndexOf('/');
                          if (lastSlash == -1) {
                            currentPath = "";
                          } else {
                            currentPath = currentPath.substring(
                              0,
                              lastSlash + 1,
                            );
                          }
                        });
                      },
                    ),
                  ...sortedFolders.map(
                    (folder) => ListTile(
                      leading: const Icon(Icons.folder, color: Colors.yellow),
                      title: Text(
                        folder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          currentPath += "$folder/";
                        });
                      },
                    ),
                  ),
                  ...filesInDir.map(
                    (file) => _ArchieveViewListItem(fileName: file),
                  ),
                ],
              ),
            ),
    );
  }
}

Archive _decodeArchive(Map<String, dynamic> params) {
  final bytes = params['bytes'] as List<int>;
  final path = (params['path'] as String).toLowerCase();

  if (path.endsWith('.tar.gz') || path.endsWith('.tgz')) {
    return TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
  } else if (path.endsWith('.tar.bz2') || path.endsWith('.tbz')) {
    return TarDecoder().decodeBytes(BZip2Decoder().decodeBytes(bytes));
  } else if (path.endsWith('.tar.xz') || path.endsWith('.txz')) {
    return TarDecoder().decodeBytes(XZDecoder().decodeBytes(bytes));
  } else if (path.endsWith('.tar')) {
    return TarDecoder().decodeBytes(bytes);
  }
  return ZipDecoder().decodeBytes(bytes);
}

class _ArchieveViewListItem extends StatefulWidget {
  final String fileName;
  const _ArchieveViewListItem({required this.fileName});

  @override
  State<_ArchieveViewListItem> createState() => _ArchieveViewListItemState();
}

class _ArchieveViewListItemState extends State<_ArchieveViewListItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: FileIcon(filePath: widget.fileName),
              title: Text(
                widget.fileName,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (_isHovering)
            Container(
              height: 1.0,
              margin: const EdgeInsets.symmetric(horizontal: 13.0),
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
