class UserModel {
  String? uid;
  String? name;
  String? email;
  String? photoUrl;
  bool? isOnline;
  String? lastSeen;

  UserModel({

    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.isOnline,
    this.lastSeen
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    email = json['email'];
    photoUrl = json['photoUrl'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    data['isOnline'] = this.isOnline;
    data['lastSeen'] = this.lastSeen;
    return data;
  }
}
