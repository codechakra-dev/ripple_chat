// screens/chat/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/models/message_model.dart';
import 'package:ripple/models/user_model.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/user_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //
    // });
    if (chatId.isNotEmpty) {
      // Only load if messages are empty OR the chatId changed (optional safety)
      // Our getMessages method cancels previous subscription anyway.
      // print("Initial ChatId : $chatId");
      chatProvider.getMessages(chatId);
    }
    if (receiver != null && receiver.uid.isNotEmpty) {
      chatProvider.getReceiverUserLiveStatus(receiver.uid);
    }

    // 3️⃣ Build UI
    return Scaffold(
      appBar: AppBar(
        title: Row(
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

        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){

            Navigator.pop(context);
            // 1. Force the keyboard to close by removing focus
            FocusManager.instance.primaryFocus?.unfocus();
            FocusScope.of(context).unfocus();
            chatProvider.messageInputController.text = "";
            chatProvider.currentChatId = "";
            chatProvider.previousMessageTimeStamp = null;
            chatProvider.closeSubscriptions();


          },
        ),

      ),
      body: receiver == null
          ? const Center(child: Text('Conversation not found'))
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                      : ListView.builder(

                          controller: chatProvider.scrollController,
                          reverse: false,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            final isMe = message.senderId == currentUserId;
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),
                // Input field
                const SizedBox(height: 10,),
                const MessageInput(),
                //_buildMessageInput(context, chatId, currentUserId),
              ],
            ),
    );
  }

  // ---- Message Bubble ----
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ---- Helpers (unchanged) ----
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
            child: IconButton(
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
