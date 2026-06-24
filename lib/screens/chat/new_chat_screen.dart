// screens/new_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/models/user_model.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/user_provider.dart';
import 'package:ripple/screens/chat/chat_screen.dart';
import 'package:ripple/utils/helpers.dart';

import '../../core/utils/helper.dart'; // contains generateChatId()

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Load users if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.users.isEmpty) {
        userProvider.getAvailableUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final currentUser = authProvider.currentUser;
    final userProvider = context.watch<UserProvider>();
    final allUsers = userProvider.users;

    // Filter out the current user
    final otherUsers = allUsers.where((u) => u.uid != currentUser?.uid).toList();

    // Apply search filter
    final displayUsers = _searchController.text.isEmpty
        ? otherUsers
        : otherUsers.where((u) {
      final name = u.name.toLowerCase();
      final email = u.email.toLowerCase();
      final query = _searchController.text.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Search bar in AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}), // rebuild on search
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayUsers.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayUsers.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final user = displayUsers[index];
          return _buildUserTile(context, user, currentUser?.uid ?? "");
        },
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
            Icons.person_search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No other users found'
                : 'No results for "${_searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Invite your friends to join!'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ---- User Tile ----
  Widget _buildUserTile(BuildContext context, UserModel user, String currentUid) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.shade100,
            child: _buildAvatarContent(user),
          ),
          // Online status dot
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: user.isOnline ? Colors.green : Colors.grey.shade400,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user.name.isNotEmpty ? user.name : _getEmailPrefix(user.email),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        user.isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: user.isOnline ? Colors.green : Colors.grey.shade500,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: () {
          //Navigate to chat screen to start conversation
          context.read<UserProvider>().startConversation(user, context);

      },
    );
  }

  // ---- Avatar Content ----
  Widget _buildAvatarContent(UserModel user) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    if (hasPhoto) {
      return ClipOval(
        child: Image.network(
          user.photoUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(user),
        ),
      );
    }
    return _buildInitials(user);
  }

  Widget _buildInitials(UserModel user) {
    final displayName = user.name.isNotEmpty ? user.name : _getEmailPrefix(user.email);
    return Text(
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
    );
  }

  // ---- Helper: Get email prefix ----
  String _getEmailPrefix(String email) {
    if (email.isEmpty) return 'User';
    return email.substring(0, email.indexOf('@'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}