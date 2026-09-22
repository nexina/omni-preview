import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:media_kit/media_kit.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/utililty/utility.dart';
import 'package:omni_preview/features/common/widget/background_builder.dart';
import 'package:omni_preview/features/viewer/presentation/widget/omni_footer.dart';
import 'package:omni_preview/features/viewer/presentation/widget/viewer-appbar.dart';

class AudioViewer extends StatelessWidget {
  final WorkingFile workingFile;
  const AudioViewer({super.key, required this.workingFile});

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          AppBarViewer(
            title: getFileName(workingFile.path),
            desc: getFilePathWithoutFileName(workingFile.path),
          ),
          AudioPlayerView(filePath: workingFile.workingPath),
          OmniFooter(),
        ],
      ),
    );
  }
}

class AudioPlayerView extends StatefulWidget {
  final String filePath;
  const AudioPlayerView({super.key, required this.filePath});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  // Create a [Player] instance.
  late final player = Player();
  late Future<Metadata> _metadataFuture;

  // Store stream subscriptions to cancel them later.
  final List<StreamSubscription> _subscriptions = [];

  // Player state.
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    // Get metadata.
    _metadataFuture = MetadataRetriever.fromFile(File(widget.filePath));
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
    return FutureBuilder<Metadata>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        final metadata = snapshot.data;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (metadata?.albumArt != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        metadata!.albumArt!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.audiotrack,
                      size: 150,
                      color: Colors.white54,
                    ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      metadata?.trackName ?? getFileName(widget.filePath),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      metadata?.trackArtistNames?.join(', ') ??
                          'Unknown Artist',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 600),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
