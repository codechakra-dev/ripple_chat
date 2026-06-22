import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ripple/firebase/auth_service.dart';
import 'package:ripple/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  void someFunction() {
    String? userId = _authService.firebaseAuth.currentUser?.uid;
  }

  //get user id
  String? get userUid => _authService.firebaseAuth.currentUser?.uid;

  //users collection reference
  CollectionReference get usersRef => _firestore.collection("users");

  //current user collection reference
  DocumentReference get currentUserRef =>
      _firestore.collection("users").doc(userUid ?? "");


  //Chats collection reference
  CollectionReference get chatsReference => _firestore.collection("chats");

  Stream<List<UserModel>> getAllUsers() {
    return usersRef.snapshots().map((snapshots) {
      return snapshots.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
