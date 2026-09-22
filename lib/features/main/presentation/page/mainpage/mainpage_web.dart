import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/file_picker_utils.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_event.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';

class MainpageWeb extends StatelessWidget {
  const MainpageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 150,
          width: 150,
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

                  context.read<RecentListBloc>().add(
                    AddFileToRecentListEvent(workingFile: workingFile),
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
        OmniFooter(),
      ],
    );
  }
}
