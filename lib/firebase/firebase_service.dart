import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ripple/firebase/auth_service.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/message_model.dart';
import 'package:ripple/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  //get user id
  String? get userUid => _authService.firebaseAuth.currentUser?.uid;

  //users collection reference
  CollectionReference get usersRef => _firestore.collection("users");

  //current user collection reference
  DocumentReference get currentUserRef =>
      _firestore.collection("users").doc(userUid ?? "");

  //Chats collection reference
  CollectionReference get chatsReference => _firestore.collection("chats");
  final Reference _storageRef = FirebaseStorage.instance.ref().child(
    "user_profile",
  );

  //--GET STORAGE REFERENCE
  Reference get storageRef => _storageRef;

  UploadTask uploadProfilePhoto(XFile file, String userId) {
    String fileExtension = file.name.split('.').last.toLowerCase();

    // Dynamically set the correct mime type string
    String contentType = 'image/$fileExtension';
    UploadTask uploadTask = storageRef
        .child(userId)
        .putFile(File(file.path), SettableMetadata(contentType: contentType));
    return uploadTask;
  }

  UploadTask uploadPhoto(XFile file, String chatId) {
    String fileExtension = file.name.split('.').last.toLowerCase();

    // Dynamically set the correct mime type string
    String contentType = 'image/$fileExtension';
    UploadTask uploadTask = storageRef
        .child(chatId)
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(File(file.path), SettableMetadata(contentType: contentType));
    return uploadTask;
  }

  UploadTask uploadAudio(File file, String chatId) {

    String contentType = 'audio/m4a';
    UploadTask uploadTask = storageRef
        .child(chatId)
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(File(file.path), SettableMetadata(contentType: contentType));
    return uploadTask;
  }

  // --- GET ALL USERS ---
  Stream<List<UserModel>> getAllUsers() {
    return usersRef.snapshots().map((snapshots) {
      return snapshots.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    });
  }

  // ---GET SINGLE USER---

  Stream<UserModel> getSingleUser(String userId) {
    return usersRef
        .doc(userId)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  }

  Future<UserModel> getUser(String userId) async {
    DocumentSnapshot? doc = await usersRef.doc(userId).get();
    return UserModel.fromFirestore(doc);
  }

  //--- GET ALL CHATS ---

  Stream<List<ChatModel>> getAllChats() {
    // Guard against null userUid
    final uid = userUid;
    if (uid == null || uid.isEmpty) {
      // Return an empty stream or handle accordingly
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid) // 🔥 THE FIX
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromFirestore(doc))
              .toList();
        });
  }

  //--- GET SINGLE CHAT
  Stream<ChatModel> getSingleChat(String chatId) {
    return chatsReference
        .doc(chatId)
        .snapshots()
        .map((doc) => ChatModel.fromFirestore(doc));
  }

  //-- GET MESSAGES FOR SINGLE CONVERSATION ONLY FOR CURRENT USER USING CHAT ID ---

  Future<bool> doesChatExists(String chatId) async {
    var docRef = await _firestore.collection("chats").doc(chatId).get();
    return docRef.exists;
  }

  Stream<List<MessageModel>> getMessageForCurrentConvo(String chatId) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  //  Create user
  Future<void> createUser(UserModel user) async {
    await usersRef.doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await usersRef.doc(user.uid).set(user.toMap());
  }

  //--For sending a message
  Future<void> addMessage(String chatId, MessageModel message) async {
    return await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc()
        .set(message.toMapForSending());
  }

  Future<void> updateAMessage(
    String chatId,
    MessageModel updatedMessage,
  ) async {
    await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(updatedMessage.messageId)
        .set(updatedMessage.toMapForSending());
  }

  Future<void> deleteMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(message.messageId)
        .delete();
  }

  //Create a chat between currentUser and receiver user
  Future<void> createChat(ChatModel chat) async {
    await chatsReference.doc(chat.chatId).set(chat.toMap());
  }

  //Update current user state
  Future<void> updateCurrentStatus(bool isOnline) async {
    DocumentSnapshot? doc = await currentUserRef.get();
    UserModel userModel = UserModel.fromFirestore(doc);
    UserModel userModel1 = userModel.copyWith(isOnline: isOnline);
    await currentUserRef.set(userModel1.toMap());
  }

  //Update is typing status
  Future<void> updateIsTypingStatus(bool isTyping) async {
    DocumentSnapshot? doc = await currentUserRef.get();
    UserModel userModel = UserModel.fromFirestore(doc);
    UserModel userModel1 = userModel.copyWith(isTyping: isTyping);
    await currentUserRef.set(userModel1.toMap());
  }
}
