import 'package:cloud_firestore/cloud_firestore.dart';
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


  // --- GET ALL USERS ---
  Stream<List<UserModel>> getAllUsers() {
    return usersRef.snapshots().map((snapshots) {
      return snapshots.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    });
  }

  //--- GET ALL CHATS ---

  Stream<List<ChatModel>> getAllChats() {
    return chatsReference.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    });
  }

  //-- GET MESSAGES FOR SINGLE CONVERSATION ONLY FOR CURRENT USER USING CHAT ID ---

  Stream<List<MessageModel>> getMessageForCurrentConvo(String chatId) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
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




  //--For sending a message
  Future<DocumentReference> addMessage(
    String chatId,
    MessageModel message,
  ) async {
    return await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add(message.toMapForSending());
  }
  
  Future<void> updateAMessage(String chatId, MessageModel updatedMessage) async{
    
     await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages").doc(updatedMessage.messageId).set(updatedMessage.toMapForSending());
  }

  Future<void> deleteMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages").doc(message.messageId).delete();
  }


  //Create a chat between currentUser and receiver user
  Future<void> createChat(ChatModel chat) async{
    await chatsReference.doc(chat.chatId).set(chat.toMap());

  }

  //Update current user state
  Future<void> updateCurrentStatus(bool isOnline) async {
   DocumentSnapshot? doc = await currentUserRef.get();
   UserModel userModel =  UserModel.fromFirestore(doc);
   UserModel userModel1 = userModel.copyWith(isOnline: isOnline);
   await currentUserRef.set(userModel1.toMap());
  }

}
