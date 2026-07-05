// screens/chat/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/utils/snackbar_helper.dart';
import 'package:ripple/models/future_response.dart';
import 'package:ripple/models/message_model.dart';
import 'package:ripple/models/user_model.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:ripple/widgets/audio_input.dart';
import 'package:ripple/widgets/audio_player_widget.dart';
import 'package:ripple/widgets/typing_bubble.dart';

import '../../core/constants/app_strings.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool runOnlyOnce = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {


      final chatProvider = context.read<ChatProvider>();
      final userProvider = context.read<UserProvider>();
      final receiver = userProvider.receiverUser;
      final chatId = userProvider.currentChatId;
      chatProvider.onInit();
      if (chatId.isNotEmpty) {
        // Only load if messages are empty OR the chatId changed (optional safety)
        // Our getMessages method cancels previous subscription anyway.
        // print("Initial ChatId : $chatId");
        chatProvider.getMessages(chatId);
      }
      if (receiver != null && receiver.uid.isNotEmpty) {
        chatProvider.getReceiverUserLiveStatus(receiver.uid);
      }


    });
  }
  @override
  Widget build(BuildContext context) {
    // 1️⃣ Read providers

    final userProvider = context.read<UserProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    final chatId = userProvider.currentChatId;
    final receiver = userProvider.receiverUser;
    final messages = chatProvider.messages;
    final isOnline = chatProvider.isReceiverUserOnline;
    final currentUserId = authProvider.currentUser?.uid ?? '';


 
    // 2️⃣ Load messages & status (only once per chatId change)

    // 3️⃣ Build UI
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // if (didPop) return;

        //Navigator.pop(context);
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        chatProvider.messageInputController.text = "";
        chatProvider.currentChatId = "";
        chatProvider.previousMessageTimeStamp = null;
        chatProvider.removeListenerForMessageInputController();
        chatProvider.closeSubscriptions();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              chatProvider.setIsUserProfile(false);
              Navigator.pushNamed(context, AppStrings.profileScreen);
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: _buildAvatarContent(receiver),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(receiver),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);

              //Hides keyboard
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              chatProvider.messageInputController.text = "";
              chatProvider.currentChatId = "";
              chatProvider.previousMessageTimeStamp = null;
              chatProvider.closeSubscriptions();
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (_, _) {
            return Column(
              children: [
                Expanded(
                  child: receiver == null
                      ? const Center(child: Text('Conversation not found'))
                      : Column(
                          children: [
                            // Messages list
                            messages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No messages yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Say hello to ${_getDisplayName(receiver)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      controller: chatProvider.scrollController,
                                        reverse: true,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 12,
                                      ),
                                      itemCount: messages.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < messages.length) {
                                          final message = messages[index];

                                          final isMe =
                                              message.senderId == currentUserId;
                                          return MessageBubble(
                                            isMe: isMe,
                                            message: message,
                                          );
                                        } else {
                                          if (chatProvider
                                              .isReceiverUserTyping) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [TypingBubble()],
                                            );
                                          }
                                          return null;
                                        }
                                      },
                                    ),
                                  ),

                          ],
                        ),
                ),

                Row(
                  children: [
                    if (chatProvider.inputType == "message") ...[
                      Expanded(
                        child: const MessageInput(),
                      ),
                    ] else ...[
                      Expanded(child: const AudioInput()),
                    ],
                    IconButton(
                      onPressed: () async {
                        if (chatProvider.inputType == "audio") {
                          if (chatProvider.isRecordingFinished) {
                            //send audio
                            String message = await chatProvider
                                .sendVoiceMessage();
                            if (context.mounted) {
                              if (message.contains("error")) {
                                SnackBarHelper.showSnackBar(
                                  context,
                                  "Error",
                                  message,
                                );
                              } else {
                                SnackBarHelper.showSnackBar(
                                  context,
                                  "Success",
                                  message,
                                );
                              }
                            }
                          }
                        } else {
                          chatProvider.inputType = "audio";
                        }
                      },
                      icon: Icon(
                        chatProvider.isRecording
                            ? Icons.record_voice_over
                            : chatProvider.isRecordingFinished
                            ? Icons.send
                            : Icons.mic_outlined,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),

      ),
    );
  }

  // ---- Message Bubble ----
  Widget _buildAvatarContent(UserModel? user) {
    if (user == null) return const Text('?');
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    if (hasPhoto) {
      return ClipOval(
        child: Image.network(
          user.photoUrl!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(user),
        ),
      );
    }
    return _buildInitials(user);
  }

  Widget _buildInitials(UserModel user) {
    final displayName = _getDisplayName(user);
    return Text(
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
    );
  }

  String _getDisplayName(UserModel? user) {
    if (user == null) return 'User';
    if (user.name.isNotEmpty) return user.name;
    if (user.email.isNotEmpty) {
      return user.email.substring(0, user.email.indexOf('@'));
    }
    return 'User';
  }
}

class MessageBubble extends StatefulWidget {
  final bool isMe;
  final MessageModel message;

  const MessageBubble({required this.isMe, required this.message, super.key});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Offset? _tapPosition = Offset.zero;

  // 2. Your helper method to update it
  void _getTapPosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
    print("on tap down: dx ${_tapPosition?.dx} dy: ${_tapPosition?.dy}");
  }

  void _showContextMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Open the popup precisely at the finger tap location
    final String? selectedAction = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition?.dx ?? 0, _tapPosition?.dy ?? 0, 40, 40),
        // Tap location bounding box
        Offset.zero & overlay.size, // Screen dimensions
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 20),
              SizedBox(width: 10),
              Text('Copy Text'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text('Delete for everyone', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    // Handle the selected action
    if (selectedAction == 'delete' && context.mounted) {
      _confirmDelete(context);
    } else if (selectedAction == 'copy') {
      // Handle your text copy logic here
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    context.read<ChatProvider>().deleteMessage(
      widget.message,
      context.read<UserProvider>().receiverUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _getTapPosition,
      onLongPress: () {
        _showContextMenu(context);
      },
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isMe ? Colors.blue : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: widget.isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.message.messageType == MessageType.image) ...[
                Image.network(widget.message.message),
              ] else if (widget.message.messageType == MessageType.voice) ...[
                AudioPlayerWidget(url: widget.message.message),
              ] else ...[
                Text(
                  widget.message.message,
                  style: TextStyle(
                    color: widget.isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatTime(widget.message.timestamp),
                style: TextStyle(
                  color: widget.isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatProvider>().messageInputController;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        //color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,

              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () async {
                    FutureResponse response = await context
                        .read<ChatProvider>()
                        .sendPhoto(
                          receiverUser: context
                              .read<UserProvider>()
                              .receiverUser,
                        );

                    if (context.mounted) {
                      SnackBarHelper.showSnackBar(
                        context,
                        response.isSuccess ? "Success" : "Error",
                        response.message,
                      );
                    }
                  },
                  icon: Icon(Icons.add_photo_alternate_outlined),
                ),
                filled: true,
                //  fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: context.watch<ChatProvider>().isMessageBeingSent
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      context.read<ChatProvider>().sendMessage(
                        receiverUser: context.read<UserProvider>().receiverUser,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
