class ChatModel {
  String? chatId;
  List<String>? participants;
  String? lastMessage;
  String? lastMessageTime;

  ChatModel(
      {this.chatId, this.participants, this.lastMessage, this.lastMessageTime});

  ChatModel.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    participants = json['participants'].cast<String>();
    lastMessage = json['lastMessage'];
    lastMessageTime = json['lastMessageTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatId'] = chatId;
    data['participants'] = participants;
    data['lastMessage'] = lastMessage;
    data['lastMessageTime'] = lastMessageTime;
    return data;
  }
}