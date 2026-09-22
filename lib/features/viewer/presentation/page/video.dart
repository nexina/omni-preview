import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';

class VideoViewer extends StatefulWidget {
  final WorkingFile workingFile;
  const VideoViewer({super.key, required this.workingFile});

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(widget.workingFile.path),
            desc: getFilePathWithoutFileName(widget.workingFile.path),
          ),
          VideoPlayerView(filePath: widget.workingFile.workingPath),
          OmniFooter(),
        ],
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  final String filePath;
  const VideoPlayerView({super.key, required this.filePath});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  // Create a [Player] instance.
  late final player = Player();
  late final controller = VideoController(player);

  // Store stream subscriptions to cancel them later.
  final List<StreamSubscription> _subscriptions = [];

  // Player state.
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool playing = false;

  @override
  void initState() {
    super.initState();

    // Open the media.
    player.open(Media(widget.filePath), play: false);

    // Listen to player streams.
    _subscriptions.addAll([
      player.stream.position.listen((p) {
        if (mounted) setState(() => position = p);
      }),
      player.stream.duration.listen((d) {
        if (mounted) setState(() => duration = d);
      }),
      player.stream.playing.listen((p) {
        if (mounted) setState(() => playing = p);
      }),
      player.stream.completed.listen((completed) {
        if (completed && mounted) {
          // Reset position to the beginning when playback completes.
          setState(() => position = Duration.zero);
        }
      }),
    ]);
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions.
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    // Dispose the player instance.
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Video(
                      controller: controller,
                      controls: NoVideoControls,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatDuration(position),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Spacer(),
                              Text(
                                formatDuration(duration),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: position.inMilliseconds.toDouble().clamp(
                            0.0,
                            duration.inMilliseconds.toDouble(),
                          ),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            player.seek(Duration(milliseconds: value.round()));
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                        ),
                        IconButton(
                          onPressed: player.playOrPause,
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
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
