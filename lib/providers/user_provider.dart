import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/user_model.dart';
import '../core/utils/helper.dart';
import '../firebase/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  late final AppLifecycleListener _listener;
  final FirebaseService _firebaseService = FirebaseService();

  //Use this is ChatScreen;
  String currentChatId = '';
  UserModel? receiverUser;

  List<UserModel> users = [];
  List<ChatModel> chats = [];
  bool isLoading = false;

  UserProvider() {
    _listener = AppLifecycleListener(
      onResume: () {
        _firebaseService.updateCurrentStatus(true);
      },
      onPause: () {
        print("Pause");
        _firebaseService.updateCurrentStatus(false);
      },
    );
  }

  void startConversation(UserModel receiverUser, BuildContext context) {
    String? currentUserId = _firebaseService.userUid;
    this.receiverUser = receiverUser;
    currentChatId = Helper.generateChatId(
      currentUserId ?? '',
      receiverUser.uid,
    );

    // Navigate to ChatScreen and remove NewChatScreen from the stack

    Navigator.pushReplacementNamed(context, AppStrings.chatScreen);
  }

  void getAvailableUsers() {
    _firebaseService.getAllUsers().listen((list) {
      users = list;
      // print("Users : ${list[0].name}");
      notifyListeners();
    });
  }

  void getChats() {
    _firebaseService.getAllChats().listen((list) {
      chats = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }
}
