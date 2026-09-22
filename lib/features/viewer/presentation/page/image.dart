import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';

class ImageViewer extends StatelessWidget {
  final WorkingFile workingFile;
  const ImageViewer({super.key, required this.workingFile});

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(workingFile.path),
            desc: getFilePathWithoutFileName(workingFile.path),
          ),
          ImageView(filePath: workingFile.workingPath),
          OmniFooter(),
        ],
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  final String filePath;
  const ImageView({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final ext = getExtension(filePath);
    return Expanded(
      child: InteractiveViewer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: (ext == "svg")
                ? FutureBuilder<Uint8List>(
                    future: File(filePath).readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SvgPicture.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                        );
                      }
                      return const SizedBox.shrink(); // Or a loading indicator
                    },
                  )
                : Image.file(File(filePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
