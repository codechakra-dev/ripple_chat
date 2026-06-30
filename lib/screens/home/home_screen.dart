// screens/chat_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/models/chat_preview_model.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/screens/chat/chat_screen.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../chat/new_chat_screen.dart'; // your ChatScreen

enum MenuAction { profile, settings, logout }

class ChatPreviewScreen extends StatelessWidget {
  const ChatPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.read<UserProvider>();
    userProvider.appLifeCycleListener();
    chatProvider.createChatPreviewsOnStart();
    final previews = chatProvider.chatPreviews;
    final displayPreview = previews.where((preview) {
      final name = preview.user.name.toLowerCase();
      final email = preview.user.email.toLowerCase();
      final query = chatProvider.searchTextController.text.trim().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        elevation: 0.5,
        actions: [
          if (!chatProvider.showSearch) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                chatProvider.toggleShowSearch();
                print("Search button pressed");
              },
            ),
          ],

          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert), // Three-dot menu icon
            onSelected: (action) {
              // Handle the tap
              switch (action) {
                case MenuAction.profile:
                  // Navigate to profile or show a dialog
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Profile tapped!')),
                  //   );

                  Navigator.pushNamed(context, AppStrings.profileScreen);
                  // Navigator.push(context, MaterialPageRoute(...));
                  break;
                case MenuAction.settings:
                  // Handle settings
                  Navigator.pushNamed(context, AppStrings.settingsScreen);
                  break;
                case MenuAction.logout:
                  // Handle logout
                  break;
              }
            },
            itemBuilder: (context) => [
              // --- PROFILE BUTTON (Featured) ---
              const PopupMenuItem<MenuAction>(
                value: MenuAction.profile,
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              // --- Other menu items ---
              const PopupMenuItem<MenuAction>(
                value: MenuAction.settings,
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],

        bottom: chatProvider.showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: context
                        .read<ChatProvider>()
                        .searchTextController,
                    onChanged: (_) {}, // rebuild on search
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      suffixIcon:
                          context
                              .read<ChatProvider>()
                              .searchTextController
                              .text
                              .isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                context
                                        .read<ChatProvider>()
                                        .searchTextController
                                        .text =
                                    "";
                                context.read<ChatProvider>().toggleShowSearch();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: displayPreview.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: displayPreview.length ,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final preview = displayPreview[index];
                return _buildChatTile(context, preview);
              },
            ),
      // ✅ NEW: Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to New Chat Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewChatScreen()),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        preview.lastMessage,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimeAgo(preview.lastMessageTime),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
