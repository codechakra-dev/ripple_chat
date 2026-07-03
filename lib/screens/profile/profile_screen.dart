import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final userProvider = context.watch<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    //userProvider.getUser();
    print("Receiver User: ${chatProvider.receiverUser?.email}");
    final username = chatProvider.isUserProfile ?  userProvider.currentUser?.name ?? authProvider.currentUser?.displayName ?? '' : chatProvider.receiverUser?.name ?? '';
    final email = chatProvider.isUserProfile ? authProvider.currentUser?.email ?? userProvider.currentUser?.email ?? '' : chatProvider.receiverUser?.email ?? '';
    final photoUrl =chatProvider.isUserProfile ?  userProvider.currentUser?.photoUrl ?? authProvider.currentUser?.photoURL ?? '' : chatProvider.receiverUser?.photoUrl ?? '';
    final userId = chatProvider.isUserProfile ? authProvider.currentUser?.uid ?? '' : chatProvider.receiverUser?.uid ?? '';
    //print("User Profile photo: ${userProvider.currentUser?.photoUrl}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
           // userProvider.cancelCurrentUserSubscription();
            chatProvider.setIsUserProfile(true);
            print("Receiver User: ${chatProvider.receiverUser?.email}");

            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Profile Photo with edit overlay ---
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  if(chatProvider.isUserProfile)...[
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _updateProfilePhoto(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ]

                ],
              ),
              const SizedBox(height: 24),

              // --- Username with edit button ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if(chatProvider.isUserProfile)...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () =>
                          _showEditUsernameDialog(context, username, userId),
                      tooltip: 'Edit username',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ]

                ],
              ),
              const SizedBox(height: 8),

              // --- Email ---
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              if(chatProvider.isUserProfile)...[
                const SizedBox(height: 48),

                // --- Logout Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your logout logic here
                      authProvider.signOut(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ]

            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //   Profile photo update – EMPTY PLACEHOLDER
  // ============================================================
  void _updateProfilePhoto(BuildContext context) {

    context.read<UserProvider>().updateProfilePic(context);

  }

  // ============================================================
  //   Edit Username dialog (kept as in your original code)
  // ============================================================
  void _showEditUsernameDialog(
      BuildContext context,
      String username,
      String userId,
      ) {
    final controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newUsername = controller.text.trim();
                if (newUsername.isNotEmpty) {
                  await context
                      .read<UserProvider>()
                      .updateUserName(newUsername, userId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username cannot be empty'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}