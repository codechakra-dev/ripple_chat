import 'package:ripple/models/user_model.dart';

class ChatPreviewModel {
  final String chatId;
  final UserModel user;          // The OTHER user (not you)
  final String lastMessage;
  final DateTime? lastMessageTime;

  ChatPreviewModel({
    required this.chatId,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}