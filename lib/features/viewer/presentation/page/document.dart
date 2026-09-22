import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';
import 'package:pdfrx/pdfrx.dart';

class DocumentViewer extends StatelessWidget {
  final WorkingFile workingFile;
  const DocumentViewer({super.key, required this.workingFile});

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(workingFile.path),
            desc: getFilePathWithoutFileName(workingFile.path),
          ),
          DocumentView(filePath: workingFile.workingPath),
          OmniFooter(),
        ],
      ),
    );
  }
}

class DocumentView extends StatefulWidget {
  final String filePath;
  const DocumentView({super.key, required this.filePath});

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  late Future<Uint8List> _fileBytesFuture;
  late String ext;

  @override
  void initState() {
    super.initState();
    _fileBytesFuture = File(widget.filePath).readAsBytes();
    ext = getExtension(widget.filePath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _fileBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (snapshot.hasData) {
          return Expanded(
            child: SizedBox(
              width: double.infinity,
              child: (ext == 'pdf')
                  ? PdfViewer.file(widget.filePath)
                  : (ext == "docx")
                  ? DocxView.path(widget.filePath)
                  : Center(child: MicrosoftViewer(snapshot.data!, false)),
            ),
          );
        }
        return const Expanded(
          child: Center(
            child: Text(
              "Failed to load document",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
