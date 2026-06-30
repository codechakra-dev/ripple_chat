import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ripple/core/utils/snackbar_helper.dart';
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
   final ScrollController _scrollController = ScrollController(

  );
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
  var isReceiverUserTyping = false;
  var isUserTyping = false;
  Timer? _debounceTimer;
  var _isMessageBeingSent = false;

  StreamSubscription<List<MessageModel>>? _messageSubscription;
  StreamSubscription<UserModel>? _liveStatusSubscription;


   bool get isMessageBeingSent => _isMessageBeingSent;
   void setSentMessageTrue(){
     _isMessageBeingSent = true;
     notifyListeners();
   }
  void toggleShowSearch() {
    if (!_showSearch) {
      _showSearch = true;
    } else {
      _showSearch = false;
    }
    print("showSearch: ${_showSearch}");
    notifyListeners();
  }

  void onInit() {
    messageInputController.addListener(_onTextChanged);
    // scrollController.addListener((){
    //   scrollToBottom();
    // });
  }

  void _onTextChanged() {
    if (messageInputController.text.isEmpty) {
      if (isUserTyping) {
        isUserTyping = false;
        updateCurrentUserTypingStatus(isUserTyping);
      }
      return;
    }
    if (!isUserTyping) {
      isUserTyping = true;
      updateCurrentUserTypingStatus(isUserTyping);
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      isUserTyping = false;
      updateCurrentUserTypingStatus(isUserTyping);
    });
  }

  bool get showSearch => _showSearch;

  //--Function to get receiver user online status
  void getReceiverUserLiveStatus(String userId) {
    _liveStatusSubscription = _firebaseService.getSingleUser(userId).listen((
      user,
    ) {
      isReceiverUserOnline = user.isOnline;
      isReceiverUserTyping = user.isTyping;
      notifyListeners();
    });
  }

  void updateCurrentUserTypingStatus(bool isTyping) async {
    await _firebaseService.updateIsTypingStatus(isTyping);
  }

  void scrollToBottom() {
    // Check if the controller is safely attached to the widget

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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

    _messageSubscription = _firebaseService
        .getMessageForCurrentConvo(chatId)
        .listen((messageList) {
          //messageList.sort((a,b)=> b.timestamp!.compareTo(a.timestamp!));
          messages = messageList;


          if (previousMessageTimeStamp != messageList.last.timestamp) {
            scrollToBottom();
            previousMessageTimeStamp = messageList.last.timestamp;
          }
          notifyListeners();
          //_scrollToBottom();
        });
  }

  //Sends message to chatId
  Future<void> addMessage( String chatId, MessageModel message,) async {


       await _firebaseService.addMessage(chatId, message);


  }

  Future<void> sendMessage(BuildContext context, {required UserModel? receiverUser}) async {

    _isMessageBeingSent = true;
    notifyListeners();
    final text = messageInputController.text.trim();

    currentChatId = Helper.generateChatId(
      _firebaseService.userUid ?? '',
      receiverUser?.uid ?? '',
    );

   try{
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
   }catch(e){
     if(context.mounted){
       SnackBarHelper.showSnackBar(context, "Error sending message", "$e");
     }
   }finally{
     _isMessageBeingSent = false;
   }
  }
  Future<void> sendPhoto(BuildContext context, {required UserModel? receiverUser}) async{
    try{
      currentChatId = Helper.generateChatId(
        _firebaseService.userUid ?? '',
        receiverUser?.uid ?? '',
      );
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optional compression to save storage bandwidth
      );

      if (pickedFile == null) return ;


      _isMessageBeingSent = true;
      messageInputController.text = pickedFile.name;
      UploadTask uploadTask = _firebaseService.uploadPhoto(pickedFile, currentChatId ?? '');


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
      //await _updateProfilePicUrl( downloadUrl, _firebaseService.userUid ?? "" );

      final message = MessageModel(
        messageId: '',
        senderId: _firebaseService.userUid ?? '',
        receiverId: receiverUser?.uid ?? "" ,
        message: downloadUrl,
        messageType: MessageType.image,
      );
      print("current chatId : $currentChatId");
      await _firebaseService.createChat(
        ChatModel(
          chatId: currentChatId ?? '',
          participants: [message.senderId, message.receiverId],
          lastMessage: message.message,
        ),
      );
        print("CurrentChatId $currentChatId");
         await addMessage(currentChatId ?? "", message);

      //return downloadUrl;
    }catch(e){

      if(context.mounted){
        SnackBarHelper.showSnackBar(context, "Error: ", "Failed to send image");
      }
      print("Error sending photo: $e");
      //return null;
    }finally{
      messageInputController.text = "";
      _isMessageBeingSent = false;
    }
  }

  Future<void> deleteMessage(BuildContext context,MessageModel message, UserModel? receiverUser)async{
    try{

      currentChatId = Helper.generateChatId(
        _firebaseService.userUid ?? '',
        receiverUser?.uid ?? '',
      );
      await _firebaseService.deleteMessage(currentChatId!, message);
      // if(context.mounted){
      //   SnackBarHelper.showSnackBar(context, "Success ", "Deleted message!");
      // }
    }catch(e){
      if(context.mounted){
        SnackBarHelper.showSnackBar(context, "Error in deleting: ", "$e");
      }
    }
  }
  void closeSubscriptions() {
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
