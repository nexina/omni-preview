import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/di/injection_container.dart' as di;
import 'package:omni_preview/core/router/app_router.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_event.dart';
import 'package:pdfrx/pdfrx.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await pdfrxFlutterInitialize();
  await di.init();

  String? initialFilePath;
  // Windows / Desktop file association (primary case)
  if (args.isNotEmpty) {
    final candidate = args.first;
    final file = File(candidate);
    if (file.existsSync()) {
      initialFilePath = file.absolute.path;
    }
  }

  // Set the working directory base to the application folder
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    Directory.current = File(Platform.resolvedExecutable).parent.path;
  }

  runApp(MyApp(initialFilePath: initialFilePath));
}

class MyApp extends StatelessWidget {
  final String? initialFilePath;

  const MyApp({super.key, this.initialFilePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.getIt<RecentListBloc>()..add(LoadRecentListEvent()),
      child: MaterialApp.router(
        title: 'Omni preview',
        // theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return InitialPathHandler(
            initialFilePath: initialFilePath,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class InitialPathHandler extends StatefulWidget {
  final String? initialFilePath;
  final Widget child;

  const InitialPathHandler({
    super.key,
    this.initialFilePath,
    required this.child,
  });

  @override
  State<InitialPathHandler> createState() => _InitialPathHandlerState();
}

class _InitialPathHandlerState extends State<InitialPathHandler> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null) {
      if (widget.initialFilePath != null && !_handled) {
        _handled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final WorkingFile file = WorkingFile(
            path: widget.initialFilePath!,
            workingPath: widget.initialFilePath!,
          );
          print(file.path);
          openScreenForFile(context, file);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
