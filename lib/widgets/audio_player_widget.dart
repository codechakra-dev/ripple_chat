import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// A widget that plays and pauses audio from a URL.
/// Shows a play/pause button, loading spinner, and progress bar.
class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final Color? buttonColor;
  final double buttonSize;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    this.buttonColor,
    this.buttonSize = 48,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false; // ✅ manual loading flag
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initListeners() {
    // Listen for total duration
    _player.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });

    // Listen for current playback position
    _player.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });

    // Listen for player state changes
    _player.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          // ✅ Handle only the valid states (lowercase)
          if (state == PlayerState.playing) {
            _isLoading = false;
            _isPlaying = true;
          } else if (state == PlayerState.paused ||
              state == PlayerState.stopped ||
              state == PlayerState.completed) {
            _isPlaying = false;
            _isLoading = false;
          }
        });
      }
    });

    // Handle completion
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _play() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _player.play(UrlSource(widget.url));
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to play audio: $e')));
      }
    }
  }

  Future<void> _pause() async {
    try {
      await _player.pause();
    } catch (e) {
      // ignore
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.buttonColor ?? Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _isLoading ? null : _togglePlayPause,
          borderRadius: BorderRadius.circular(widget.buttonSize / 2),
          child: Container(
            width: widget.buttonSize,
            height: widget.buttonSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: widget.buttonSize * 0.5,
                      height: widget.buttonSize * 0.5,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: color,
                      size: widget.buttonSize * 0.6,
                    ),
            ),
          ),
        ),
        // Progress bar (shown after duration is known)
        if (_duration > Duration.zero)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: widget.buttonSize * 2,
              child: LinearProgressIndicator(
                value: _position.inMilliseconds / _duration.inMilliseconds,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        // Time display
        if (_duration > Duration.zero)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
