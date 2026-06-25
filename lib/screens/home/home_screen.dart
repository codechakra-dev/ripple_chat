// screens/chat_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/models/chat_preview_model.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/screens/chat/chat_screen.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../chat/new_chat_screen.dart'; // your ChatScreen

class ChatPreviewScreen extends StatelessWidget {
  const ChatPreviewScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    chatProvider.createChatPreviewsOnStart();
    final previews = chatProvider.chatPreviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: implement search
            },
          ),
        ],
      ),
      body: previews.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: previews.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final preview = previews[index];
          return _buildChatTile(context, preview);
        },
      ),
      // ✅ NEW: Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to New Chat Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewChatScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  // ---- Empty State ----
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to start a new chat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Single Chat Tile ----
  Widget _buildChatTile(BuildContext context, ChatPreviewModel preview) {
    final user = preview.user;
    final isOnline = user.isOnline;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.shade100,
            child: _buildAvatarContent(user),
          ),
          // Online / Offline dot
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.grey.shade400,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        _getDisplayName(user),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        preview.lastMessage,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimeAgo(preview.lastMessageTime),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          // Optional: unread indicator (blue dot)
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent, // set to Colors.blue for unread
            ),
          ),
        ],
      ),
      onTap: () {
        context.read<UserProvider>().startConversation(user, context, true);
      },
    );
  }

  // ---- Helper: Avatar content (photo or initial) ----
  Widget _buildAvatarContent(UserModel user) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    if (hasPhoto) {
      return ClipOval(
        child: Image.network(
          user.photoUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(user),
        ),
      );
    }
    return _buildInitialsAvatar(user);
  }

  Widget _buildInitialsAvatar(UserModel user) {
    final displayName = _getDisplayName(user);
    return Text(
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
    );
  }

  // ---- Helper: Get display name (or email prefix) ----
  String _getDisplayName(UserModel user) {
    if (user.name.isNotEmpty) return user.name;
    if (user.email.isNotEmpty) {
      return user.email.substring(0, user.email.indexOf('@'));
    }
    return 'User';
  }

  // ---- Helper: Time formatting ----
  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}