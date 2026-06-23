import 'package:flutter/material.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/user_model.dart';
import '../firebase/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  late final AppLifecycleListener _listener;
  final FirebaseService _firebaseService = FirebaseService();

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

    getAvailableUsers();
  }

  void getAvailableUsers()  {

    _firebaseService.getAllUsers().listen((list){


      users = list;
     // print("Users : ${list[0].name}");
        notifyListeners();
   });
  }
  void getChats(){
    _firebaseService.getAllChats().listen((list){
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
