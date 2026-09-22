import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/main/presentation/page/mainpage/mainpage_all.dart';
import 'package:omni_preview/features/main/presentation/page/mainpage/mainpage_web.dart';
import 'package:receive_intent/receive_intent.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static bool _initialIntentHandled = false;

  @override
  void initState() {
    super.initState();
    if (!_initialIntentHandled) {
      _initialIntentHandled = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _handleInitialIntent(),
      );
    }
  }

  Future<void> _handleInitialIntent() async {
    if (kIsWeb) return;
    String? path;
    String? workingPath;

    try {
      final intent = await ReceiveIntent.getInitialIntent();
      if (intent?.data != null) {
        path = intent!.data;
      } else {
        final uri = intent?.extra?['android.intent.extra.STREAM'];
        if (uri != null) {
          path = uri.toString();
        }
      }
    } catch (_) {}

    if (path != null && Platform.isAndroid) {
      try {
        workingPath = await getFilePathFromUri(path);
      } catch (_) {}
    }

    if (path != null && mounted) {
      final file = WorkingFile(
        path: workingPath ?? path,
        workingPath: workingPath ?? path,
      );
      openScreenForFile(context, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: (kIsWeb) ? const MainpageWeb() : const MainpageAll(),
    );
  }
}
