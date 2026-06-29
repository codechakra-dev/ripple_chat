import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ripple/firebase/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:ripple/models/chat_model.dart';
import 'package:ripple/models/chat_preview_model.dart';
import 'package:ripple/models/message_model.dart';
import 'package:ripple/models/user_model.dart';

import '../core/utils/helper.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController messageInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();

  //For ChatPreviewScreen: chatPreview list
  List<ChatPreviewModel> chatPreviews = [];

  //messages to show in current conversation
  List<MessageModel> messages = [];

  UserModel? receiverUser;
  String? currentChatId;
  DateTime? previousMessageTimeStamp;

  ScrollController get scrollController => _scrollController;
  TextEditingController get searchTextController => _searchTextController;

  //Use this in Chat Screen to Receiver users live status
  var isReceiverUserOnline = false;
  var isCalled = false;
  var _showSearch = false;
  ChatProvider() {
    scrollToBottom();
  }

  StreamSubscription<List<MessageModel>>? _messageSubscription;
  StreamSubscription<UserModel>? _liveStatusSubscription;


  void toggleShowSearch(){
    if(!_showSearch){
      _showSearch = true;
    }else{
      _showSearch = false;
    }
    print("showSearch: ${_showSearch}");
    notifyListeners();

  }
  bool get showSearch => _showSearch;
  //--Function to get receiver user online status
  void getReceiverUserLiveStatus(String userId) {
   _liveStatusSubscription =  _firebaseService.getSingleUser(userId).listen((user) {
      isReceiverUserOnline = user.isOnline;
      notifyListeners();
    }) ;
  }

  void scrollToBottom() {
    // Check if the controller is safely attached to the widget
    if (_scrollController.hasClients) {
      _scrollController.jumpTo( _scrollController.position.maxScrollExtent);
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent, // Target position
      //   duration: const Duration(milliseconds: 10), // Speed
      //   curve: Curves.linear, // Animation style
      // );
    }
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
    //bool doesChatExists =  await _firebaseService.doesChatExists(chatId);


      _messageSubscription =  _firebaseService.getMessageForCurrentConvo(chatId).listen((messageList) {
          //messageList.sort((a,b)=> b.timestamp!.compareTo(a.timestamp!));
          messages = messageList;
          notifyListeners();

          if (previousMessageTimeStamp != messageList.last.timestamp) {
            scrollToBottom();
            previousMessageTimeStamp = messageList.last.timestamp;
          }
          //_scrollToBottom();

        });



  }

  //Sends message to chatId
  Future<void> addMessage(String chatId, MessageModel message) async {
    print("Sending message: ");
    await _firebaseService.addMessage(chatId, message);
  }

  Future<void> sendMessage({required UserModel? receiverUser}) async {
    final text = messageInputController.text.trim();

    currentChatId = Helper.generateChatId(
      _firebaseService.userUid ?? '',
      receiverUser?.uid ?? '',
    );

    if (text.isNotEmpty &&
        (currentChatId != null && currentChatId!.isNotEmpty)) {
      final receiver = receiverUser;
      if (receiver == null) {
        print('Receiver is null');
        return;
      }

      final message = MessageModel(
        messageId: '',
        senderId: _firebaseService.userUid ?? '',
        receiverId: receiver.uid,
        message: text,
        messageType: MessageType.text,
      );
      await _firebaseService.createChat(
        ChatModel(
          chatId: currentChatId ?? '',
          participants: [message.senderId, message.receiverId],
          lastMessage: message.message,
        ),
      );

      await addMessage(currentChatId ?? '', message);

      print('MessageId : sending');
      // print('MessageId : ${id}');
      messageInputController.text = "";
    } else {
      print('MessageId : else  ${currentChatId}');
      print('MessageId : else  ${text}');
    }
  }
  void closeSubscriptions(){
    _messageSubscription?.cancel();
    _liveStatusSubscription?.cancel();
  }

  @override
  void dispose() {
    messageInputController.dispose();
    scrollController.dispose();
    searchTextController.dispose();
    closeSubscriptions();
    super.dispose();
  }
}
