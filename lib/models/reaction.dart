class Reaction {
  final String reactionType; // E.g., like, love, laugh, etc.
  final String userName; // ID of the user who reacted
  final String messageId; // ID of the message reacted to

  Reaction({
    required this.reactionType,
    required this.userName,
    required this.messageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'reactionType': reactionType,
      'userName': userName,
      'messageId': messageId,
    };
  }

  static fromMap(Map<String, dynamic> data) {}
}
