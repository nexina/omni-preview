import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/file_picker_utils.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:intl/intl.dart';
import 'package:uri_to_file/uri_to_file.dart';

import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_state.dart';
import 'package:omni_preview/features/main/presentation/widget/file_icon.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';

class MainpageAll extends StatelessWidget {
  const MainpageAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecentTitle(),
        SizedBox(height: 12),
        _RecentFilesList(),
        SizedBox(height: 12),
        OmniFooter(onNexinaPressed: () {}, onOmniPressed: () {}),
      ],
    );
  }
}

class _RecentTitle extends StatelessWidget {
  const _RecentTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0),
      child: Row(
        children: [
          Text(
            "Recent",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Inria Sans",
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              height: 38,
              child: TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final pickedFile = await pickFile();
                    // Ensure the widget is still mounted before using context after an async gap.
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true).pop();
                    final path = pickedFile?.path;
                    if (path != null) {
                      if (!context.mounted) return;

                      int size = 0;
                      try {
                        size = await File(path).length();
                      } catch (_) {}

                      final workingFile = WorkingFile(
                        path: path,
                        workingPath: path,
                        size: size,
                      );

                      openScreenForFile(context, workingFile);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  }
                },
                child: Text(
                  "Open File",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: "Inria Sans",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFilesList extends StatelessWidget {
  const _RecentFilesList();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<RecentListBloc, RecentListState>(
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: switch (state) {
              RecentListInitial() || RecentListLoading() => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              RecentListLoaded(recentFiles: final files) =>
                files.isEmpty
                    ? const Center(
                        child: Text(
                          "No recent files",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(Colors.white),
                            trackColor: WidgetStateProperty.all(Colors.white24),
                            trackBorderColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return _RecentFilesListItem(
                              lastOpened: file.lastOpened,
                              filePath: file.filePath,
                              fileSize: file.fileSize,
                            );
                          },
                        ),
                      ),
              RecentListError(errorMessage: final msg) => Center(
                child: Text(msg, style: const TextStyle(color: Colors.red)),
              ),
              RecentListState() => throw UnimplementedError(),
            },
          );
        },
      ),
    );
  }
}

class _RecentFilesListItem extends StatefulWidget {
  final DateTime lastOpened;
  final String filePath;
  final String fileSize;
  const _RecentFilesListItem({
    required this.lastOpened,
    required this.filePath,
    required this.fileSize,
  });

  @override
  State<_RecentFilesListItem> createState() => _RecentFilesListItemState();
}

class _RecentFilesListItemState extends State<_RecentFilesListItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    String fileName = getFileName(widget.filePath);
    String lastOpened = DateFormat(
      'd MMMM y, hh:mm a',
    ).format(widget.lastOpened);

    return GestureDetector(
      onTap: () async {
        String workingPath = widget.filePath;
        if (Platform.isAndroid && widget.filePath.startsWith('content://')) {
          final file = await UriToFilePlatform.instance.toFile(widget.filePath);
          workingPath = file.path;
        }

        int size = 0;
        try {
          size = await File(workingPath).length();
        } catch (_) {}

        final workingFile = WorkingFile(
          path: widget.filePath,
          workingPath: workingPath,
          size: size,
        );

        await openScreenForFile(context, workingFile);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListTile(
              leading: FileIcon(filePath: widget.filePath),
              title: Text(
                fileName,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(184, 255, 255, 255),
                          size: 12,
                        ),
                        Text(
                          lastOpened,
                          style: const TextStyle(
                            color: Color.fromARGB(184, 255, 255, 255),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 4,
                      children: [
                        const Icon(
                          Icons.file_copy,
                          color: Color.fromARGB(184, 255, 255, 255),
                          size: 12,
                        ),
                        Text(
                          widget.fileSize,
                          style: const TextStyle(
                            color: Color.fromARGB(184, 255, 255, 255),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
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
      ),
    );
  }
}
