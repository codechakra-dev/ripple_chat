class MessageModel {
  String? senderId;
  String? receiverId;
  String? message;
  String? timestamp;
  String? messageType;

  MessageModel(
      {this.senderId,
        this.receiverId,
        this.message,
        this.timestamp,
        this.messageType});

  MessageModel.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    message = json['message'];
    timestamp = json['timestamp'];
    messageType = json['messageType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['senderId'] = this.senderId;
    data['receiverId'] = this.receiverId;
    data['message'] = this.message;
    data['timestamp'] = this.timestamp;
    data['messageType'] = this.messageType;
    return data;
  }
}
