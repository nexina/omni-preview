import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';

class TextViewer extends StatefulWidget {
  final WorkingFile workingFile;
  const TextViewer({super.key, required this.workingFile});

  @override
  State<TextViewer> createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> {
  double fontSize = 16.0;

  void increaseFontSize() {
    setState(() {
      fontSize += 2;
    });
  }

  void decreaseFontSize() {
    setState(() {
      if (fontSize > 2) fontSize -= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(widget.workingFile.path),
            desc: getFilePathWithoutFileName(widget.workingFile.path),
            actionButton: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          title: const Text('Adjust Font Size'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setDialogState(() {
                                    decreaseFontSize();
                                  });
                                },
                              ),
                              Text(fontSize.toInt().toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setDialogState(() {
                                    increaseFontSize();
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
          Expanded(
            child: _TextView(
              filePath: widget.workingFile.workingPath,
              fontSize: fontSize,
            ),
          ),
          OmniFooter(),
        ],
      ),
    );
  }
}

class _TextView extends StatefulWidget {
  final String filePath;
  final double fontSize;
  const _TextView({required this.filePath, this.fontSize = 16.0});

  @override
  State<_TextView> createState() => __TextViewState();
}

class __TextViewState extends State<_TextView> {
  Future<String> getFileContent() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return "File not found.";
      }
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getFileContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.white),
              trackColor: WidgetStateProperty.all(Colors.white24),
              trackBorderColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
          child: TextField(
            maxLines: null,
            expands: true,
            readOnly: true,
            scrollPadding: const EdgeInsets.all(16.0),
            scrollPhysics: const BouncingScrollPhysics(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
            scrollController: ScrollController(),
            style: TextStyle(fontSize: widget.fontSize, color: Colors.white),
            controller: TextEditingController(text: snapshot.data ?? ""),
          ),
        );
      },
    );
  }
}
