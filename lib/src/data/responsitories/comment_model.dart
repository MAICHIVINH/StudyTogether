import 'package:timeago/timeago.dart' as timeago;

class CommentModel {
  final String postId;
  final String uid;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;

  CommentModel({
    required this.postId,
    required this.uid,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
  });

  String get timeAgo => timeago.format(timestamp, locale: 'vi');
}
