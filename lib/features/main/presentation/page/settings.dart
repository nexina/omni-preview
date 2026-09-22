import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_event.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/omni-preview-logo.png",
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 14),
                Text(
                  "Omni Preview",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Inria Sans",
                    fontSize: 30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: "Inria Sans",
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: ListView(
                children: [
                  _ListItem(
                    title: "Clear Recent Files",
                    color: Color.fromARGB(255, 255, 137, 129),
                    onPressed: () {
                      context.read<RecentListBloc>().add(
                        ClearRecentListEvent(),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Preferences Cleared")),
                        );
                      }
                    },
                  ),
                  _ListItem(
                    title: "Visit Website",
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://nexina.github.io/omni/index.html',
                      );
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  _ListItem(
                    title: "Terms and Policy",
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://nexina.github.io/omni/terms-and-policy.html',
                      );
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color color;
  const _ListItem({
    required this.title,
    this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white70, width: 1)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(color: color, fontFamily: "Inria Sans"),
        ),
      ),
    );
  }
}
