import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;              // Non-nullable, from doc.id
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;  // 👈 DateTime, not String!

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
  });

  // Firestore factory (replaces fromJson)
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      chatId: doc.id, // Document ID is the chatId
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }

  // Firestore map (replaces toJson)
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : FieldValue.serverTimestamp(), // For new chats
    };
  }
}