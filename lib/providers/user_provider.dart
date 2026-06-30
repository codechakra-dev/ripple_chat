import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/core/utils/snackbar_helper.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/user_model.dart';
import '../core/utils/helper.dart';
import '../firebase/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  AppLifecycleListener? _listener;
  final FirebaseService _firebaseService = FirebaseService();

  //Use this is ChatScreen;
  String currentChatId = '';
  UserModel? _currentUser;
  UserModel? receiverUser;

  List<UserModel> users = [];
  List<ChatModel> chats = [];
  bool isLoading = false;
  bool isUpdating = false;
  StreamSubscription<UserModel?>? _currentStreamSubscription;

  void appLifeCycleListener() {
    _listener ??= AppLifecycleListener(
      onResume: () async {
        await _firebaseService.updateCurrentStatus(true);
        print("resume");
      },
      onPause: () async {
        print("Pause");
        await _firebaseService.updateCurrentStatus(false);
      },
    );
  }

  UserModel? get currentUser => _currentUser;

  Future<void> updateUserName(
    BuildContext context,
    String newUserName,
    String userId,
  ) async {
    isUpdating = true;
    try {
      UserModel user = await _firebaseService.getUser(userId);
      UserModel userModel = user.copyWith(name: newUserName);
      await _firebaseService.updateUser(userModel);
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          "Error while updating",
          e.toString(),
        );
      }
    } finally {
      isUpdating = false;
    }
  }

  void getUser() {
    _currentStreamSubscription = _firebaseService
        .getSingleUser(_firebaseService.userUid ?? "")
        .listen((user) {
          _currentUser = user;
          notifyListeners();

        });
  }



  Future<String?> updateProfilePic(BuildContext context) async {
    try{
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optional compression to save storage bandwidth
      );

      if (pickedFile == null) return null;
      UploadTask uploadTask = _firebaseService.uploadProfilePhoto(pickedFile, currentUser?.uid ?? '');


      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          // Calculate percentage (0.0 to 1.0)
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          //onProgress(progress);
        }
      }, onError: (e) {
        debugPrint('Error inside progress listener: $e');
      });


      TaskSnapshot completedSnapshot = await uploadTask;

      // 6. Retrieve the public download URL
      String downloadUrl = await completedSnapshot.ref.getDownloadURL();
      await _updateProfilePicUrl( downloadUrl, _currentUser?.uid ?? "" );
      return downloadUrl;
    }catch(e){

      if(context.mounted){
        SnackBarHelper.showSnackBar(context, "Error: ", "Failed to update profile pic");
      }
      return null;
    }
  }
  Future<void> _updateProfilePicUrl(

      String url,
      String userId,
      ) async {

      UserModel user = await _firebaseService.getUser(userId);
      UserModel userModel = user.copyWith(photoUrl: url);
      await _firebaseService.updateUser(userModel);

  }
  void startConversation(
    UserModel receiverUser,
    BuildContext context,
    bool isHomeScreen,
  ) {
    String? currentUserId = _firebaseService.userUid;
    this.receiverUser = receiverUser;
    currentChatId = Helper.generateChatId(
      currentUserId ?? '',
      receiverUser.uid,
    );

    // Navigate to ChatScreen and remove NewChatScreen from the stack

    if (isHomeScreen) {
      Navigator.pushNamed(context, AppStrings.chatScreen);
    } else {
      Navigator.pushReplacementNamed(context, AppStrings.chatScreen);
    }
  }

  void getAvailableUsers() {
    try {
      isLoading = true;
      _firebaseService.getAllUsers().listen((list) {
        users = list;
        // print("Users : ${list[0].name}");
        notifyListeners();
      });

      isLoading = false;
    } catch (e) {
      print("Get all user: $e");
    }
  }

  void getChats() {
    try {
      _firebaseService.getAllChats().listen((list) {
        chats = list;
        notifyListeners();
      });
    } catch (e) {
      print("Get chats: $e");
    }
  }


  void cancelCurrentUserSubscription(){

    _currentStreamSubscription?.cancel();
  }
  void disposeListeners() {
    _listener?.dispose();
    _currentStreamSubscription?.cancel();
  }

  @override
  void dispose() {
    disposeListeners();
    super.dispose();
  }
}
