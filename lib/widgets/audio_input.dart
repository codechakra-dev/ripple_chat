import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/utils/helper.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/user_provider.dart';

class AudioInput extends StatelessWidget {
  const AudioInput({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.watch<UserProvider>();
    chatProvider.receiverUser = userProvider.receiverUser;
    chatProvider.initRecorder();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          chatProvider.isRecording ||
              chatProvider.recordingDuration > Duration(seconds: 1)
              ? Row(
            children: [
              if (chatProvider.isRecording) ...[
                IconButton(
                  icon: Icon(
                    chatProvider.isRecordingPause
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: Colors.black54,
                  ),
                  onPressed: chatProvider.togglePause,
                  tooltip: chatProvider.isRecordingPause ? 'Resume' : 'Pause',
                ),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  Helper.formatDuration(chatProvider.recordingDuration),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              if(chatProvider.isRecording)...[
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.red),
                  onPressed: chatProvider.stopRecording,
                  tooltip: 'Stop recording',
                ),

              ],


            ],
          )
              : IconButton(
            icon: const Icon(Icons.mic, color: Colors.black54),
            onPressed: chatProvider.isRecorderInitialized
                ? chatProvider.startRecording
                : null,
            tooltip: 'Start recording',
            iconSize: 28,
          ),

          IconButton(
            onPressed: () {
              chatProvider.closeRecorder();
            },
            icon: Icon(Icons.close),
          ),
        ],
      )

    );
  }
}

//
