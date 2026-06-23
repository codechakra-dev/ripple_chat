import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;          // 👈 Non-nullable (taken from doc.id)
  final String name;         // 👈 Non-nullable
  final String email;        // 👈 Non-nullable
  final String? photoUrl;    // 👈 Nullable (users might not have a photo)
  final bool isOnline;       // 👈 Non-nullable with default
  final DateTime? lastSeen;  // 👈 DateTime, not String!

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,   // Default to offline
    this.lastSeen,
  });

  // Firestore factory (replaces fromJson)
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // 👈 CRITICAL: Document ID MUST be the UID
      name: data['name'] ?? 'Unknown User',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  // Firestore map (replaces toJson)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null
          ? Timestamp.fromDate(lastSeen!)
          : FieldValue.serverTimestamp(), // Use server time when creating
    };
  }

  // ⚠️ Special method for updating online status
  Map<String, dynamic> toMapForOnlineStatus() {
    return {
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(), // Always server time!
    };
  }

  // Helper: Create a copy with updated fields (great for state management)
  UserModel copyWith({
    String? name,
    String? photoUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, isOnline: $isOnline, lastSeen: $lastSeen)';
  }
}
