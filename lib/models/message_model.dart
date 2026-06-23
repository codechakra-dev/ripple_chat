import 'package:cloud_firestore/cloud_firestore.dart';

// Type-safe enum for bonus features
enum MessageType { text, image, voice, video, file }

class MessageModel {
  final String messageId;      // Document ID (non-nullable)
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime? timestamp;   // 👈 DateTime, not String!
  final MessageType messageType;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.timestamp,
    this.messageType = MessageType.text,
  });

  // Firestore factory
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      messageType: _stringToEnum(data['messageType'] ?? 'text'),
    );
  }

  // For SENDING a message (uses server timestamp)
  Map<String, dynamic> toMapForSending() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(), // ✅ Server time
      'messageType': messageType.name, // "text", "image", etc.
    };
  }

  static MessageType _stringToEnum(String value) {
    return MessageType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }

  // Helper for UI
  bool isSentByMe(String currentUserId) => senderId == currentUserId;
}