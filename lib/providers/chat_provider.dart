import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ripple/firebase/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/chat_preview_model.dart';
import 'package:ripple/models/message_model.dart';
import 'package:ripple/models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController messageInputController = TextEditingController();


  //For ChatPreviewScreen: chatPreview list
  List<ChatPreviewModel> chatPreviews = [];


  //messages to show in current conversation
  List<MessageModel> messages = [];


  UserModel? receiverUser;
  String?   currentChatId;

  //Use this in Chat Screen to Receiver users live status
  var isReceiverUserOnline = false;

  //--Function to get receiver user online status
  void getReceiverUserLiveStatus(String userId){

    _firebaseService.getSingleUser(userId).listen((user){
        isReceiverUserOnline = user.isOnline;
        notifyListeners();

    });
  }





  //Fetches live chatPreview list
  void createChatPreviewsOnStart() async {
    _firebaseService.getAllChats().listen((chatList) async {
      List<ChatPreviewModel> newChatPreview = [];
      for (ChatModel chat in chatList) {
        String userId_1 = chat.participants[0];
        String userId_2 = chat.participants[1];
        String userIdToFetch = '';
        if (userId_1 != _firebaseService.userUid) {
          userIdToFetch = userId_1;
        }
        if (userId_2 != _firebaseService.userUid) {
          userIdToFetch = userId_2;
        }

        UserModel user = await _firebaseService.getUser(userIdToFetch);
        newChatPreview.add(
          ChatPreviewModel(
            chatId: chat.chatId,
            user: user,
            lastMessage: chat.lastMessage,
            lastMessageTime: chat.lastMessageTime,
          ),
        );
      }

      chatPreviews = newChatPreview;
      notifyListeners();
    });
  }


  //Get messages for current chatId
  void getMessages(String chatId) async {

    // bool doesChatExists =  await _firebaseService.doesChatExists(chatId);
    //
    // if(doesChatExists){
    //   _firebaseService.getMessageForCurrentConvo(chatId).listen((messageList){
    //     messages = messageList;
    //     notifyListeners();
    //   });
    // }

  }
  //Sends message to chatId
  Future<DocumentReference> addMessage(String chatId, MessageModel message) async {
    print("Sending message: ");
    return await _firebaseService.addMessage(chatId, message);
  }

   @override
  void dispose(){
    messageInputController.dispose();
    super.dispose();


   }
}
